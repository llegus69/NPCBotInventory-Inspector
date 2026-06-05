# NPCBotInventory (NO LUA SERVER)

> Addon para **World of Warcraft 3.3.5 (WotLK)** que permite inspeccionar el inventario equipado de tus NPCBots con un paperdoll completo, estadísticas calculadas localmente y detección automática de especialización.

---

## 📋 Tabla de contenidos

- [Características](#-características)
- [Instalación](#-instalación)
- [Uso](#-uso)
- [Archivos del addon](#-archivos-del-addon)
- [Cómo funciona](#-cómo-funciona)
- [Comandos](#-comandos)
- [Variables guardadas](#-variables-guardadas)
- [Historial de versiones](#-historial-de-versiones)
- [Notas técnicas](#-notas-técnicas)

---

## ✨ Características

- **Paperdoll completo** con los 19 slots de equipo del bot (cabeza, cuello, hombros, pecho, manos, anillos, trinkets, armas, etc.)
- **Estadísticas calculadas localmente** sumando los stats de cada item equipado mediante `GetItemStats()` — sin depender de ningún servidor externo
- **GearScore automático** calculado con la fórmula estándar de WotLK (iLevel × factor de calidad × peso de slot × 1.8618)
- **Detección de especialización en tiempo real** — cuando el bot cambia de spec y te envía un susurro, el icono y nombre de spec se actualizan al momento
- **Icono de talento** junto al nombre de spec en el encabezado
- **Soporte multiidioma** Español / Inglés con un solo clic, preferencia guardada entre sesiones
- **Modelo 3D del bot** en el centro del paperdoll si el bot está en tu grupo
- **Colores de calidad** en los bordes de los slots (gris, blanco, verde, azul, épico, legendario)
- **Botón en el minimapa** arrastrable y configurable
- **Panel lateral** con lista de todos los bots con inventario registrado
- **Persistencia de datos** — los inventarios y preferencias se guardan entre sesiones con SavedVariables

---

## 📦 Instalación

1. Descarga o clona este repositorio
2. Copia la carpeta `NPCBotInventory` en tu directorio de addons:
   ```
   World of Warcraft/Interface/AddOns/NPCBotInventory/
   ```
3. Asegúrate de que el `.toc` incluye las SavedVariables necesarias:
   ```
   ## SavedVariables: BotInventoryDB NBIStatsDB NBIRealStatsDB NBIButtonPos NBILangDB
   ```
4. Activa el addon en la pantalla de selección de personaje
5. El servidor necesita tener **NPCBots** habilitado con el módulo de susurros activo

---

## 🎮 Uso

### Abrir el inventario de un bot

- Haz clic en el **botón del minimapa** (icono de pergamino) o en el botón flotante **"Bot Inventory"**
- Se abrirá el panel lateral con la lista de bots conocidos
- Haz clic en el **icono de pergamino** a la derecha del nombre del bot para abrir su paperdoll

### Solicitar el inventario al bot

Susurra al bot o usa el comando del servidor correspondiente para que te envíe su inventario. El addon captura automáticamente los susurros de tipo `CHAT_MSG_MONSTER_WHISPER` con item links y stats.

### Cambiar idioma

En la esquina superior derecha del paperdoll hay un botón **`ES | EN`**. Cada clic alterna entre español e inglés. El cambio afecta a todos los textos: slots, secciones de stats, nombres de stats, roles y especialización. La preferencia se guarda automáticamente.

### Especialización

El addon detecta el susurro que envía el bot al cambiar de spec:
```
[NombreBot]: Cambiando mi talento a Restauración
```
Al recibir este mensaje, el icono y nombre de spec se actualizan inmediatamente en el encabezado del paperdoll sin necesidad de reabrirlo.

---

## 📁 Archivos del addon

| Archivo | Descripción |
|---|---|
| `Core.lua` | Lógica de datos: captura susurros, guarda y carga inventarios, gestiona SavedVariables |
| `UI.lua` | Panel lateral de lista de bots y botón flotante / minimapa |
| `BotInspect.lua` | Ventana paperdoll completa: slots, modelo 3D, stats, GS, spec, idiomas |

---

## 🔧 Cómo funciona

### Captura de inventario

Cuando un bot envía su inventario por susurro, `Core.lua` escucha el evento `CHAT_MSG_MONSTER_WHISPER` y extrae los item links con:
```lua
local link = string.match(message, "|H(.*)|h%[(.-)%]|h")
```
Cada link se almacena en `NBI.botInventories[nombreBot]` y se persiste en `BotInventoryDB`.

### Cálculo de estadísticas

`BotInspect.lua` itera todos los item links del bot y usa la API nativa de WoW:
```lua
GetItemStats(link, itemStats)
```
Los resultados se mapean desde claves internas (`ITEM_MOD_STAMINA_SHORT`, `ITEM_MOD_CRIT_RATING_SHORT`, etc.) a claves propias del addon (`stamina`, `critRating`, etc.) y se suman. No se requiere comunicación con el servidor.

### Cálculo de GearScore

Se aplica la fórmula estándar del addon GearScore 3.x para WotLK:

```
GS = Σ (iLevel × factorCalidad × pesoSlot × 1.8618)
```

Factores de calidad: Poco común `0.3333` · Raro `0.6667` · Épico/Legendario `1.0`

Pesos de slot destacados: Cabeza/Pecho/Piernas `1.0` · Arma 2H `2.0` · Cuello/Anillos/Trinkets `0.5625` · Hombros/Manos/Cintura/Pies `0.75`

### Detección de especialización

`BotInspect.lua` registra su propio listener independiente de `Core.lua`:
```lua
talentFrame:RegisterEvent("CHAT_MSG_MONSTER_WHISPER")
```
Al detectar `"Cambiando mi talento a X"`, resuelve el nombre en español a la clave de spec interna (ej. `"Restauración"` → `SHAMAN_RESTO` o `DRUID_RESTO` dependiendo de la clase del bot). Las specs con nombre ambiguo se resuelven por clase usando `NBI.botClasses`.

### Sistema de idiomas

Todos los textos visibles están en la tabla `L` con dos entradas (`ES` y `EN`). La función `T(key)` devuelve el texto en el idioma activo. Al cambiar de idioma se llama a `ApplyLanguage()` que recorre todos los elementos de la UI y los actualiza en caliente.

---

## 💬 Comandos

| Comando | Acción |
|---|---|
| `/botinv` | Abre/cierra el panel lateral de bots |
| `/botinv <nombre>` | Abre directamente el paperdoll del bot indicado |
| `/npcbotinv` | Alias de `/botinv` |

---

## 💾 Variables guardadas

| Variable | Contenido |
|---|---|
| `BotInventoryDB` | Inventarios de todos los bots por personaje |
| `NBIStatsDB` | Stats de texto recibidos por susurro |
| `NBIRealStatsDB` | Stats detallados recibidos por addon message (requiere servidor) |
| `NBIButtonPos` | Posición del botón flotante y ángulo del botón del minimapa |
| `NBILangDB` | Idioma seleccionado (`"ES"` o `"EN"`) |

---

## 📜 Historial de versiones

### v7.0 — Multiidioma ES/EN
- Añadido sistema de idiomas completo con botón `ES | EN` en el encabezado
- Todos los textos de la UI traducidos: slots, stats, secciones, specs, roles
- Preferencia de idioma guardada en `NBILangDB` (SavedVariable)
- Añadido icono de talento (16×16) junto al nombre de spec en el encabezado
- Cada especialización tiene su icono nativo del juego asignado

### v6.1 — Stats + GS + Spec locales
- Añadido cálculo de **GearScore local** usando la fórmula estándar WotLK
- Añadida detección de spec por susurro (`"Cambiando mi talento a X"`) completamente independiente del servidor
- Listener propio en `BotInspect.lua` sin depender de `Core.lua`
- Specs ambiguas (Sagrado, Restauración, Escarcha, Protección) resueltas por clase del bot
- Spec y GS se actualizan en tiempo real si el paperdoll está abierto

### v6.0 — Stats locales desde items equipados
- **Eliminada dependencia de `BotStats_Server.lua`** para las estadísticas
- Implementado `ComputeStatsFromInventory()` usando `GetItemStats()` de la API nativa
- Añadido `ITEM_STAT_MAP` con todas las claves de WotLK 3.3.5
- Panel de stats ahora funciona 100% offline

### v5.x — Paperdoll unificado
- Ventana paperdoll con slots automáticos detectados por `equipSlot` de cada item
- Modelo 3D del bot si está en el grupo del jugador
- Bordes de slots coloreados por calidad del item
- Panel de stats lateral con scroll integrado
- Botón de recalcular stats

### v3.1 — UI y minimapa
- Panel lateral de lista de bots con botón de inspección
- Botón flotante arrastrable
- Botón en el minimapa arrastrable con posición guardada
- Confirmación antes de borrar todos los inventarios

---

## 🔬 Notas técnicas

- Compatible con **WoW 3.3.5a** (build 12340)
- No requiere librerías externas
- No requiere `BotStats_Server.lua` ni ningún módulo de servidor para las estadísticas
- Los stats muestran valores de **rating** (no porcentajes), ya que la conversión rating→% depende del nivel y requeriría constantes adicionales
- La spec persiste en `NBI.botRolesByName[nombre]` durante la sesión; al relogar se pierde hasta que el bot vuelva a cambiar de spec o el servidor la envíe por addon message
- Si tienes `BotStats_Server.lua` activo en el servidor, la spec también se puede poblar desde `NBI.botRoles[entry]` vía addon message con prefijo `BSTATS`

---

## 👤 Autor

**Lleguito** — Addon creado para servidores privados WotLK con NPCBots habilitados.
