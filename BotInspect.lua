-- ============================================================
-- NPCBotInventory - BotInspect.lua
-- Ventana paperdoll unificada: slots automáticos + stats integradas
-- Compatible con WotLK 3.3.5
-- Autor: Lleguito | Version: 7.0 (Multiidioma ES/EN)
-- ============================================================

local NBI = NPCBotInventory

-- ============================================================
-- SISTEMA DE IDIOMAS
-- ============================================================
local LANG = "ES"  -- idioma activo, se sobreescribe desde SavedVariables

local L = {
    ES = {
        -- Encabezado
        title        = "NPCBot Inventory Inspector",
        noSpec       = "Sin Spec",
        credits      = "Creado por Lleguito",
        -- Botón stats
        recalc       = "Recalcular Stats",
        statsTitle   = "Stats de equipo",
        -- Slots
        Head         = "Cabeza",
        Neck         = "Cuello",
        Shoulder     = "Hombros",
        Back         = "Espalda",
        Chest        = "Pecho",
        Shirt        = "Camisa",
        Tabard       = "Tabardo",
        Wrist        = "Muñeca",
        Hands        = "Manos",
        Waist        = "Cintura",
        Legs         = "Piernas",
        Feet         = "Pies",
        ["Ring 1"]   = "Anillo 1",
        ["Ring 2"]   = "Anillo 2",
        ["Trinket 1"]= "Trinket 1",
        ["Trinket 2"]= "Trinket 2",
        ["Main Hand"]= "Mano Ppal.",
        ["Off Hand"] = "Mano Sec.",
        Ranged       = "A Distancia",
        -- Secciones de stats
        sec_Attributes  = "Atributos",
        sec_Attack      = "Ataque",
        sec_Defense     = "Defensa",
        sec_Various     = "Varios",
        sec_Resistances = "Resistencias",
        -- Stats
        strength        = "Fuerza",
        agility         = "Agilidad",
        stamina         = "Aguante",
        intellect       = "Intelecto",
        spirit          = "Espíritu",
        attackPower     = "Poder Ataque",
        spellPower      = "Poder Hechizo",
        spellPen        = "Pen. Hechizo",
        critRating      = "Crítico",
        hasteRating     = "Celeridad",
        hitRating       = "Golpe",
        expertiseRating = "Pericia",
        armorPenRating  = "Pen. Armadura",
        armor           = "Armadura",
        defenseRating   = "Defensa",
        dodgeRating     = "Esquive",
        parryRating     = "Parada",
        blockRating     = "Bloqueo",
        blockValue      = "Valor Bloqueo",
        resilience      = "Resiliencia",
        mp5             = "Maná/5s",
        hp5             = "Vida/5s",
        resHoly         = "Sagrado",
        resFire         = "Fuego",
        resNature       = "Naturaleza",
        resFrost        = "Escarcha",
        resShadow       = "Sombras",
        resArcane       = "Arcano",
        -- Roles
        role_MeleeDPS   = "Daño C-C",
        role_Tank       = "Tanque",
        role_Healer     = "Sanador",
        role_Range      = "Rango",
        role_Feral      = "Feral",
    },
    EN = {
        title        = "NPCBot Inventory Inspector",
        noSpec       = "No Spec",
        credits      = "Created by Lleguito",
        recalc       = "Recalculate Stats",
        statsTitle   = "Equipment Stats",
        Head         = "Head",
        Neck         = "Neck",
        Shoulder     = "Shoulder",
        Back         = "Back",
        Chest        = "Chest",
        Shirt        = "Shirt",
        Tabard       = "Tabard",
        Wrist        = "Wrist",
        Hands        = "Hands",
        Waist        = "Waist",
        Legs         = "Legs",
        Feet         = "Feet",
        ["Ring 1"]   = "Ring 1",
        ["Ring 2"]   = "Ring 2",
        ["Trinket 1"]= "Trinket 1",
        ["Trinket 2"]= "Trinket 2",
        ["Main Hand"]= "Main Hand",
        ["Off Hand"] = "Off Hand",
        Ranged       = "Ranged",
        sec_Attributes  = "Attributes",
        sec_Attack      = "Attack",
        sec_Defense     = "Defense",
        sec_Various     = "Various",
        sec_Resistances = "Resistances",
        strength        = "Strength",
        agility         = "Agility",
        stamina         = "Stamina",
        intellect       = "Intellect",
        spirit          = "Spirit",
        attackPower     = "Attack Power",
        spellPower      = "Spell Power",
        spellPen        = "Spell Pen.",
        critRating      = "Crit Rating",
        hasteRating     = "Haste Rating",
        hitRating       = "Hit Rating",
        expertiseRating = "Expertise",
        armorPenRating  = "Armor Pen.",
        armor           = "Armor",
        defenseRating   = "Defense",
        dodgeRating     = "Dodge Rating",
        parryRating     = "Parry Rating",
        blockRating     = "Block Rating",
        blockValue      = "Block Value",
        resilience      = "Resilience",
        mp5             = "Mana/5s",
        hp5             = "Health/5s",
        resHoly         = "Holy",
        resFire         = "Fire",
        resNature       = "Nature",
        resFrost        = "Frost",
        resShadow       = "Shadow",
        resArcane       = "Arcane",
        role_MeleeDPS   = "Melee DPS",
        role_Tank       = "Tank",
        role_Healer     = "Healer",
        role_Range      = "Ranged",
        role_Feral      = "Feral",
    },
}

local function T(key)
    return (L[LANG] and L[LANG][key]) or (L["ES"][key]) or key
end

-- ============================================================
-- SPEC INFO (roles internos, traducidos al mostrar)
-- ============================================================
local SPEC_INFO = {
    WARRIOR_ARMS   = { name_ES="Armas",         name_EN="Arms",         role="role_MeleeDPS", color={0.9,0.2,0.2}, icon="Interface\\Icons\\Ability_Warrior_Savageblow"        },
    WARRIOR_FURY   = { name_ES="Furia",         name_EN="Fury",         role="role_MeleeDPS", color={0.9,0.2,0.2}, icon="Interface\\Icons\\Ability_Warrior_Innerrage"          },
    WARRIOR_PROT   = { name_ES="Protección",    name_EN="Protection",   role="role_Tank",     color={0.4,0.7,1.0}, icon="Interface\\Icons\\Ability_Warrior_Defensivestance"    },
    PALADIN_HOLY   = { name_ES="Sagrado",        name_EN="Holy",         role="role_Healer",   color={0.2,0.9,0.4}, icon="Interface\\Icons\\Spell_Holy_HolyBolt"               },
    PALADIN_PROT   = { name_ES="Protección",    name_EN="Protection",   role="role_Tank",     color={0.4,0.7,1.0}, icon="Interface\\Icons\\Ability_Paladin_ShieldoftheTemplar" },
    PALADIN_RET    = { name_ES="Reprensión",    name_EN="Retribution",  role="role_MeleeDPS", color={0.9,0.2,0.2}, icon="Interface\\Icons\\Spell_Holy_AuraofLight"             },
    HUNTER_BM      = { name_ES="Bestias",       name_EN="Beast Mastery",role="role_Range",    color={1.0,0.6,0.1}, icon="Interface\\Icons\\Ability_Hunter_BeastMastery"        },
    HUNTER_MM      = { name_ES="Puntería",      name_EN="Marksmanship", role="role_Range",    color={1.0,0.6,0.1}, icon="Interface\\Icons\\Ability_Marksmanship"               },
    HUNTER_SURV    = { name_ES="Supervivencia", name_EN="Survival",     role="role_Range",    color={1.0,0.6,0.1}, icon="Interface\\Icons\\Ability_Hunter_SwiftStrike"         },
    ROGUE_ASS      = { name_ES="Asesinato",     name_EN="Assassination",role="role_MeleeDPS", color={0.9,0.2,0.2}, icon="Interface\\Icons\\Ability_Rogue_Eviscerate"           },
    ROGUE_COMBAT   = { name_ES="Combate",       name_EN="Combat",       role="role_MeleeDPS", color={0.9,0.2,0.2}, icon="Interface\\Icons\\Ability_BackStab"                   },
    ROGUE_SUB      = { name_ES="Sutileza",      name_EN="Subtlety",     role="role_MeleeDPS", color={0.9,0.2,0.2}, icon="Interface\\Icons\\Ability_Stealth"                    },
    PRIEST_DISC    = { name_ES="Disciplina",    name_EN="Discipline",   role="role_Healer",   color={0.2,0.9,0.4}, icon="Interface\\Icons\\Spell_Holy_PowerWordShield"         },
    PRIEST_HOLY    = { name_ES="Sagrado",        name_EN="Holy",         role="role_Healer",   color={0.2,0.9,0.4}, icon="Interface\\Icons\\Spell_Holy_GuardianSpirit"          },
    PRIEST_SHADOW  = { name_ES="Sombra",        name_EN="Shadow",       role="role_Range",    color={1.0,0.6,0.1}, icon="Interface\\Icons\\Spell_Shadow_ShadowWordPain"        },
    DK_BLOOD       = { name_ES="Sangre",        name_EN="Blood",        role="role_Tank",     color={0.4,0.7,1.0}, icon="Interface\\Icons\\Spell_DeathKnight_BloodPresence"    },
    DK_FROST       = { name_ES="Escarcha",      name_EN="Frost",        role="role_MeleeDPS", color={0.9,0.2,0.2}, icon="Interface\\Icons\\Spell_DeathKnight_FrostPresence"    },
    DK_UNHOLY      = { name_ES="Profano",       name_EN="Unholy",       role="role_MeleeDPS", color={0.9,0.2,0.2}, icon="Interface\\Icons\\Spell_DeathKnight_UnholyPresence"   },
    SHAMAN_ELEM    = { name_ES="Elemental",     name_EN="Elemental",    role="role_Range",    color={1.0,0.6,0.1}, icon="Interface\\Icons\\Spell_Nature_Lightning"             },
    SHAMAN_ENH     = { name_ES="Mejora",        name_EN="Enhancement",  role="role_MeleeDPS", color={0.9,0.2,0.2}, icon="Interface\\Icons\\Spell_Nature_ShamanRage"            },
    SHAMAN_RESTO   = { name_ES="Restauración",  name_EN="Restoration",  role="role_Healer",   color={0.2,0.9,0.4}, icon="Interface\\Icons\\Spell_Nature_MagicImmunity"         },
    MAGE_ARCANE    = { name_ES="Arcano",        name_EN="Arcane",       role="role_Range",    color={1.0,0.6,0.1}, icon="Interface\\Icons\\Spell_Holy_MagicalSentry"           },
    MAGE_FIRE      = { name_ES="Fuego",         name_EN="Fire",         role="role_Range",    color={1.0,0.6,0.1}, icon="Interface\\Icons\\Spell_Fire_FireBolt02"              },
    MAGE_FROST     = { name_ES="Escarcha",      name_EN="Frost",        role="role_Range",    color={1.0,0.6,0.1}, icon="Interface\\Icons\\Spell_Frost_FrostBolt02"            },
    WARLOCK_AFF    = { name_ES="Aflicción",     name_EN="Affliction",   role="role_Range",    color={1.0,0.6,0.1}, icon="Interface\\Icons\\Spell_Shadow_DeathCoil"             },
    WARLOCK_DEMO   = { name_ES="Demonología",   name_EN="Demonology",   role="role_Range",    color={1.0,0.6,0.1}, icon="Interface\\Icons\\Spell_Shadow_Metamorphosis"         },
    WARLOCK_DESTRO = { name_ES="Destrucción",   name_EN="Destruction",  role="role_Range",    color={1.0,0.6,0.1}, icon="Interface\\Icons\\Spell_Shadow_RainofFire"            },
    DRUID_BALANCE  = { name_ES="Equilibrio",    name_EN="Balance",      role="role_Range",    color={1.0,0.6,0.1}, icon="Interface\\Icons\\Spell_Nature_StarFall"              },
    DRUID_FERAL    = { name_ES="Feral",         name_EN="Feral",        role="role_Feral",    color={0.9,0.5,0.1}, icon="Interface\\Icons\\Ability_Druid_CatForm"              },
    DRUID_RESTO    = { name_ES="Restauración",  name_EN="Restoration",  role="role_Healer",   color={0.2,0.9,0.4}, icon="Interface\\Icons\\Spell_Nature_HealingTouch"          },
}

-- Devuelve: texto con color, color, string de icono |T...|t listo para concatenar
local function GetSpecText(spec)
    local info = spec and SPEC_INFO[spec]
    if not info then return T("noSpec"), {0.53,0.53,0.53}, "" end
    local nameKey  = LANG == "EN" and "name_EN" or "name_ES"
    local label    = info[nameKey] .. " (" .. T(info.role) .. ")"
    local iconStr  = info.icon and ("|T"..info.icon..":16:16:0:0|t") or ""
    return label, info.color, iconStr
end

-- ============================================================
-- EQUIP SLOT MAP
-- ============================================================
local EQUIP_SLOT_MAP = {
    INVTYPE_HEAD           = "Head",
    INVTYPE_NECK           = "Neck",
    INVTYPE_SHOULDER       = "Shoulder",
    INVTYPE_CLOAK          = "Back",
    INVTYPE_CHEST          = "Chest",
    INVTYPE_ROBE           = "Chest",
    INVTYPE_BODY           = "Shirt",
    INVTYPE_TABARD         = "Tabard",
    INVTYPE_WRIST          = "Wrist",
    INVTYPE_HAND           = "Hands",
    INVTYPE_WAIST          = "Waist",
    INVTYPE_LEGS           = "Legs",
    INVTYPE_FEET           = "Feet",
    INVTYPE_FINGER         = "Finger1",
    INVTYPE_TRINKET        = "Trinket1",
    INVTYPE_WEAPON         = "MainHand",
    INVTYPE_2HWEAPON       = "MainHand",
    INVTYPE_WEAPONMAINHAND = "MainHand",
    INVTYPE_WEAPONOFFHAND  = "OffHand",
    INVTYPE_SHIELD         = "OffHand",
    INVTYPE_HOLDABLE       = "OffHand",
    INVTYPE_RANGED         = "Ranged",
    INVTYPE_RANGEDRIGHT    = "Ranged",
    INVTYPE_THROWN         = "Ranged",
    INVTYPE_RELIC          = "Ranged",
}

-- Clave interna → clave de traducción
local SLOT_LABEL_KEY = {
    Head     = "Head",
    Neck     = "Neck",
    Shoulder = "Shoulder",
    Back     = "Back",
    Chest    = "Chest",
    Shirt    = "Shirt",
    Tabard   = "Tabard",
    Wrist    = "Wrist",
    Hands    = "Hands",
    Waist    = "Waist",
    Legs     = "Legs",
    Feet     = "Feet",
    Finger1  = "Ring 1",
    Finger2  = "Ring 2",
    Trinket1 = "Trinket 1",
    Trinket2 = "Trinket 2",
    MainHand = "Main Hand",
    OffHand  = "Off Hand",
    Ranged   = "Ranged",
}

local SLOT_LAYOUT = {
    { name = "Head",     x = -120, y =  145 },
    { name = "Neck",     x = -120, y =   98 },
    { name = "Shoulder", x = -120, y =   51 },
    { name = "Back",     x = -120, y =    4 },
    { name = "Chest",    x = -120, y =  -43 },
    { name = "Shirt",    x = -120, y =  -90 },
    { name = "Tabard",   x = -120, y = -137 },
    { name = "Wrist",    x = -120, y = -184 },
    { name = "Hands",    x =  106, y =  145 },
    { name = "Waist",    x =  106, y =   98 },
    { name = "Legs",     x =  106, y =   51 },
    { name = "Feet",     x =  106, y =    4 },
    { name = "Finger1",  x =  106, y =  -43 },
    { name = "Finger2",  x =  106, y =  -90 },
    { name = "Trinket1", x =  106, y = -137 },
    { name = "Trinket2", x =  106, y = -184 },
    { name = "MainHand", x = -120, y = -231 },
    { name = "OffHand",  x =  106, y = -231 },
    { name = "Ranged",   x =    3, y = -231 },
}

local SLOT_SZ = 37
local WIN_W   = 660
local WIN_H   = 620

local QUALITY_COLOR = {
    [0] = {0.62,0.62,0.62}, [1] = {1,1,1},
    [2] = {0.12,1,0},       [3] = {0,0.44,0.87},
    [4] = {0.64,0.21,0.93}, [5] = {1,0.5,0},
}

-- ============================================================
-- ITEM STAT MAP
-- ============================================================
local ITEM_STAT_MAP = {
    ITEM_MOD_STRENGTH_SHORT              = "strength",
    ITEM_MOD_AGILITY_SHORT               = "agility",
    ITEM_MOD_STAMINA_SHORT               = "stamina",
    ITEM_MOD_INTELLECT_SHORT             = "intellect",
    ITEM_MOD_SPIRIT_SHORT                = "spirit",
    ITEM_MOD_ARMOR                       = "armor",
    ITEM_MOD_ATTACK_POWER_SHORT          = "attackPower",
    ITEM_MOD_RANGED_ATTACK_POWER_SHORT   = "attackPower",
    ITEM_MOD_SPELL_POWER_SHORT           = "spellPower",
    ITEM_MOD_SPELL_PENETRATION_SHORT     = "spellPen",
    ITEM_MOD_CRIT_RATING_SHORT           = "critRating",
    ITEM_MOD_HASTE_RATING_SHORT          = "hasteRating",
    ITEM_MOD_HIT_RATING_SHORT            = "hitRating",
    ITEM_MOD_EXPERTISE_RATING_SHORT      = "expertiseRating",
    ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT = "armorPenRating",
    ITEM_MOD_DODGE_RATING_SHORT          = "dodgeRating",
    ITEM_MOD_PARRY_RATING_SHORT          = "parryRating",
    ITEM_MOD_BLOCK_RATING_SHORT          = "blockRating",
    ITEM_MOD_BLOCK_VALUE_SHORT           = "blockValue",
    ITEM_MOD_DEFENSE_SKILL_RATING_SHORT  = "defenseRating",
    ITEM_MOD_RESILIENCE_RATING_SHORT     = "resilience",
    ITEM_MOD_MANA_REGENERATION_SHORT     = "mp5",
    ITEM_MOD_HEALTH_REGEN                = "hp5",
    RESISTANCE0_NAME                     = "armor",
    RESISTANCE1_NAME                     = "resHoly",
    RESISTANCE2_NAME                     = "resFire",
    RESISTANCE3_NAME                     = "resNature",
    RESISTANCE4_NAME                     = "resFrost",
    RESISTANCE5_NAME                     = "resShadow",
    RESISTANCE6_NAME                     = "resArcane",
}

-- ============================================================
-- GEARSCORE
-- ============================================================
local GS_SLOT_WEIGHT = {
    INVTYPE_HEAD=1, INVTYPE_NECK=0.5625, INVTYPE_SHOULDER=0.75,
    INVTYPE_CLOAK=0.5625, INVTYPE_CHEST=1, INVTYPE_ROBE=1,
    INVTYPE_WRIST=0.5625, INVTYPE_HAND=0.75, INVTYPE_WAIST=0.75,
    INVTYPE_LEGS=1, INVTYPE_FEET=0.75, INVTYPE_FINGER=0.5625,
    INVTYPE_TRINKET=0.5625, INVTYPE_WEAPON=1, INVTYPE_2HWEAPON=2,
    INVTYPE_WEAPONMAINHAND=1, INVTYPE_WEAPONOFFHAND=1, INVTYPE_SHIELD=1,
    INVTYPE_HOLDABLE=0.5625, INVTYPE_RANGED=0.5625, INVTYPE_RANGEDRIGHT=0.5625,
    INVTYPE_THROWN=0.5625, INVTYPE_RELIC=0.5625, INVTYPE_BODY=0, INVTYPE_TABARD=0,
}
local GS_QUALITY_FACTOR = {[0]=0,[1]=0,[2]=0.3333,[3]=0.6667,[4]=1,[5]=1,[6]=0,[7]=0}

local function ComputeGearScore(inventory)
    if not inventory then return 0 end
    local total = 0
    for _, link in ipairs(inventory) do
        local _, _, quality, itemLevel, _, _, _, _, equipSlot = GetItemInfo(link)
        if itemLevel and quality and equipSlot and equipSlot ~= "" then
            total = total + (itemLevel * (GS_QUALITY_FACTOR[quality] or 0) * (GS_SLOT_WEIGHT[equipSlot] or 0) * 1.8618)
        end
    end
    return math.floor(total)
end

local function ComputeStatsFromInventory(inventory)
    local stats = {}
    if not inventory then return stats end
    for _, link in ipairs(inventory) do
        local itemStats = {}
        GetItemStats(link, itemStats)
        for statKey, value in pairs(itemStats) do
            local mapped = ITEM_STAT_MAP[statKey]
            if mapped then stats[mapped] = (stats[mapped] or 0) + value end
        end
    end
    return stats
end

-- ============================================================
-- STAT DISPLAY (secciones y claves, labels vienen de T())
-- ============================================================
local STAT_DISPLAY = {
    { section = "sec_Attributes" },
    { key="strength",       color={1,0.82,0}    },
    { key="agility",        color={1,0.82,0}    },
    { key="stamina",        color={1,0.82,0}    },
    { key="intellect",      color={1,0.82,0}    },
    { key="spirit",         color={1,0.82,0}    },
    { section = "sec_Attack" },
    { key="attackPower",    color={0.9,0.5,0.1} },
    { key="spellPower",     color={0.5,0.5,1}   },
    { key="spellPen",       color={0.5,0.5,1}   },
    { key="critRating",     color={0.2,0.9,0.4} },
    { key="hasteRating",    color={0.2,0.9,0.4} },
    { key="hitRating",      color={0.2,0.9,0.4} },
    { key="expertiseRating",color={0.2,0.9,0.4} },
    { key="armorPenRating", color={0.8,0.8,0.8} },
    { section = "sec_Defense" },
    { key="armor",          color={0.6,0.6,0.8} },
    { key="defenseRating",  color={0.4,0.7,1}   },
    { key="dodgeRating",    color={0.4,0.7,1}   },
    { key="parryRating",    color={0.4,0.7,1}   },
    { key="blockRating",    color={0.4,0.7,1}   },
    { key="blockValue",     color={0.4,0.7,1}   },
    { section = "sec_Various" },
    { key="resilience",     color={0.8,0.6,1}   },
    { key="mp5",            color={0.3,0.6,1}   },
    { key="hp5",            color={0.3,1,0.3}   },
    { section = "sec_Resistances" },
    { key="resHoly",        color={1,1,0.6}     },
    { key="resFire",        color={1,0.4,0.1}   },
    { key="resNature",      color={0.3,0.9,0.2} },
    { key="resFrost",       color={0.5,0.8,1}   },
    { key="resShadow",      color={0.7,0.3,0.9} },
    { key="resArcane",      color={0.9,0.3,0.9} },
}

-- ============================================================
-- UI HELPERS
-- ============================================================
local function GoldBorder(frame)
    frame:SetBackdrop({
        bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true, tileSize=8, edgeSize=10,
        insets={left=2,right=2,top=2,bottom=2},
    })
    frame:SetBackdropColor(0.08,0.08,0.1,1)
    frame:SetBackdropBorderColor(0.5,0.42,0.1,1)
end

-- ============================================================
-- MARCO PRINCIPAL
-- ============================================================
local inspectFrame = CreateFrame("Frame","NBI_InspectFrame",UIParent)
inspectFrame:SetSize(WIN_W,WIN_H)
inspectFrame:SetPoint("CENTER")
inspectFrame:SetFrameStrata("DIALOG")
inspectFrame:SetMovable(true)
inspectFrame:EnableMouse(true)
inspectFrame:RegisterForDrag("LeftButton")
inspectFrame:SetScript("OnDragStart",inspectFrame.StartMoving)
inspectFrame:SetScript("OnDragStop", inspectFrame.StopMovingOrSizing)
inspectFrame:SetBackdrop({
    bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
    tile=true,tileSize=32,edgeSize=32,
    insets={left=8,right=8,top=8,bottom=8},
})
inspectFrame:SetBackdropColor(0.05,0.05,0.08,0.98)
inspectFrame:SetBackdropBorderColor(0.4,0.35,0.1,1)
inspectFrame:Hide()

local paperdollFrame = CreateFrame("Frame",nil,inspectFrame)
paperdollFrame:SetSize(420,620)
paperdollFrame:SetPoint("TOPLEFT",inspectFrame,"TOPLEFT",0,0)

-- Encabezado
local inspectHeader = CreateFrame("Frame",nil,inspectFrame)
inspectHeader:SetPoint("TOPLEFT", inspectFrame,"TOPLEFT", 0,0)
inspectHeader:SetPoint("TOPRIGHT",inspectFrame,"TOPRIGHT",0,0)
inspectHeader:SetHeight(52)
inspectHeader:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background"})
inspectHeader:SetBackdropColor(0.08,0.07,0.03,1)

local classIcon = inspectHeader:CreateTexture(nil,"OVERLAY")
classIcon:SetSize(36,36)
classIcon:SetPoint("TOPLEFT",inspectHeader,"TOPLEFT",12,-8)
classIcon:Hide()

local inspectTitle = inspectHeader:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
inspectTitle:SetPoint("TOPLEFT",inspectHeader,"TOPLEFT",56,-8)
inspectTitle:SetTextColor(1,0.82,0,1)
inspectTitle:SetText(T("title"))

local inspectSubTitle = inspectHeader:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
inspectSubTitle:SetPoint("TOPLEFT",inspectTitle,"BOTTOMLEFT",0,-2)
inspectSubTitle:SetTextColor(0.8,0.8,0.8,1)
inspectSubTitle:SetText("")

local sep = inspectFrame:CreateTexture(nil,"ARTWORK")
sep:SetHeight(1)
sep:SetPoint("TOPLEFT", inspectFrame,"TOPLEFT", 10,-52)
sep:SetPoint("TOPRIGHT",inspectFrame,"TOPRIGHT",-10,-52)
sep:SetTexture(0.5,0.42,0.1,0.6)

local inspectClose = CreateFrame("Button",nil,inspectFrame,"UIPanelCloseButton")
inspectClose:SetPoint("TOPRIGHT",inspectFrame,"TOPRIGHT",2,2)
inspectClose:SetScript("OnClick",function() inspectFrame:Hide() end)

local creditsLabel = inspectFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
creditsLabel:SetPoint("BOTTOM",inspectFrame,"BOTTOM",0,8)
creditsLabel:SetTextColor(0.4,0.4,0.4,1)
creditsLabel:SetText(T("credits"))

-- ============================================================
-- DESPLEGABLE DE IDIOMA (esquina superior derecha del header)
-- ============================================================
local langBtn = CreateFrame("Button",nil,inspectHeader,"UIPanelButtonTemplate")
langBtn:SetSize(60,20)
langBtn:SetPoint("TOPRIGHT",inspectHeader,"TOPRIGHT",-36,-16)
langBtn:SetText(LANG == "ES" and "ES | EN" or "EN | ES")

local function ApplyLanguage()
    -- Actualizar botón
    langBtn:SetText(LANG == "ES" and "ES | EN" or "EN | ES")
    -- Título y créditos
    inspectTitle:SetText(T("title"))
    creditsLabel:SetText(T("credits"))
    -- Labels de slots
    for _, sf in pairs(inspectFrame.slotFrames or {}) do
        local labelKey = SLOT_LABEL_KEY[sf.slotName]
        if labelKey then sf.slotLabel:SetText(T(labelKey)) end
    end
    -- Botón recalcular y título del panel stats
    if statsRefreshBtn then statsRefreshBtn:SetText(T("recalc")) end
    if statsHeaderLabel then statsHeaderLabel:SetText(T("statsTitle")) end
    -- Repintar stats si hay bot activo
    if statsWin and statsWin.currentBot then
        local inv = NBI.botInventories[statsWin.currentBot]
        PopulateStatsWindow(statsWin.currentBot, ComputeStatsFromInventory(inv))
    end
    -- Repintar subtítulo si hay bot activo
    if inspectFrame.currentBot then
        local botName = inspectFrame.currentBot
        local entry   = NBI.botEntryByName and NBI.botEntryByName[botName]
        local spec    = (entry and NBI.botRoles and NBI.botRoles[entry])
                     or (NBI.botRolesByName and NBI.botRolesByName[botName])
        local specLabel, specColor, specIcon = GetSpecText(spec)
        local roleText = specIcon..string.format("|cff%02x%02x%02x%s|r",
            specColor[1]*255, specColor[2]*255, specColor[3]*255, specLabel)
        local inventory = NBI.botInventories[botName]
        local gsVal  = ComputeGearScore(inventory)
        local gsText = gsVal > 0 and ("|cff33ff66GS: "..gsVal.."|r") or ""
        local parts  = {"|cffFFD700"..botName.."|r", roleText}
        if gsText ~= "" then table.insert(parts, gsText) end
        inspectSubTitle:SetText(table.concat(parts,"  |  "))
    end
    -- Guardar preferencia
    NBILangDB = LANG
end

langBtn:SetScript("OnClick",function()
    LANG = (LANG == "ES") and "EN" or "ES"
    ApplyLanguage()
end)

-- ============================================================
-- PORTRAIT
-- ============================================================
local centerBg = CreateFrame("Frame",nil,paperdollFrame)
centerBg:SetSize(150,330)
centerBg:SetPoint("CENTER",paperdollFrame,"CENTER",-7,-20)
centerBg:SetBackdrop({
    bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
    tile=true,tileSize=16,edgeSize=12,
    insets={left=3,right=3,top=3,bottom=3},
})
centerBg:SetBackdropColor(0.05,0.05,0.1,0.5)
centerBg:SetBackdropBorderColor(0.3,0.25,0.1,0.6)

local portraitModel = CreateFrame("PlayerModel","NBI_PortraitModel",centerBg)
portraitModel:SetSize(136,318)
portraitModel:SetPoint("TOP",centerBg,"TOP",0,-6)
portraitModel:SetBackdrop({
    bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
    tile=true,tileSize=8,edgeSize=8,
    insets={left=2,right=2,top=2,bottom=2},
})
portraitModel:SetBackdropColor(0.05,0.05,0.1,0.8)
portraitModel:SetBackdropBorderColor(0.4,0.35,0.1,0.8)

local portraitPlaceholder = centerBg:CreateTexture(nil,"ARTWORK")
portraitPlaceholder:SetSize(80,80)
portraitPlaceholder:SetPoint("CENTER",portraitModel,"CENTER",0,0)
portraitPlaceholder:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
portraitPlaceholder:SetAlpha(0.3)

local function FindBotUnitId(botName)
    for i=1,4 do
        local unit="party"..i
        if UnitExists(unit) then
            local name=UnitName(unit)
            if name and name==botName then
                local guid=UnitGUID(unit)
                if guid then
                    local high=string.sub(guid,1,5)
                    if high=="0xF13" or high=="0xF15" then
                        local entry=tonumber(string.sub(guid,7,12),16)
                        if entry then
                            NBI.botEntryByName[botName]=entry
                            local _,botClass=UnitClass(unit)
                            if botClass then NBI.botClasses[entry]=botClass end
                        end
                    end
                end
                return unit
            end
        end
    end
    if UnitName("player")==botName then return "player" end
    return nil
end

inspectFrame.portraitModel=portraitModel
inspectFrame.FindBotUnitId=FindBotUnitId
inspectFrame.slotFrames={}

-- ============================================================
-- SLOTS
-- ============================================================
for _,slotInfo in ipairs(SLOT_LAYOUT) do
    local sf=CreateFrame("Button","NBI_Slot_"..slotInfo.name,paperdollFrame)
    sf:SetSize(SLOT_SZ,SLOT_SZ)
    sf:SetPoint("CENTER",paperdollFrame,"CENTER",slotInfo.x,slotInfo.y-10)
    GoldBorder(sf)

    local icon=sf:CreateTexture(nil,"ARTWORK")
    icon:SetPoint("TOPLEFT",    sf,"TOPLEFT",    3,-3)
    icon:SetPoint("BOTTOMRIGHT",sf,"BOTTOMRIGHT",-3, 3)
    icon:SetTexCoord(0.08,0.92,0.08,0.92)
    icon:SetTexture("Interface\\PaperDollInfoFrame\\UI-PaperDoll-Slot-"..slotInfo.name)

    local qbar=sf:CreateTexture(nil,"OVERLAY")
    qbar:SetHeight(3)
    qbar:SetPoint("BOTTOMLEFT", sf,"BOTTOMLEFT", 2,1)
    qbar:SetPoint("BOTTOMRIGHT",sf,"BOTTOMRIGHT",-2,1)
    qbar:SetTexture(0.4,0.4,0.4,0)

    local labelKey = SLOT_LABEL_KEY[slotInfo.name]
    local lbl=paperdollFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    lbl:SetPoint("TOP",sf,"BOTTOM",0,-1)
    lbl:SetTextColor(0.45,0.45,0.45,1)
    lbl:SetText(T(labelKey))

    sf.icon=icon; sf.qbar=qbar; sf.slotLabel=lbl
    sf.link=nil;  sf.slotName=slotInfo.name

    sf:SetScript("OnEnter",function(self)
        if self.link then
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(self.link)
            GameTooltip:Show()
        end
    end)
    sf:SetScript("OnLeave",function() GameTooltip:Hide() end)
    inspectFrame.slotFrames[slotInfo.name]=sf
end

-- ============================================================
-- PANEL DE STATS
-- ============================================================
local STATS_WIN_W=220
local STATS_WIN_H=540

local statsWin=CreateFrame("Frame","NBI_StatsWindow",inspectFrame)
statsWin:SetSize(STATS_WIN_W,STATS_WIN_H)
statsWin:SetPoint("TOPRIGHT",inspectFrame,"TOPRIGHT",-12,-58)
GoldBorder(statsWin)

local statsRefreshBtn=CreateFrame("Button",nil,statsWin,"UIPanelButtonTemplate")
statsRefreshBtn:SetSize(STATS_WIN_W-24,22)
statsRefreshBtn:SetPoint("BOTTOM",statsWin,"BOTTOM",0,8)
statsRefreshBtn:SetText(T("recalc"))
statsRefreshBtn:SetScript("OnClick",function()
    if statsWin.currentBot then
        local inv=NBI.botInventories[statsWin.currentBot]
        PopulateStatsWindow(statsWin.currentBot,ComputeStatsFromInventory(inv))
    end
end)

local statsScroll=CreateFrame("ScrollFrame","NBI_StatsScroll",statsWin,"UIPanelScrollFrameTemplate")
statsScroll:SetPoint("TOPLEFT",    statsWin,"TOPLEFT",    8,-8)
statsScroll:SetPoint("BOTTOMRIGHT",statsWin,"BOTTOMRIGHT",-28,38)

local statsContent=CreateFrame("Frame",nil,statsScroll)
statsContent:SetSize(STATS_WIN_W-36,10)
statsScroll:SetScrollChild(statsContent)

local statsHeaderLabel=statsWin:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
statsHeaderLabel:SetPoint("TOP",statsWin,"TOP",0,-6)
statsHeaderLabel:SetTextColor(1,0.82,0,1)
statsHeaderLabel:SetText(T("statsTitle"))

local statRows={}
local function GetStatRow(index)
    if not statRows[index] then
        local row=CreateFrame("Frame",nil,statsContent)
        row:SetSize(STATS_WIN_W-36,16)
        row:SetPoint("TOPLEFT",statsContent,"TOPLEFT",2,-2-(index-1)*18)
        local keyLbl=row:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        keyLbl:SetPoint("LEFT",row,"LEFT",2,0)
        keyLbl:SetTextColor(0.75,0.75,0.75,1)
        keyLbl:SetJustifyH("LEFT")
        local valLbl=row:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        valLbl:SetPoint("RIGHT",row,"RIGHT",-2,0)
        valLbl:SetJustifyH("RIGHT")
        local secTex=row:CreateTexture(nil,"ARTWORK")
        secTex:SetHeight(1)
        secTex:SetPoint("TOPLEFT", row,"TOPLEFT", 0,0)
        secTex:SetPoint("TOPRIGHT",row,"TOPRIGHT",0,0)
        secTex:SetTexture(0.5,0.42,0.1,0.4)
        secTex:Hide()
        row.key=keyLbl; row.val=valLbl; row.secTex=secTex
        statRows[index]=row
    end
    return statRows[index]
end

function PopulateStatsWindow(botName,itemStats)
    statsWin.currentBot=botName
    for _,row in ipairs(statRows) do row:Hide(); row.secTex:Hide() end
    local rowIndex=1
    for _,entry in ipairs(STAT_DISPLAY) do
        if entry.section then
            local row=GetStatRow(rowIndex)
            row.key:SetText(T(entry.section))
            row.key:SetTextColor(1,0.82,0,1)
            row.val:SetText("")
            if rowIndex>1 then row.secTex:Show() end
            row:Show()
            rowIndex=rowIndex+1
        else
            local val=itemStats and itemStats[entry.key]
            if val and val~=0 then
                local row=GetStatRow(rowIndex)
                row.key:SetText(T(entry.key))
                row.key:SetTextColor(0.75,0.75,0.75,1)
                row.secTex:Hide()
                local c=entry.color
                row.val:SetText(tostring(math.floor(val)))
                row.val:SetTextColor(c[1],c[2],c[3])
                row:Show()
                rowIndex=rowIndex+1
            end
        end
    end
    statsContent:SetHeight(math.max((rowIndex-1)*18+4,10))
end

-- ============================================================
-- OPEN INSPECT
-- ============================================================
function NBI.OpenInspect(botName)
    local inventory=NBI.botInventories[botName]
    if not inventory then
        print("|cffFFD700[NPCBotInventory]|r No hay datos para: "..botName)
        return
    end

    inspectFrame.currentBot=botName
    local unitId=FindBotUnitId(botName)

    local entry=NBI.botEntryByName and NBI.botEntryByName[botName]
    local botClass=entry and NBI.botClasses[entry]
    if botClass and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[botClass] then
        classIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
        classIcon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[botClass]))
        classIcon:Show()
        inspectTitle:SetPoint("TOPLEFT",inspectHeader,"TOPLEFT",56,-8)
    else
        classIcon:Hide()
        inspectTitle:SetPoint("TOPLEFT",inspectHeader,"TOPLEFT",15,-8)
    end

    local spec = (entry and NBI.botRoles and NBI.botRoles[entry])
              or (NBI.botRolesByName and NBI.botRolesByName[botName])
    local specLabel, specColor, specIcon = GetSpecText(spec)
    local roleText = specIcon..string.format("|cff%02x%02x%02x%s|r",
        specColor[1]*255, specColor[2]*255, specColor[3]*255, specLabel)

    local gsVal  = ComputeGearScore(inventory)
    local gsText = gsVal>0 and ("|cff33ff66GS: "..gsVal.."|r") or ""

    local parts={"|cffFFD700"..botName.."|r", roleText}
    if gsText~="" then table.insert(parts,gsText) end
    inspectSubTitle:SetText(table.concat(parts,"  |  "))

    if unitId then
        portraitModel:SetUnit(unitId)
        portraitPlaceholder:SetAlpha(0)
    else
        portraitModel:ClearModel()
        portraitPlaceholder:SetAlpha(0.3)
    end

    for _,sf in pairs(inspectFrame.slotFrames) do
        sf.icon:SetTexture("Interface\\PaperDollInfoFrame\\UI-PaperDoll-Slot-"..sf.slotName)
        sf.icon:SetTexCoord(0,1,0,1)
        sf.qbar:SetTexture(0.4,0.4,0.4,0)
        sf.link=nil
        sf:SetBackdropBorderColor(0.5,0.42,0.1,1)
    end

    for _,link in ipairs(inventory) do
        local _,_,_,_,_,_,_,_,equipSlot,texture=GetItemInfo(link)
        if not equipSlot then
            local itemID=link:match("item:(%d+)")
            if itemID then GetItemInfo(tonumber(itemID)) end
        end
        if equipSlot and equipSlot~="" then
            local slotName=EQUIP_SLOT_MAP[equipSlot]
            if slotName=="Finger1" and inspectFrame.slotFrames["Finger1"].link then slotName="Finger2" end
            if slotName=="Trinket1" and inspectFrame.slotFrames["Trinket1"].link then slotName="Trinket2" end
            if slotName then
                local sf=inspectFrame.slotFrames[slotName]
                if sf and not sf.link then
                    if texture then sf.icon:SetTexture(texture); sf.icon:SetTexCoord(0.08,0.92,0.08,0.92) end
                    sf.link=link
                    local _,_,quality=GetItemInfo(link)
                    if quality and QUALITY_COLOR[quality] then
                        local qc=QUALITY_COLOR[quality]
                        sf:SetBackdropBorderColor(qc[1],qc[2],qc[3],1)
                        sf.qbar:SetTexture(qc[1],qc[2],qc[3],0.9)
                    end
                end
            end
        end
    end

    PopulateStatsWindow(botName, ComputeStatsFromInventory(inventory))
    if not statsWin:IsShown() then statsWin:Show() end
    inspectFrame:Show()
    inspectFrame:Raise()
end

-- ============================================================
-- LISTENER DE CAMBIO DE TALENTO (whisper del bot)
-- ============================================================
NBI.botRolesByName = NBI.botRolesByName or {}

local TALENT_TO_SPEC = {
    ["Armas"]="WARRIOR_ARMS", ["Furia"]="WARRIOR_FURY",
    ["Reprensión"]="PALADIN_RET",
    ["Bestias"]="HUNTER_BM", ["Puntería"]="HUNTER_MM", ["Supervivencia"]="HUNTER_SURV",
    ["Asesinato"]="ROGUE_ASS", ["Combate"]="ROGUE_COMBAT", ["Sutileza"]="ROGUE_SUB",
    ["Disciplina"]="PRIEST_DISC", ["Sombra"]="PRIEST_SHADOW",
    ["Sangre"]="DK_BLOOD", ["Profano"]="DK_UNHOLY",
    ["Elemental"]="SHAMAN_ELEM", ["Mejora"]="SHAMAN_ENH",
    ["Arcano"]="MAGE_ARCANE", ["Fuego"]="MAGE_FIRE",
    ["Aflicción"]="WARLOCK_AFF", ["Demonología"]="WARLOCK_DEMO", ["Destrucción"]="WARLOCK_DESTRO",
    ["Equilibrio"]="DRUID_BALANCE", ["Feral"]="DRUID_FERAL",
}
local AMBIGUOUS = {
    ["Protección"]   = {WARRIOR="WARRIOR_PROT", PALADIN="PALADIN_PROT"},
    ["Sagrado"]      = {PALADIN="PALADIN_HOLY",  PRIEST="PRIEST_HOLY"},
    ["Escarcha"]     = {DEATHKNIGHT="DK_FROST",  MAGE="MAGE_FROST"},
    ["Restauración"] = {SHAMAN="SHAMAN_RESTO",   DRUID="DRUID_RESTO"},
}

local talentFrame=CreateFrame("Frame","NBI_TalentListener")
talentFrame:RegisterEvent("CHAT_MSG_MONSTER_WHISPER")
talentFrame:SetScript("OnEvent",function(self,event,message,sender)
    local talentName=message:match("^Cambiando mi talento a%s+(.+)$")
    if not talentName then return end
    talentName=talentName:gsub("%s+$","")

    local spec
    local ambig=AMBIGUOUS[talentName]
    if ambig then
        local entry2=NBI.botEntryByName and NBI.botEntryByName[sender]
        local botClass2=entry2 and NBI.botClasses and NBI.botClasses[entry2]
        if botClass2 then
            spec=ambig[botClass2:upper():gsub(" ","")]
        end
        if not spec then for _,v in pairs(ambig) do spec=v break end end
    else
        spec=TALENT_TO_SPEC[talentName]
    end

    if spec then
        NBI.botRolesByName[sender]=spec
        local entry2=NBI.botEntryByName and NBI.botEntryByName[sender]
        if entry2 then NBI.botRoles[entry2]=spec end

        if inspectFrame:IsShown() and inspectFrame.currentBot==sender then
            local specLabel2,specColor2,specIcon2=GetSpecText(spec)
            local roleText2=specIcon2..string.format("|cff%02x%02x%02x%s|r",
                specColor2[1]*255,specColor2[2]*255,specColor2[3]*255,specLabel2)
            local inv2=NBI.botInventories[sender]
            local gsVal2=ComputeGearScore(inv2)
            local gsText2=gsVal2>0 and ("|cff33ff66GS: "..gsVal2.."|r") or ""
            local parts2={"|cffFFD700"..sender.."|r",roleText2}
            if gsText2~="" then table.insert(parts2,gsText2) end
            inspectSubTitle:SetText(table.concat(parts2,"  |  "))
        end
    end
end)

-- ============================================================
-- CARGAR IDIOMA GUARDADO
-- ============================================================
local langInitFrame=CreateFrame("Frame")
langInitFrame:RegisterEvent("ADDON_LOADED")
langInitFrame:SetScript("OnEvent",function(self,event,addon)
    if addon~="NPCBotInventory" then return end
    if NBILangDB and (NBILangDB=="ES" or NBILangDB=="EN") then
        LANG=NBILangDB
        ApplyLanguage()
    end
end)

-- ============================================================
-- SLASH
-- ============================================================
local origSlash=SlashCmdList["NBOTINV"]
SlashCmdList["NBOTINV"]=function(msg)
    msg=msg:trim()
    local botName=msg:match("^inspect%s+(.+)$")
    if botName then NBI.OpenInspect(botName); return end
    origSlash(msg)
end

print("|cffFFD700[NPCBotInventory]|r BotInspect cargado. /botinv inspect <nombre>")
