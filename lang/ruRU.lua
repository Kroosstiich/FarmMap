-- ============================================================
--  FarmMap — Russian (ruRU)
--  Translator: ZamestoTV
--
--  Falls back to enUS for any key not defined here.
--
--  Adding a new language? Read lang/README.md first.
-- ============================================================

local _, ns = ...

ns.locales = ns.locales or {}

ns.locales.ruRU = {
    name       = "Русский",   -- shown in the language panel
    latinName  = "Russian",   -- latin fallback, always readable
    translator = "ZamestoTV",
    order      = 50,          -- sort order in the language panel (zhCN uses 40)

    -- OPTIONAL: your link, shown under the translation credit. The
    -- label is free text and is never translated. See enUS.lua.
    -- contactLabel = "Twitch",
    -- contactValue = "twitch.tv/yourname",

    -- OPTIONAL: localized slash aliases. English stays canonical —
    -- /fm, /farmmap and every English sub-command always keep working,
    -- so the addon page and any guide written in English stay correct.
    slash = {
        prefix   = {},   -- extra chat commands, e.g. { "/farm" }
        commands = {},   -- extra sub-commands, e.g. { clear = { "wipe" } }
    },

    strings = {
        OPTIONS_TITLE          = "Настройки FarmMap",
        CREDITS_CREATOR        = "Создатель",
        CREDITS_DISCORD        = "Discord",
        CREDITS_TRANSLATOR     = "Перевод",
        CREDITS_VERSION        = "Версия",
        CREDITS_UPDATE         = "Обновлено",

        -- [TRANSLATE] marks English strings added after this translation
        -- was contributed. They are left in English on purpose, never
        -- machine-translated. Translate the text and delete the marker;
        -- until then they simply show in English in game.
        CREDITS_COPY_CLICK     = "Нажмите, чтобы скопировать",
        CREDITS_COPY_KEY       = "Ctrl+C для копирования",
        CREDITS_COPIED         = "Скопировано!",

        DB_SECTION             = "База данных",
        DB_CLEAR               = "Очистить базу данных",
        DB_CLEARED             = "База данных очищена.",
        DB_MIGRATE             = "Обновить БД",
        DB_MIGRATE_DESC        = "«Обновить» исправляет записи без удаления ваших данных.",
        DB_EXPORT              = "Экспорт",
        DB_IMPORT              = "Импорт",
        DB_EXPORTIMPORT_DESC   = "Экспортируйте свои точки, чтобы поделиться ими. Импорт объединяет данные без перезаписи.",

        DISPLAY_SECTION        = "Отображение",
        DISPLAY_DEBUG          = "Показывать окно отладки",
        DISPLAY_FLOAT          = "Показывать всплывающий текст сбора",
        DISPLAY_FLOAT_SIZE     = "Размер текста",
        DISPLAY_FLOAT_DURATION = "Длительность отображения (сек.)",
        DISPLAY_FLOAT_TIER     = "Показывать иконку ранга",
        DISPLAY_FLOAT_PROFIT   = "Показывать прибыль",
        DISPLAY_FLOAT_PROFIT_HINT = "(требуется Auctionator)",
        FILTERBAR_SECTION      = "Панель фильтров карты мира",
        FILTERBAR_SIZE         = "Размер значков",
        FILTERBAR_ALPHA        = "Прозрачность вне курсора",
        FILTERBAR_RESET        = "Сбросить положение",
        FILTERBAR_DRAG_HINT    = "Shift+перетаскивание - переместить панель",
        FILTERBAR_FLIP_HINT    = "Shift+ПКМ - повернуть горизонтально/вертикально",
        WORLDPIN_SECTION       = "Значки объектов на карте мира",
        WORLDPIN_SIZE          = "Размер значков",
        DISPLAY_NODE_ITEMS     = "Показывать собранные предметы для каждого узла",
        -- [TRANSLATE] English text changed in v2.0.0: "Adds to each node's tooltip what it has yielded you. The node's own ore or herb is guaranteed; extras (stone, gems...) drop at random.",
        DISPLAY_NODE_ITEMS_HINT = "Добавляет разбивку по тирам (рангам) во всплывающую подсказку каждого узла. Добыча с отдельного узла случайна; реальное значение имеют лишь цифры в сводке по зоне.",
        ZONE_SUMMARY_TITLE     = "Сводка по зоне",
        ZONE_BUTTON_HINT       = "Нажмите, чтобы открыть сводку по зоне",
        ZONE_GATHERED          = "Сборов выполнено здесь",
        ZONE_RESOURCES         = "Ресурсов собрано",
        ZONE_KNOWN             = "Известных узлов здесь",
        ZONE_TOTAL             = "Всего",
        ZONE_EMPTY             = "Здесь пока ничего не собрано.",
        DELETE_NODE            = "Удалить эту метку",
        DEBUG_SECTION          = "Отладка",

        COLORS_TITLE           = "Иконки и цвета",
        COLORS_DESC            = " Выберите стиль иконок для миникарты и карты мира.\n Нажмите на строку, чтобы выбрать ее (золотая рамка = активно).",
        MINIMAP_SECTION        = "Миникарта",
        REPLACE_BLIP           = "Заменять атлас Blizzard",
        -- [TRANSLATE] English text changed in v2.0.0: " Since patch 12.0.7, Blizzard no longer lets addons replace\n its atlas on the minimap. FarmMap's pins are drawn on top\n of it instead (option below).",
        REPLACE_BLIP_DESC      = " После недавнего обновления замена атласа Blizzard\n на миникарте стала невозможна. Кастомные метки\n сохраняются только на карте мира.",
        SHOW_MINIMAP_PINS      = "Показывать метки на миникарте",
        HIDE_NEARBY_MINIMAP_PINS = "Hide nearby pins",  -- [TRANSLATE]
        HIDE_NEARBY_MINIMAP_PINS_RADIUS = "Hide pins within",  -- [TRANSLATE]
        SHOW_MINIMAP_BUTTON    = "Показывать кнопку FarmMap у миникарты",
        MINIMAP_BTN_LEFT       = "ЛКМ: открыть настройки",
        MINIMAP_BTN_RIGHT      = "ПКМ: показать/скрыть окно отладки",
        WORLDMAP_SECTION       = "Карта мира",
        PRESET_BLANK           = "Белый контур",
        PRESET_VIVID           = "Яркие цвета",
        PRESET_ATLAS           = "Атлас Blizzard",
        PRESET_DEUT            = "Дейтеранопия",
        PRESET_PROT            = "Протанопия",
        PRESET_TRIT            = "Тританопия",

        STATS_TITLE            = "Статистика сбора",
        STATS_DESC             = " Всего собрано ресурсов с момента установки. Эти данные никогда не удаляются при импорте БД.",
        STATS_RESET            = "Сбросить статистику",
        STATS_RESET_DONE       = "Статистика сброшена.",
        STATS_TOTAL            = "Всего",

        TYPE_Herbo             = "Травничество",
        TYPE_Minage            = "Горное дело",
        TYPE_Peche             = "Рыбная ловля",
        TYPE_Bois              = "Заготовка леса",
        TYPE_HerboR            = "Изначальная трава",
        TYPE_MinageR           = "Изначальная руда",
        TYPE_PecheR            = "Изобильная рыба",

        SKILL_MISSING          = "|cffff4444Навык не изучен|r",
        TOGGLE_ON              = "|cff00ff00Включено|r",
        TOGGLE_OFF             = "|cffff4444Выключено|r",
        TOGGLE_HINT            = "Нажмите, чтобы включить/выключить",
        EXPANSION              = "Дополнение",

        EXPORT_TITLE           = "Экспорт базы данных",
        EXPORT_HINT            = " Нажмите Ctrl+A, затем Ctrl+C, чтобы скопировать всё.",
        IMPORT_TITLE           = "Импорт базы данных",
        IMPORT_WARN            = "|cffff8800\226\154\160 Импортированные точки будут объединены с текущей БД.|r",
        IMPORT_BTN             = "Импорт",
        IMPORT_SUCCESS         = " точк(а/и/ек) успешно импортировано.",
        IMPORT_ERROR           = "Ошибка",
        IMPORT_DONE            = "Импорт завершен - ",
        IMPORT_DONE2           = " точк(а/и/ек) добавлено.",
        CLOSE                  = "Закрыть",
        PROF_DISABLED          = " не обнаружено - отображение отключено.",

        DEBUG_TITLE            = "FarmMap.debug",
        DEBUG_CAPTURE          = " Захват",
        DEBUG_CLEAR            = "Очистить",
        DEBUG_COPY             = "Копировать",
        DEBUG_COPY_TITLE       = "Копировать логи отладки (Ctrl+A, Ctrl+C)",

        -- One key per command: a command added later shows up in
        -- English for languages that have not been updated yet,
        -- instead of vanishing from the list.
        SLASH_HELP_TITLE       = "|cffffd100=== FarmMap - Команды ===|r",
        SLASH_CMD_HELP         = "показать эту справку",
        SLASH_CMD_DEBUG        = "показать/скрыть окно отладки",
        SLASH_CMD_EXPORT       = "открыть экспорт БД",
        SLASH_CMD_IMPORT       = "открыть импорт БД",
        SLASH_CMD_CLEAR        = "очистить базу данных",
        SLASH_CMD_STATS        = "показать статистику в чате",
        SLASH_CMD_MIGRATE      = "принудительное обновление БД",
        SLASH_CMD_ATLAS        = "калибратор атласа иконок (для разработчиков)",
        SLASH_CMD_DEFAULT      = "вернуться к языку игрового клиента",
        SLASH_CMD_VERSION      = "показать версию аддона",

        SLASH_VERSION          = "Версия",
        SLASH_CLEAR_CONFIRM    = "БД очищена с помощью команды.",
        SLASH_UNKNOWN          = "Неизвестная команда. Введите /fm help",
        SLASH_CONFLICT         = "|cffff8800%s также использует /fm|r - FarmMap теперь отвечает на |cffffffff%s|r.",
        SLASH_DEFAULT_DONE     = "Язык сброшен на язык игрового клиента. Введите /reload для применения.",

        MIGR_PREFIX            = "Обновление FarmMap:",
        MIGR_DONE              = "База данных актуальна",
        MIGR_TOTAL             = "Обновление БД завершено -",
        MIGR_ENTRIES           = " запис(ь/и/ей) исправлено.",
        UNKNOWN                = "Неизвестно",
        UNKNOWN_EXP            = "Неизвестно",

        LANG_SECTION           = "Язык",
        LANG_DESC              = " Принудительный язык (переопределяет язык игры). Требуется перезагрузка.",
        LANG_AUTO              = "Автоматически (системный)",
        LANG_RELOAD            = "|cffff8800Язык изменен. Введите /reload для применения.|r",
        LANG_THANKS            = "Спасибо участникам, которые перевели аддон",

        PANEL_COLORS           = "Цвета",
        PANEL_PACKS            = "Наборы",
        PANEL_STATS            = "Статистика",
        PACKS_TITLE            = "Наборы иконок",
        PACKS_DESC             = " Стили из установленных под-аддонов.\n Выбор набора отключает активный пресет во вкладке «Цвета» (и наоборот).",
        PACKS_EMPTY            = "|cffaaaaaa Нет установленных наборов.\n Установите под-аддон FarmMap_*, чтобы увидеть наборы здесь.|r",

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
        ATLAS_TITLE            = "FarmMap - Калибровка атласа (ObjectIconsAtlas)",
        ATLAS_HINT             = "Зажмите ЛКМ и перетащите иконку, чтобы изменить ее положение. Размер остается фиксированным (32x32), меняются только координаты.",
        ATLAS_PRINT            = "Скопировать таблицу",
        ATLAS_RESET            = "Сбросить",
        ATLAS_COPY_TITLE       = "FarmMap - Координаты атласа",
        ATLAS_COPY_HINT        = "Уже выделено: нажмите Ctrl+C, затем вставьте в WORLD_MAP_TEXCOORDS (и BUILTIN_PINS).",

        -- ------------------------------------------------------------
        -- v2.0.0: new strings (new options window, dashboard, nodes,
        -- themes, integrations, What's new...). Lines marked [TRANSLATE]
        -- are still in English: translate them, then remove the comment.
        -- Keep %s / %d and |c...|r codes exactly as they are.
        -- ------------------------------------------------------------
        CREDITS_GAME           = "World of Warcraft",  -- [TRANSLATE]
        CLIENT_FOREVER         = "Forever",  -- [TRANSLATE]
        VERSION_NOTICE         = "Tell me when a newer version is spotted (guild or group)",  -- [TRANSLATE]
        UPDATE_AVAILABLE       = "a newer version is available: %s (you have %s). Please update the addon as soon as possible.",  -- [TRANSLATE]
        INTEG_SECTION          = "Integrations",  -- [TRANSLATE]
        INTEG_DESC             = "Other addons FarmMap works with when they are installed. None of them is required.",  -- [TRANSLATE]
        INTEG_DETECTED         = "detected",  -- [TRANSLATE]
        INTEG_MISSING          = "not installed",  -- [TRANSLATE]
        INTEG_AUCTIONATOR_DESC = "Shows what your harvests are worth in the floating text. Prices come from Auctionator's own database: scan the auction house at least once.",  -- [TRANSLATE]
        INTEG_NEEDS_FLOAT      = "(turn the floating text on in Display)",  -- [TRANSLATE]
        INTEG_TSM_DESC         = "Another source for the value of your harvests. TSM's prices come from the TSM application installed next to the game: keep it running so your realm's prices stay current.",  -- [TRANSLATE]
        INTEG_TOMTOM_DESC      = "Click a node on the map or the minimap to set a TomTom waypoint there, with its arrow to guide you.",  -- [TRANSLATE]
        INTEG_WAYPOINTUI_DESC  = "Click a node on the map or the minimap to be guided to it by WaypointUI. If TomTom is installed too, choose below which one FarmMap uses.",  -- [TRANSLATE]
        UI_WINDOW_SCALE        = "Window size",  -- [TRANSLATE]
        UI_WINDOW_SCALE_DESC   = "Makes the options and What's new windows larger or smaller. Set for this game client only: each client has its own interface scale.",  -- [TRANSLATE]
        UI_WAYPOINT_ADDON      = "Navigation addon",  -- [TRANSLATE]
        UI_WAYPOINT_ADDON_DESC = "Both are installed: choose which one places the waypoint when you click a node. With TomTom, WaypointUI shows the waypoint too as long as its \"Track TomTom Waypoints\" option is on: turn it off in WaypointUI's settings to use TomTom alone.",  -- [TRANSLATE]
        WAYPOINT_CLICK_TIP     = "Click: %s waypoint (click again to remove it)",  -- [TRANSLATE]
        PRESET_BLIZZARD        = "WoW Retail",  -- [TRANSLATE]
        PRESET_RING            = "Classic ring",  -- [TRANSLATE]
        PRESET_RING_COLOR      = "Classic ring, colors",  -- [TRANSLATE]
        PACKS_MORE             = "More icon packs are available on CurseForge:",  -- [TRANSLATE]
        PACKS_COPY_HINT        = "click an address, then Ctrl+C",  -- [TRANSLATE]
        PACKS_OWN              = "You can also make your own: any addon can add a style with FarmMapStyles.Register.\nSee the README on GitHub.",  -- [TRANSLATE]
        UI_TITLE               = "Options",  -- [TRANSLATE]
        UI_SEARCH              = "Search a setting…",  -- [TRANSLATE]
        UI_SETTINGS            = "Settings",  -- [TRANSLATE]
        UI_NEWS                = "What's new",  -- [TRANSLATE]
        UI_NEWS_DESC           = "The changelog of the current version series.",  -- [TRANSLATE]
        UI_CREDITS             = "Credits",  -- [TRANSLATE]
        UI_CREDITS_DESC        = "Creator, translators and contributors.",  -- [TRANSLATE]
        UI_DASH                = "Dashboard",  -- [TRANSLATE]
        UI_DASH_DESC           = "Your farming session, updated on every harvest.",  -- [TRANSLATE]
        UI_NODES               = "Nodes",  -- [TRANSLATE]
        UI_NODES_DESC          = "Every node you recorded: search, filter, delete in bulk.",  -- [TRANSLATE]
        UI_ICONS               = "Map and icons",  -- [TRANSLATE]
        UI_ICONS_DESC          = "The style of the icons on the minimap and the world map.",  -- [TRANSLATE]
        UI_THEME               = "Theme",  -- [TRANSLATE]
        UI_THEME_DESC          = "The colours of this window. Players can make and share their own.",  -- [TRANSLATE]
        UI_DISPLAY             = "Display",  -- [TRANSLATE]
        UI_DISPLAY_DESC        = "Floating text, filter bar, icon size.",  -- [TRANSLATE]
        UI_INTEG               = "Integrations",  -- [TRANSLATE]
        UI_INTEG_DESC          = "The other addons FarmMap works with, when they are installed.",  -- [TRANSLATE]
        UI_IO                  = "Import / Export",  -- [TRANSLATE]
        UI_IO_DESC             = "Share your node database, and see what an import adds before confirming.",  -- [TRANSLATE]
        UI_LANG                = "Language",  -- [TRANSLATE]
        UI_LANG_DESC           = "FarmMap's language, independent of the game's.",  -- [TRANSLATE]
        UI_DEBUG               = "Debug",  -- [TRANSLATE]
        UI_DEBUG_DESC          = "The diagnostic window and its options.",  -- [TRANSLATE]
        UI_RELOAD              = "Reload UI",  -- [TRANSLATE]
        DISPLAY_NEW_WINDOW     = "New options window",  -- [TRANSLATE]
        DISPLAY_NEW_WINDOW_DESC = "The minimap button opens FarmMap's own options window. Unticked, it opens the legacy panel in the game's AddOns options instead. Applied after a reload.",  -- [TRANSLATE]
        DISPLAY_NEW_WINDOW_RELOAD = "Reload the interface to apply this change.",  -- [TRANSLATE]
        UI_LINK_HINT           = "Ctrl+C to copy, Escape to close",  -- [TRANSLATE]
        UI_SOON                = "This page arrives in a coming test build.",  -- [TRANSLATE]
        UI_NO_MATCH            = "No page matches.",  -- [TRANSLATE]
        UI_THEME_BY            = "by %s",  -- [TRANSLATE]
        UI_THEME_OWN_TITLE     = "Themes as addons",  -- [TRANSLATE]
        UI_THEME_OWN           = "For addon authors: a theme can also ship as a small separate addon, like an icon pack (FarmMapThemes.Register). Like every theme, it changes the colours above and nothing else: icons go through an icon pack, and sizes, spacing and layout stay fixed, so no theme can break the window.",  -- [TRANSLATE]
        UI_THEME_MINE          = "your theme",  -- [TRANSLATE]
        UI_THEME_NEW_NAME      = "My theme %d",  -- [TRANSLATE]
        UI_THEME_DELETE        = "Delete this theme",  -- [TRANSLATE]
        UI_THEME_DELETE_CONFIRM = "Click × again to delete",  -- [TRANSLATE]
        UI_THEME_CUSTOM_TITLE  = "Customise",  -- [TRANSLATE]
        UI_THEME_LOCKED        = "Themes that come with FarmMap or from another addon cannot be changed. Make a copy to edit its colours: the copy is saved with your FarmMap settings, no file is created.",  -- [TRANSLATE]
        UI_THEME_EDIT_TITLE    = "Edit “%s”",  -- [TRANSLATE]
        UI_THEME_EDIT          = "Click a colour to change it: the window shows the change at once. Your themes are saved with your FarmMap settings, no file is created.",  -- [TRANSLATE]
        UI_THEME_NAME          = "Name",  -- [TRANSLATE]
        UI_THEME_COPY          = "Make a copy",  -- [TRANSLATE]
        UI_THEME_EXPORT        = "Export",  -- [TRANSLATE]
        UI_THEME_EXPORT_HINT   = "Ctrl+C to copy this theme, Escape to close",  -- [TRANSLATE]
        UI_THEME_EXPORT_ROW    = "Export a theme",  -- [TRANSLATE]
        UI_THEME_EXPORT_DESC   = "Copies the active theme's colours as text, to share it. Pick the theme first in Theme.",  -- [TRANSLATE]
        UI_THEME_IMPORT_TITLE  = "Theme “%s”",  -- [TRANSLATE]
        UI_THEME_IMPORT_DESC   = "A theme changes the colours of this window and nothing else, no icons. It joins your themes and is applied at once.",  -- [TRANSLATE]
        UI_THEME_IMPORT_GO     = "Import the theme",  -- [TRANSLATE]
        UI_THEME_IMPORT_DONE   = "Theme “%s” imported and applied.",  -- [TRANSLATE]
        UI_THEME_IMPORT_BAD    = "This text is not a FarmMap theme, or part of it is missing.",  -- [TRANSLATE]
        UI_TOKEN_BG            = "Window background",  -- [TRANSLATE]
        UI_TOKEN_PANEL         = "Panels",  -- [TRANSLATE]
        UI_TOKEN_PANEL2        = "Panels, second level",  -- [TRANSLATE]
        UI_TOKEN_LINE          = "Borders",  -- [TRANSLATE]
        UI_TOKEN_ACCENT        = "Accent",  -- [TRANSLATE]
        UI_TOKEN_ACCENTSOFT    = "Accent, quiet",  -- [TRANSLATE]
        UI_TOKEN_TEXT          = "Text",  -- [TRANSLATE]
        UI_TOKEN_DIM           = "Secondary text",  -- [TRANSLATE]
        UI_TOKEN_FAINT         = "Faint text",  -- [TRANSLATE]
        UI_TOKEN_GOOD          = "Positive",  -- [TRANSLATE]
        UI_TOKEN_WARN          = "Warning",  -- [TRANSLATE]
        UI_TOKEN_BAD           = "Negative",  -- [TRANSLATE]
        UI_TRANSLATORS         = "Translations",  -- [TRANSLATE]
        UI_CONTRIBUTORS        = "Contributors",  -- [TRANSLATE]
        UI_CREDIT_TEAM         = "FarmMap team",  -- [TRANSLATE]
        UI_CREDIT_INFO         = "Info",  -- [TRANSLATE]
        UI_CREDIT_CODE         = "Code and ideas",  -- [TRANSLATE]
        UI_CREDIT_TESTERS      = "Testers",  -- [TRANSLATE]
        UI_LANG_CHOICE         = "FarmMap's language",  -- [TRANSLATE]
        LANG_RELOAD_PLAIN      = "Language changed: reload the interface to apply it.",  -- [TRANSLATE]
        UI_LANG_CHOICE_DESC    = "Automatic follows the game's language. Any other choice forces FarmMap's texts into that language; item and zone names stay in the game's. Applied after a reload.",  -- [TRANSLATE]
        UI_SEC_GENERAL         = "General",  -- [TRANSLATE]
        UI_VERSION_NOTICE      = "New version notice",  -- [TRANSLATE]
        UI_VERSION_NOTICE_DESC = "When someone in your guild or group runs a newer FarmMap, a line in the chat tells you, once per session.",  -- [TRANSLATE]
        UI_SEC_FLOAT           = "Floating text",  -- [TRANSLATE]
        UI_FLOAT               = "Floating text on harvest",  -- [TRANSLATE]
        UI_FLOAT_DESC          = "Above your character after each harvest: what you gathered, how many you now carry and, with Auctionator or TSM, what it is worth.",  -- [TRANSLATE]
        UI_FLOAT_TIER          = "Quality rank icon",  -- [TRANSLATE]
        UI_FLOAT_TIER_DESC     = "Shows the reagent's quality rank next to its name.",  -- [TRANSLATE]
        UI_FLOAT_SIZE          = "Text size",  -- [TRANSLATE]
        UI_FLOAT_DURATION      = "Time on screen",  -- [TRANSLATE]
        UI_SEC_FILTERBAR       = "World map filter bar",  -- [TRANSLATE]
        UI_FILTERBAR_HINT      = "Shift-drag the bar to move it, Shift-right-click it to switch between horizontal and vertical.",  -- [TRANSLATE]
        UI_FILTERBAR_SIZE      = "Button size",  -- [TRANSLATE]
        UI_FILTERBAR_ALPHA     = "Opacity when the cursor is elsewhere",  -- [TRANSLATE]
        UI_FILTERBAR_RESET     = "Bar position",  -- [TRANSLATE]
        UI_FILTERBAR_RESET_DESC = "Puts the bar back in its default corner of the world map.",  -- [TRANSLATE]
        UI_SEC_WORLDPINS       = "World map node icons",  -- [TRANSLATE]
        UI_WORLDPIN_SIZE       = "Icon size",  -- [TRANSLATE]
        UI_NODE_ITEMS          = "Harvested items in node tooltips",  -- [TRANSLATE]
        UI_SEC_STYLES          = "Icon style",  -- [TRANSLATE]
        UI_STYLE_MINIMAP       = "Minimap",  -- [TRANSLATE]
        UI_STYLE_WORLDMAP      = "World map",  -- [TRANSLATE]
        UI_STYLE_PACK          = "pack",  -- [TRANSLATE]
        UI_SEC_MINIMAP         = "Minimap",  -- [TRANSLATE]
        UI_MINIMAP_PINS        = "FarmMap pins on the minimap",  -- [TRANSLATE]
        UI_MINIMAP_PINS_DESC   = "Off, your nodes only show on the world map.",  -- [TRANSLATE]
        UI_MINIMAP_HIDE_NEARBY = "Hide nearby pins",  -- [TRANSLATE]
        UI_MINIMAP_HIDE_NEARBY_DESC = "Hides pins within the distance you choose to keep the minimap clear.",  -- [TRANSLATE]
        UI_MINIMAP_HIDE_NEARBY_RADIUS = "Hide pins within",  -- [TRANSLATE]
        UI_MINIMAP_BUTTON      = "Minimap button",  -- [TRANSLATE]
        UI_MINIMAP_BUTTON_DESC = "Left click opens these options, right click the debug window.",  -- [TRANSLATE]
        UI_SEC_PACKS           = "Icon packs",  -- [TRANSLATE]
        UI_PACKS_DESC          = "Icon packs are small separate addons: once installed, their styles join the lists above. More packs on CurseForge, or make your own with FarmMapStyles.Register (see the README on GitHub).",  -- [TRANSLATE]
        UI_PROFIT              = "Harvest value in the floating text",  -- [TRANSLATE]
        UI_PROFIT_DESC         = "Adds what each harvest is worth at the auction house.",  -- [TRANSLATE]
        UI_PROFIT_NEEDS_AUC    = "Needs Auctionator or TSM.",  -- [TRANSLATE]
        UI_PROFIT_NEEDS_FLOAT  = "Turn the floating text on in Display first.",  -- [TRANSLATE]
        UI_SEC_PRICES          = "Harvest value",  -- [TRANSLATE]
        UI_SEC_WAYPOINTS       = "Navigation",  -- [TRANSLATE]
        UI_PRICE_SOURCE        = "Price source",  -- [TRANSLATE]
        UI_PRICE_SOURCE_DESC   = "Both addons are installed: choose which one values your harvests.",  -- [TRANSLATE]
        UI_TSM_PRICE           = "TSM price",  -- [TRANSLATE]
        UI_TSM_PRICE_DESC      = "The TSM price used to value your harvests.",  -- [TRANSLATE]
        UI_TSM_DBMarket        = "Market value (realm)",  -- [TRANSLATE]
        UI_TSM_DBMinBuyout     = "Lowest buyout (realm)",  -- [TRANSLATE]
        UI_TSM_DBRegionMarketAvg = "Average market value (region)",  -- [TRANSLATE]
        UI_WAYPOINT_CLICK      = "Waypoint on click",  -- [TRANSLATE]
        UI_WAYPOINT_CLICK_DESC = "A click on a node sets a waypoint with TomTom or WaypointUI; a second click removes it. These waypoints are not kept from one session to the next.",  -- [TRANSLATE]
        UI_INTEG_ASK_TITLE     = "Another addon?",  -- [TRANSLATE]
        UI_INTEG_ASK           = "You use an addon FarmMap could work with? Ask on the Discord: integrations are added at the players' request.",  -- [TRANSLATE]
        UI_EXPORT_DESC         = "Copies your node database as text, to share it.",  -- [TRANSLATE]
        UI_AGO_NOW             = "just now",  -- [TRANSLATE]
        UI_AGO_MIN             = "%d min ago",  -- [TRANSLATE]
        UI_AGO_H               = "%d h ago",  -- [TRANSLATE]
        UI_DUR_MIN             = "%d min",  -- [TRANSLATE]
        UI_DUR_H               = "%d h %02d",  -- [TRANSLATE]
        UI_DASH_TIME           = "Duration",  -- [TRANSLATE]
        UI_DASH_TIME_SUB       = "this session",  -- [TRANSLATE]
        UI_DASH_NODES          = "Nodes harvested",  -- [TRANSLATE]
        UI_DASH_PER_HOUR       = "%d per hour",  -- [TRANSLATE]
        UI_DASH_VALUE          = "Value harvested",  -- [TRANSLATE]
        UI_DASH_VALUE_SUB      = "%s prices",  -- [TRANSLATE]
        UI_DASH_GPH            = "Gold per hour",  -- [TRANSLATE]
        UI_DASH_GPH_SUB        = "at the current pace",  -- [TRANSLATE]
        UI_DASH_BYTYPE         = "By resource",  -- [TRANSLATE]
        UI_DASH_RECENT         = "Latest harvests",  -- [TRANSLATE]
        UI_DASH_RECENT_EMPTY   = "No harvest yet this session.",  -- [TRANSLATE]
        UI_DASH_RESET          = "Reset the session",  -- [TRANSLATE]
        UI_DASH_RESET_DESC     = "Starts a new session now. One also starts on its own after 15 minutes logged out; a /reload keeps it.",  -- [TRANSLATE]
        UI_NODES_SEARCH        = "Item or zone, e.g. Peacebloom",  -- [TRANSLATE]
        UI_NODES_ALL_ZONES     = "All zones",  -- [TRANSLATE]
        UI_NODES_WHERE         = "Where to find \"%s\"",  -- [TRANSLATE]
        UI_NODES_WHERE_LINE    = "%s — %d harvests, %d nodes",  -- [TRANSLATE]
        UI_NODES_COL_ITEM      = "Item",  -- [TRANSLATE]
        UI_NODES_COL_ZONE      = "Zone",  -- [TRANSLATE]
        UI_NODES_COL_NODES     = "Nodes",  -- [TRANSLATE]
        UI_NODES_COL_HARVESTS  = "Harvests",  -- [TRANSLATE]
        UI_NODES_MORE          = "%d more lines: narrow the search.",  -- [TRANSLATE]
        UI_NODES_NONE          = "No node matches.",  -- [TRANSLATE]
        UI_NODES_DELETE        = "Delete %d lines",  -- [TRANSLATE]
        UI_NODES_DELETE_NAME   = "Delete the selection",  -- [TRANSLATE]
        UI_NODES_DELETE_DESC   = "Removes the selected nodes from the map. Your harvest statistics stay.",  -- [TRANSLATE]
        UI_NODES_DELETED       = "%d nodes deleted.",  -- [TRANSLATE]
        UI_IMPORT_PASTE        = "Paste another player's export or a theme below, then Analyse: nothing is imported until you confirm.",  -- [TRANSLATE]
        UI_IMPORT_ANALYSE      = "Analyse",  -- [TRANSLATE]
        UI_IMPORT_CLEAR        = "Clear",  -- [TRANSLATE]
        UI_IMPORT_PREVIEW      = "Import preview",  -- [TRANSLATE]
        UI_IMPORT_SUMMARY      = "%d new nodes, %d already known (skipped). Nothing is imported yet.",  -- [TRANSLATE]
        UI_IMPORT_INVALID      = "%d unreadable entries are left out.",  -- [TRANSLATE]
        UI_IMPORT_COL_NEW      = "New",  -- [TRANSLATE]
        UI_IMPORT_COL_KNOWN    = "Already known",  -- [TRANSLATE]
        UI_IMPORT_GO           = "Import %d nodes",  -- [TRANSLATE]
        UI_IMPORT_CANCEL       = "Cancel",  -- [TRANSLATE]
        UI_IMPORT_DONE         = "%d nodes imported.",  -- [TRANSLATE]
        UI_IMPORT_OTHER_CLIENT = "This export comes from %s and you are on %s. Map IDs differ between game clients, so its nodes may land on maps that do not exist here.",  -- [TRANSLATE]
        UI_PACK_INSTALLED      = "Installed",  -- [TRANSLATE]
        UI_CL_NEW              = "New",  -- [TRANSLATE]
        UI_CL_CHANGED          = "Changes",  -- [TRANSLATE]
        UI_CL_FIXED            = "Fixes",  -- [TRANSLATE]
        UI_CL_REMOVED          = "Removed",  -- [TRANSLATE]
        UI_CL_SKIPPED          = "Also since your last visit",  -- [TRANSLATE]
        UI_CL_UNREAD           = "Unread",  -- [TRANSLATE]
        UI_CL_IN_ENGLISH       = "In English",  -- [TRANSLATE]
        UI_CL_OLDER            = "Older versions",  -- [TRANSLATE]
        UI_CL_SHOW_OLDER       = "Show older changelogs",  -- [TRANSLATE]
        UI_CL_HIDE_OLDER       = "Hide older changelogs",  -- [TRANSLATE]
        UI_CL_INTRO            = "FarmMap was updated to %s. Here is what changes.",  -- [TRANSLATE]
        UI_CL_OPEN_OPTIONS     = "Open the options",  -- [TRANSLATE]
        UI_DASH_SESSION        = "Session",  -- [TRANSLATE]
        UI_DASH_MINI           = "Small session window",  -- [TRANSLATE]
        UI_DASH_MINI_DESC      = "Shows these four numbers in a small window you can move anywhere, without opening the options.",  -- [TRANSLATE]
        UI_SEC_LIFETIME        = "Since installation",  -- [TRANSLATE]
        UI_DASH_LIFETIME       = "Harvests since installation",  -- [TRANSLATE]
        UI_STATS_RESET_DESC    = "Resets every harvest counter: these totals, the per-node history (zone summary, harvest counts of the Nodes page) and the session. Your nodes stay on the map.",  -- [TRANSLATE]
        UI_DEBUG_WINDOW        = "Debug window",  -- [TRANSLATE]
        UI_DEBUG_WINDOW_DESC   = "What FarmMap sees on each harvest, to report a problem. Also opens with a right click on the minimap button.",  -- [TRANSLATE]
        UI_DEBUG_CAPTURE       = "Record debug lines",  -- [TRANSLATE]
        UI_DEBUG_CAPTURE_DESC  = "Off, FarmMap writes nothing to the debug window.",  -- [TRANSLATE]
        UI_DB_MIGRATE          = "Repair the database",  -- [TRANSLATE]
        UI_DB_MIGRATE_DESC     = "Fixes old entries without deleting anything.",  -- [TRANSLATE]
        UI_DB_CLEAR_DESC       = "Deletes every recorded node. Your settings and statistics stay.",  -- [TRANSLATE]
        UI_DB_CLEAR_CONFIRM    = "Click again to confirm",  -- [TRANSLATE]
        UI_LANG_HELP_TITLE     = "Your language is missing?",  -- [TRANSLATE]
        UI_LANG_HELP           = "FarmMap is translated by its players, and a partial translation already works: untranslated texts stay in English. Copy lang/enUS.lua, translate the texts between the quotes, then send the file on the Discord or on GitHub.",  -- [TRANSLATE]
        UI_ROLE_AUTHOR         = "Author",  -- [TRANSLATE]
        UI_CONTRIB_BUSEQ       = "harvest value display",  -- [TRANSLATE]
        UI_CONTRIB_CRAZY       = "ideas: movable filter bar and its size, translated expansion names",  -- [TRANSLATE]
        UI_CONTRIB_R0S0J       = "ideas: world map icon size, zone summary",  -- [TRANSLATE]

        -- v2.0.0, added later (Sakura pack, filter bar): [TRANSLATE] = still English.
        UI_THEME_SITE_TIP      = "Click to copy the link to the author's site.",  -- [TRANSLATE]
        UI_CREDIT_ART          = "Illustrations",  -- [TRANSLATE]
        UI_FILTERBAR_ICONS     = "Style icons in the bar",  -- [TRANSLATE]
        UI_FILTERBAR_ICONS_DESC = "The buttons show the icons of the style chosen for the world map, an icon pack's included, so the bar matches the map. With a ring style, or off, they keep their usual icons.",  -- [TRANSLATE]
        UI_CONTRIB_SOREL       = "FarmMap's icon and the Sakura pack (soreldesign.fr)",  -- [TRANSLATE]
        UI_CONTRIB_FIOTE       = "hiding nearby pins on the minimap",  -- [TRANSLATE]

        -- Setup assistant (UI\Setup.lua): one setting per screen.
        SETUP_TITLE            = "Setup",  -- [TRANSLATE]
        SETUP_STEP             = "%d / %d",
        SETUP_ON               = "Turn on",  -- [TRANSLATE]
        SETUP_OFF              = "Leave off",  -- [TRANSLATE]
        SETUP_NEXT             = "Next",  -- [TRANSLATE]
        SETUP_PREV             = "Back",  -- [TRANSLATE]
        SETUP_DONE             = "Done",  -- [TRANSLATE]
        SETUP_SKIP             = "Skip",  -- [TRANSLATE]
        SETUP_HINT             = "Everything can be changed later in the options. Type /fm setup to run this assistant again.",  -- [TRANSLATE]
        SETUP_MINIMAP_PINS_TITLE = "Pins on the minimap",  -- [TRANSLATE]
        SETUP_MINIMAP_PINS_TEXT  = "FarmMap shows the nodes you have harvested on the minimap, with the icons of the style you choose.",  -- [TRANSLATE]
        SETUP_MINIMAP_PINS_ON    = "Your nodes show on the minimap and on the world map. After long farming sessions, the minimap can fill up.",  -- [TRANSLATE]
        SETUP_MINIMAP_PINS_OFF   = "Your nodes only show on the world map. The minimap stays as the game draws it.",  -- [TRANSLATE]
        SETUP_HIDE_NEARBY_TITLE  = "Hide nearby pins",  -- [TRANSLATE]
        SETUP_HIDE_NEARBY_TEXT   = "Hides FarmMap's pins close to your character, so they no longer cover its arrow on the minimap. They come back as you move away. An idea, and the code, by fiote.",  -- [TRANSLATE]
        SETUP_HIDE_NEARBY_ON     = "Within the distance chosen below, pins disappear from the minimap. Up close, the game's own gathering tracking usually shows the nodes.",  -- [TRANSLATE]
        SETUP_HIDE_NEARBY_ON_CLASSIC = "Within the distance chosen below, pins disappear from the minimap. If your game tracks only one kind of gathering at a time, a nearby node of another kind will not show at all.",  -- [TRANSLATE]
        SETUP_HIDE_NEARBY_OFF    = "Every pin stays on the minimap, even under your character.",  -- [TRANSLATE]
        SETUP_MINIMAP_BUTTON_TITLE = "Minimap button",  -- [TRANSLATE]
        SETUP_MINIMAP_BUTTON_TEXT  = "A FarmMap button on the edge of the minimap: left click opens the options, right click the debug window.",  -- [TRANSLATE]
        SETUP_MINIMAP_BUTTON_ON    = "The button stays on the minimap. Drag it to move it along the edge.",  -- [TRANSLATE]
        SETUP_MINIMAP_BUTTON_OFF   = "No button on the minimap. Open the options with /fm ui.",  -- [TRANSLATE]
        SETUP_FLOAT_TITLE      = "Floating text",  -- [TRANSLATE]
        SETUP_FLOAT_TEXT       = "After each harvest, a short text rises above your character: what you gathered and how many you now carry.",  -- [TRANSLATE]
        SETUP_FLOAT_ON         = "You see each harvest at a glance, without opening your bags.",  -- [TRANSLATE]
        SETUP_FLOAT_OFF        = "No text on screen. Your harvests are still recorded.",  -- [TRANSLATE]
        SETUP_PROFIT_TITLE     = "Harvest value",  -- [TRANSLATE]
        SETUP_PROFIT_TEXT      = "FarmMap adds to the floating text what your harvest is worth at the auction house, with the prices of Auctionator or TradeSkillMaster.",  -- [TRANSLATE]
        SETUP_PROFIT_ON        = "Each harvest shows its value. The prices are those of your price addon's latest data.",  -- [TRANSLATE]
        SETUP_PROFIT_OFF       = "The floating text shows the items only, without their value.",  -- [TRANSLATE]
        SETUP_WAYPOINT_TITLE   = "Waypoint on click",  -- [TRANSLATE]
        SETUP_WAYPOINT_TEXT    = "Click a node on the world map or the minimap to set a waypoint there with TomTom or WaypointUI.",  -- [TRANSLATE]
        SETUP_WAYPOINT_ON      = "A click guides you to the node. A second click removes the waypoint.",  -- [TRANSLATE]
        SETUP_WAYPOINT_OFF     = "A click on a node sets no waypoint. TomTom and WaypointUI work as usual.",  -- [TRANSLATE]
        SETUP_THEME_TITLE      = "Window theme",  -- [TRANSLATE]
        SETUP_THEME_TEXT       = "The colours of FarmMap's windows, this one included: pick a theme to see it right away. The Theme page lets you make your own.",  -- [TRANSLATE]
        SETUP_STYLES_TITLE     = "Icon style",  -- [TRANSLATE]
        SETUP_STYLES_TEXT      = "The icons of your nodes, on the minimap and on the world map. The minimap below shows the style picked for it; hover an icon in the lists to see it bigger.",  -- [TRANSLATE]
        UI_TOOLTIP_ICON        = "Node icon in the tooltip",  -- [TRANSLATE]
        UI_TOOLTIP_ICON_DESC   = "Shows the icon of the pin you hover at the top right of its tooltip, in the style chosen for that map.",  -- [TRANSLATE]
    },
}
