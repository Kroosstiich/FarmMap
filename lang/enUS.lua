-- ============================================================
--  FarmMap — English (enUS)
--  Translator: Kroosstii
--
--  REFERENCE LOCALE. Every other language falls back to this
--  file for any key it does not define, so this file must
--  always stay complete.
--
--  Adding a new language? Read lang/README.md first.
-- ============================================================

local _, ns = ...

ns.locales = ns.locales or {}

ns.locales.enUS = {
    name       = "English",   -- shown in the language panel
    latinName  = "English",   -- latin fallback, always readable
    translator = "Kroosstii",
    order      = 10,          -- sort order in the language panel

    -- OPTIONAL: your link, shown in the options right under the
    -- translation credit. Yours to use as you like - a way to be
    -- reached, or a plug for your channel.
    --
    -- The label is free text and is NEVER translated: "Twitch" is a
    -- brand name, it reads the same in every language.
    --
    --   contactLabel = "Twitch",  contactValue = "twitch.tv/yourname"
    --   contactLabel = "Discord", contactValue = "yourname"
    --   contactLabel = "GitHub",  contactValue = "github.com/yourname"
    --
    -- Leave both commented out for no line at all - that is the
    -- default. Filling only one of the two drops the line as well.
    -- contactLabel = "Twitch",
    -- contactValue = "twitch.tv/yourname",

    -- OPTIONAL: localized slash aliases. English stays canonical —
    -- /fm, /farmmap and every English sub-command always keep working,
    -- so the addon page and any guide written in English stay correct.
    -- Nothing to add here: this file IS the English one.
    slash = {
        prefix   = {},   -- extra chat commands, e.g. { "/farm" }
        commands = {},   -- extra sub-commands, e.g. { clear = { "wipe" } }
    },

    strings = {
        OPTIONS_TITLE          = "FarmMap Options",
        CREDITS_CREATOR        = "Creator",
        CREDITS_DISCORD        = "Discord",
        CREDITS_TRANSLATOR     = "Translation",
        CREDITS_VERSION        = "Version",
        CREDITS_UPDATE         = "Updated",

        -- Copyable credit rows (the Discord invite, and the translator's
        -- own link if they filled one in). WoW has no clipboard API, so
        -- the click only selects the text - the player still presses
        -- Ctrl+C, and CREDITS_COPIED confirms once they have.
        CREDITS_COPY_CLICK     = "Click to copy",
        CREDITS_COPY_KEY       = "Ctrl+C to copy",
        CREDITS_COPIED         = "Copied!",

        DB_SECTION             = "Database",
        DB_CLEAR               = "Clear database",
        DB_CLEARED             = "Database cleared.",
        DB_MIGRATE             = "Update DB",
        DB_MIGRATE_DESC        = "\"Update\" fixes entries without deleting your data.",
        DB_EXPORT              = "Export",
        DB_IMPORT              = "Import",
        DB_EXPORTIMPORT_DESC   = "Export your nodes to share. Import merges without overwriting.",

        DISPLAY_SECTION        = "Display",
        DISPLAY_DEBUG          = "Show debug window",
        DISPLAY_FLOAT          = "Show floating harvest text",
        DISPLAY_FLOAT_SIZE     = "Text size",
        DISPLAY_FLOAT_DURATION = "Display duration (seconds)",
        DISPLAY_FLOAT_TIER     = "Show tier icon",
        DELETE_NODE            = "Delete this pin",
        DEBUG_SECTION          = "Debug",

        COLORS_TITLE           = "Icons & Colors",
        COLORS_DESC            = " Choose an icon style for the minimap and world map.\n Click a row to select it (golden border = active).",
        MINIMAP_SECTION        = "Minimap",
        REPLACE_BLIP           = "Replace Blizzard atlas",
        REPLACE_BLIP_DESC      = " Following a recent update, it is no longer possible to\n replace the Blizzard atlas on the minimap. Only the world\n map keeps the custom pins.",
        SHOW_MINIMAP_PINS      = "Show pins on the minimap",
        SHOW_MINIMAP_BUTTON    = "Show the FarmMap minimap button",
        MINIMAP_BTN_LEFT       = "Left click: open the options",
        MINIMAP_BTN_RIGHT      = "Right click: show/hide the debug window",
        WORLDMAP_SECTION       = "World Map",
        PRESET_BLANK           = "White outline",
        PRESET_VIVID           = "Vivid colors",
        PRESET_ATLAS           = "Blizzard Atlas",
        PRESET_DEUT            = "Deuteranopia",
        PRESET_PROT            = "Protanopia",
        PRESET_TRIT            = "Tritanopia",

        STATS_TITLE            = "Harvest statistics",
        STATS_DESC             = " Total harvests since installation. This data is never erased on DB import.",
        STATS_RESET            = "Reset statistics",
        STATS_RESET_DONE       = "Statistics reset.",
        STATS_TOTAL            = "Total",

        TYPE_Herbo             = "Herbalism",
        TYPE_Minage            = "Mining",
        TYPE_Peche             = "Fishing",
        TYPE_Bois              = "Logging",
        TYPE_HerboR            = "Primordial Herb",
        TYPE_MinageR           = "Primordial Ore",
        TYPE_PecheR            = "Abundant Fish",

        SKILL_MISSING          = "|cffff4444Skill not learned|r",
        TOGGLE_ON              = "|cff00ff00Enabled|r",
        TOGGLE_OFF             = "|cffff4444Disabled|r",
        TOGGLE_HINT            = "Click to enable/disable",
        EXPANSION              = "Expansion",

        EXPORT_TITLE           = "Export database",
        EXPORT_HINT            = " Ctrl+A then Ctrl+C to copy everything.",
        IMPORT_TITLE           = "Import database",
        IMPORT_WARN            = "|cffff8800\226\154\160 Imported nodes will be merged with your current DB.|r",
        IMPORT_BTN             = "Import",
        IMPORT_SUCCESS         = " node(s) successfully imported.",
        IMPORT_ERROR           = "Error",
        IMPORT_DONE            = "Import complete — ",
        IMPORT_DONE2           = " node(s) added.",
        CLOSE                  = "Close",
        PROF_DISABLED          = " not detected — display disabled.",

        DEBUG_TITLE            = "FarmMap.debug",
        DEBUG_CAPTURE          = " Capture",
        DEBUG_CLEAR            = "Clear",
        DEBUG_COPY             = "Copy",
        DEBUG_COPY_TITLE       = "Copy debug logs (Ctrl+A, Ctrl+C)",

        -- One key per command: a command added later shows up in
        -- English for languages that have not been updated yet,
        -- instead of vanishing from the list.
        SLASH_HELP_TITLE       = "|cffffd100=== FarmMap — Commands ===|r",
        SLASH_CMD_HELP         = "show this help",
        SLASH_CMD_DEBUG        = "show/hide debug window",
        SLASH_CMD_EXPORT       = "open DB export",
        SLASH_CMD_IMPORT       = "open DB import",
        SLASH_CMD_CLEAR        = "clear the database",
        SLASH_CMD_STATS        = "show statistics in chat",
        SLASH_CMD_MIGRATE      = "force DB migration",
        SLASH_CMD_ATLAS        = "icon atlas calibrator (dev tool)",
        SLASH_CMD_DEFAULT      = "go back to the game client language",
        SLASH_CMD_VERSION      = "show addon version",

        SLASH_VERSION          = "Version",
        SLASH_CLEAR_CONFIRM    = "DB cleared via command.",
        SLASH_UNKNOWN          = "Unknown command. Type /fm help",
        SLASH_DEFAULT_DONE     = "Language reset to the game client language. Type /reload to apply.",

        MIGR_PREFIX            = "FarmMap Migration:",
        MIGR_DONE              = "Database up to date",
        MIGR_TOTAL             = "DB migration complete —",
        MIGR_ENTRIES           = " entry/entries corrected.",
        UNKNOWN                = "Unknown",
        UNKNOWN_EXP            = "Unknown",

        LANG_SECTION           = "Language",
        LANG_DESC              = " Forced language (overrides game language). Reload required.",
        LANG_AUTO              = "Automatic (system)",
        LANG_RELOAD            = "|cffff8800Language changed. /reload to apply.|r",
        LANG_THANKS            = "Thanks to the contributors who translated the addon",

        PANEL_COLORS           = "Colors",
        PANEL_PACKS            = "Packs",
        PANEL_STATS            = "Statistics",
        PACKS_TITLE            = "Icon Packs",
        PACKS_DESC             = " Styles from installed sub-addons.\n Selecting a pack disables the active preset in Colors (and vice versa).",
        PACKS_EMPTY            = "|cffaaaaaa No packs installed.\n Install a FarmMap_* sub-addon to see packs here.|r",

        -- Expansion names shown in node tooltips.
        --
        -- Deliberately left commented out. FarmMap reads Blizzard's own
        -- EXPANSION_NAME<id> globals, which are ALREADY translated in every
        -- game client — a Korean player sees the official Korean name without
        -- anyone translating anything. Uncommenting a line here overrides
        -- Blizzard for this language only, so do it just for the wording you
        -- disagree with, and leave the rest alone.
        --
        -- EXP_0  = "Classic",
        -- EXP_1  = "The Burning Crusade",
        -- EXP_2  = "Wrath of the Lich King",
        -- EXP_3  = "Cataclysm",
        -- EXP_4  = "Mists of Pandaria",
        -- EXP_5  = "Warlords of Draenor",
        -- EXP_6  = "Legion",
        -- EXP_7  = "Battle for Azeroth",
        -- EXP_8  = "Shadowlands",
        -- EXP_9  = "Dragonflight",
        -- EXP_10 = "The War Within",
        -- EXP_11 = "Midnight",

        -- /fm atlas — icon atlas calibrator. It is a developer tool,
        -- but the addon page points pack creators to it, so it needs
        -- to be readable by non-French speakers too.
        ATLAS_TITLE            = "FarmMap — Atlas calibration (ObjectIconsAtlas)",
        ATLAS_HINT             = "Left-click and drag the icon to reposition it. The size stays fixed (32x32), only the position moves.",
        ATLAS_PRINT            = "Copy the table",
        ATLAS_RESET            = "Reset",
        ATLAS_COPY_TITLE       = "FarmMap — Atlas coordinates",
        ATLAS_COPY_HINT        = "Already selected: Ctrl+C, then paste into WORLD_MAP_TEXCOORDS (and BUILTIN_PINS).",
    },
}
