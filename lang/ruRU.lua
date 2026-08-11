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
        CREDITS_COPY_CLICK     = "Click to copy",   -- [TRANSLATE]
        CREDITS_COPY_KEY       = "Ctrl+C to copy",  -- [TRANSLATE]
        CREDITS_COPIED         = "Copied!",         -- [TRANSLATE]

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
        DELETE_NODE            = "Удалить эту метку",
        DEBUG_SECTION          = "Отладка",

        COLORS_TITLE           = "Иконки и цвета",
        COLORS_DESC            = " Выберите стиль иконок для миникарты и карты мира.\n Нажмите на строку, чтобы выбрать ее (золотая рамка = активно).",
        MINIMAP_SECTION        = "Миникарта",
        REPLACE_BLIP           = "Заменять атлас Blizzard",
        REPLACE_BLIP_DESC      = " После недавнего обновления замена атласа Blizzard\n на миникарте стала невозможна. Кастомные метки\n сохраняются только на карте мира.",
        SHOW_MINIMAP_PINS      = "Показывать метки на миникарте",
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
    },
}
