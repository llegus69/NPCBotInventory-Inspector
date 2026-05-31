-- ============================================================
-- NPCBotInventory - Core.lua
-- Logica de datos: captura mensajes, guarda y carga inventarios
-- Compatible con WotLK 3.3.5
-- ============================================================

NPCBotInventory = NPCBotInventory or {}
local NBI = NPCBotInventory

NBI.botInventories = {}
NBI.botStats       = {}
NBI.botRealStats   = {}
NBI.botRoles       = {}
NBI.botClasses     = {}
NBI.botEntryByName = {}
NBI.playerName     = nil
NBI.lastCallTime   = 0

local BSTATS_PREFIX = "BSTATS"

-- ============================================================
-- Mapa: texto del whisper "Cambiando mi talento a X" → clave de spec
-- ============================================================
local TALENT_NAME_TO_SPEC = {
    ["Armas"]          = "WARRIOR_ARMS",
    ["Furia"]          = "WARRIOR_FURY",
    ["Reprensión"]     = "PALADIN_RET",
    ["Bestias"]        = "HUNTER_BM",
    ["Puntería"]       = "HUNTER_MM",
    ["Supervivencia"]  = "HUNTER_SURV",
    ["Asesinato"]      = "ROGUE_ASS",
    ["Combate"]        = "ROGUE_COMBAT",
    ["Sutileza"]       = "ROGUE_SUB",
    ["Disciplina"]     = "PRIEST_DISC",
    ["Sombra"]         = "PRIEST_SHADOW",
    ["Sangre"]         = "DK_BLOOD",
    ["Profano"]        = "DK_UNHOLY",
    ["Elemental"]      = "SHAMAN_ELEM",
    ["Mejora"]         = "SHAMAN_ENH",
    ["Arcano"]         = "MAGE_ARCANE",
    ["Fuego"]          = "MAGE_FIRE",
    ["Aflicción"]      = "WARLOCK_AFF",
    ["Demonología"]    = "WARLOCK_DEMO",
    ["Destrucción"]    = "WARLOCK_DESTRO",
    ["Equilibrio"]     = "DRUID_BALANCE",
    ["Feral"]          = "DRUID_FERAL",
}

-- Specs ambiguas: mismo nombre en español, distinta clase
local AMBIGUOUS_SPEC = {
    ["Sagrado"] = {
        PALADIN     = "PALADIN_HOLY",
        PRIEST      = "PRIEST_HOLY",
    },
    ["Restauración"] = {
        SHAMAN      = "SHAMAN_RESTO",
        DRUID       = "DRUID_RESTO",
    },
    ["Escarcha"] = {
        DEATHKNIGHT = "DK_FROST",
        MAGE        = "MAGE_FROST",
    },
    ["Protección"] = {
        WARRIOR     = "WARRIOR_PROT",
        PALADIN     = "PALADIN_PROT",
    },
}

-- Resuelve el nombre de talento a clave de spec, usando la clase si es ambiguo
local function ResolveSpec(talentName, botClass)
    local ambig = AMBIGUOUS_SPEC[talentName]
    if ambig then
        if botClass then
            local classKey = botClass:upper():gsub(" ", "")
            if ambig[classKey] then return ambig[classKey] end
        end
        -- Sin clase conocida, devolver el primero
        for _, v in pairs(ambig) do return v end
    end
    return TALENT_NAME_TO_SPEC[talentName]
end

local REAL_STAT_KEYS = {
    "entry", "role",
    "maxhealth", "maxpower",
    "strength", "agility", "stamina", "intellect", "spirit",
    "armor", "defense",
    "resHoly", "resFire", "resNature", "resFrost", "resShadow", "resArcane",
    "blockPct", "dodgePct", "parryPct", "critPct",
    "attackPower", "spellPower", "spellPen",
    "hastePct", "hitBonusPct", "expertise", "armorPenPct",
}

local function OnAddonLoaded(addonName)
    if addonName ~= "NPCBotInventory" then return end

    NBI.playerName = UnitName("player")

    BotInventoryDB = BotInventoryDB or {}
    BotInventoryDB[NBI.playerName] = BotInventoryDB[NBI.playerName] or {}
    for botName, inventory in pairs(BotInventoryDB[NBI.playerName]) do
        NBI.botInventories[botName] = inventory
    end

    NBIStatsDB = NBIStatsDB or {}
    NBIStatsDB[NBI.playerName] = NBIStatsDB[NBI.playerName] or {}
    for botName, stats in pairs(NBIStatsDB[NBI.playerName]) do
        NBI.botStats[botName] = stats
    end

    NBIRealStatsDB = NBIRealStatsDB or {}
    NBIRealStatsDB[NBI.playerName] = NBIRealStatsDB[NBI.playerName] or {}
    for botEntry, stats in pairs(NBIRealStatsDB[NBI.playerName]) do
        NBI.botRealStats[botEntry] = stats
        if stats.role then NBI.botRoles[botEntry] = stats.role end
        if stats.name then NBI.botEntryByName[stats.name] = botEntry end
        if stats.class then NBI.botClasses[botEntry] = stats.class end
    end

    if NBI.OnDataLoaded then NBI.OnDataLoaded() end
end

local function OnChatMessage(self, event, message, sender, ...)
    if event ~= "CHAT_MSG_MONSTER_WHISPER" then return end

    local currentTime = GetTime()

    if (currentTime - NBI.lastCallTime) >= 2 then
        NBI.botInventories[sender] = {}
        NBI.botStats[sender]       = ""
    end

    local guid = select(10, ...) 
    if guid and type(guid) == "string" then
        local high = string.sub(guid, 1, 5)
        if high == "0xF13" or high == "0xF15" then
            local entry = tonumber(string.sub(guid, 7, 12), 16)
            if entry then
                NBI.botEntryByName[sender] = entry
            end
        end
    end

    local key, val = message:match("^([%a][%a%s]-)%s*[:%s]%s*([%d%.]+%%?)%s*$")
    if key and val then
        NBI.botStats[sender] = (NBI.botStats[sender] or "") .. key .. ": " .. val .. "\n"
        NBIStatsDB[NBI.playerName] = NBIStatsDB[NBI.playerName] or {}
        NBIStatsDB[NBI.playerName][sender] = NBI.botStats[sender]
        NBI.lastCallTime = currentTime
        return
    end

    -- Detectar whisper de cambio de talento: "Cambiando mi talento a X"
    local talentName = message:match("^Cambiando mi talento a%s+(.+)$")
    if talentName then
        talentName = talentName:gsub("%s+$", "")
        local entry    = NBI.botEntryByName[sender]
        local botClass = entry and NBI.botClasses[entry]
        local spec     = ResolveSpec(talentName, botClass)
        if spec then
            -- Guardar siempre por nombre (no depende del entry)
            NBI.botRolesByName = NBI.botRolesByName or {}
            NBI.botRolesByName[sender] = spec
            -- Guardar también por entry si ya lo tenemos
            if entry then
                NBI.botRoles[entry] = spec
                if NBIRealStatsDB and NBIRealStatsDB[NBI.playerName] and NBIRealStatsDB[NBI.playerName][entry] then
                    NBIRealStatsDB[NBI.playerName][entry].role = spec
                end
            end
            if NBI.OnSpecUpdated then NBI.OnSpecUpdated(sender) end
        end
        NBI.lastCallTime = currentTime
        return
    end

    local link = string.match(message, "|H(.*)|h%[(.-)%]|h")
    if link then
        NBI.botInventories[sender] = NBI.botInventories[sender] or {}
        table.insert(NBI.botInventories[sender], link)
        BotInventoryDB[NBI.playerName] = BotInventoryDB[NBI.playerName] or {}
        BotInventoryDB[NBI.playerName][sender] = NBI.botInventories[sender]
        if NBI.OnBotDataUpdated then NBI.OnBotDataUpdated(sender) end
    end

    NBI.lastCallTime = currentTime
end

local function OnAddonMessage(self, event, prefix, msg, channel, sender)
    if prefix ~= BSTATS_PREFIX then return end

    if msg == "END" then
        if NBI.OnRealStatsUpdated then NBI.OnRealStatsUpdated() end
        return
    end

    if msg == "NOBOT" or msg == "NOSTATS" then return end

    local cmd = msg:match("^(%a+);")
    if cmd ~= "STAT" then return end

    local values = {}
    for v in msg:gmatch("[^;]+") do table.insert(values, v) end
    if #values < 3 then return end

    local entry = tonumber(values[2])
    if not entry then return end

    local role = values[3] or "DPS"
    NBI.botRoles[entry] = role

    local stats = { role = role }
    for i = 3, #REAL_STAT_KEYS do
        local key = REAL_STAT_KEYS[i]
        local raw = values[i + 1]
        stats[key] = tonumber(raw) or 0
    end

    local botClass = values[30]
    local botName = values[31]

    if botClass and botClass ~= "UNKNOWN" then
        NBI.botClasses[entry] = botClass
        stats.class = botClass
    end

    if botName then
        NBI.botEntryByName[botName] = entry
        stats.name = botName
    end

    NBI.botRealStats[entry] = stats

    NBIRealStatsDB = NBIRealStatsDB or {}
    NBIRealStatsDB[NBI.playerName] = NBIRealStatsDB[NBI.playerName] or {}
    NBIRealStatsDB[NBI.playerName][entry] = stats
end

function NBI.RequestRealStats()
    if IsLoggedIn() then
        SendAddonMessage(BSTATS_PREFIX, "REQUEST", "WHISPER", UnitName("player"))
    end
end

function NBI.ClearAll()
    if BotInventoryDB[NBI.playerName] then wipe(BotInventoryDB[NBI.playerName]) end
    if NBIStatsDB[NBI.playerName] then wipe(NBIStatsDB[NBI.playerName]) end
    if NBIRealStatsDB and NBIRealStatsDB[NBI.playerName] then wipe(NBIRealStatsDB[NBI.playerName]) end
    
    wipe(NBI.botInventories)
    wipe(NBI.botStats)
    wipe(NBI.botRealStats)
    wipe(NBI.botRoles)
    wipe(NBI.botClasses)
    wipe(NBI.botEntryByName)
    
    if NBI.OnDataCleared then NBI.OnDataCleared() end
    print("|cff00ff96[NPCBotInventory]|r Inventarios y stats borrados.")
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_MONSTER_WHISPER")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        OnAddonLoaded(...)
    elseif event == "CHAT_MSG_MONSTER_WHISPER" then
        OnChatMessage(self, event, ...)
    elseif event == "CHAT_MSG_ADDON" then
        OnAddonMessage(self, event, ...)
    end
end)