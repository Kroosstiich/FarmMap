-- ============================================================
--  FarmMap — Simplified Chinese (zhCN)
--  Translator: bluse
--
--  Falls back to enUS for any key not defined here.
--
--  Adding a new language? Read lang/README.md first.
-- ============================================================

local _, ns = ...

ns.locales = ns.locales or {}

ns.locales.zhCN = {
    name       = "简体中文",   -- shown in the language panel
    latinName  = "Simplified Chinese",   -- latin fallback, always readable
    translator = "bluse",
    order      = 40,          -- sort order in the language panel (koKR uses 30)

    -- OPTIONAL: your link, shown under the translation credit. The
    -- label is free text and is never translated. See enUS.lua.
    -- contactLabel = "Twitch",
    -- contactValue = "twitch.tv/yourname",

    -- OPTIONAL: localized slash aliases.
    slash = {
        prefix   = {},   -- extra chat commands, e.g. { "/farm" }
        commands = {},   -- extra sub-commands, e.g. { clear = { "wipe" } }
    },

    strings = {
        OPTIONS_TITLE          = "FarmMap 设置",
        CREDITS_CREATOR        = "作者",
        CREDITS_DISCORD        = "Discord",
        CREDITS_TRANSLATOR     = "翻译",
        CREDITS_VERSION        = "版本",
        CREDITS_UPDATE         = "更新日期",

        CREDITS_COPY_CLICK     = "点击复制",
        CREDITS_COPY_KEY       = "Ctrl+C 复制",
        CREDITS_COPIED         = "已复制!",

        DB_SECTION             = "数据库",
        DB_CLEAR               = "清除数据库",
        DB_CLEARED             = "数据库已清除。",
        DB_MIGRATE             = "更新数据库",
        DB_MIGRATE_DESC        = "\"更新\"会修复条目，不会删除你的数据。",
        DB_EXPORT              = "导出",
        DB_IMPORT              = "导入",
        DB_EXPORTIMPORT_DESC   = "导出你的节点以便分享。导入时会合并，不会覆盖现有数据。",

        DISPLAY_SECTION        = "显示",
        DISPLAY_DEBUG          = "显示调试窗口",
        DISPLAY_FLOAT          = "显示浮动采集文本",
        DISPLAY_FLOAT_SIZE     = "文本大小",
        DISPLAY_FLOAT_DURATION = "显示持续时间（秒）",
        DISPLAY_FLOAT_TIER     = "显示品质图标",
        DISPLAY_FLOAT_PROFIT   = "显示收益",
        DISPLAY_FLOAT_PROFIT_HINT = "（需要 Auctionator）",
        FILTERBAR_SECTION      = "世界地图筛选栏",
        FILTERBAR_SIZE         = "图标大小",
        FILTERBAR_ALPHA        = "未悬停时透明度",
        FILTERBAR_RESET        = "重置位置",
        FILTERBAR_DRAG_HINT    = "按住Shift拖动以移动筛选栏",
        FILTERBAR_FLIP_HINT    = "按住Shift右键点击以水平/垂直翻转",
        WORLDPIN_SECTION       = "世界地图节点图标",
        WORLDPIN_SIZE          = "图标大小",
        DISPLAY_NODE_ITEMS     = "显示每个节点的采集物品",
        -- [TRANSLATE] English text changed in v2.0.0: "Adds to each node's tooltip what it has yielded you. The node's own ore or herb is guaranteed; extras (stone, gems...) drop at random.",
        DISPLAY_NODE_ITEMS_HINT = "在每个节点的悬停提示中添加按品质的明细。单个节点的产出是随机的；区域汇总中的数据才更有意义。",
        ZONE_SUMMARY_TITLE     = "区域汇总",
        ZONE_BUTTON_HINT       = "点击打开区域汇总",
        ZONE_GATHERED          = "此处采集次数",
        ZONE_RESOURCES         = "采集的资源",
        ZONE_KNOWN             = "此处已知节点",
        ZONE_TOTAL             = "总计",
        ZONE_EMPTY             = "此处尚无采集记录。",
        DELETE_NODE            = "删除此标记",
        DEBUG_SECTION          = "调试",

        COLORS_TITLE           = "图标与颜色",
        COLORS_DESC            = " 选择小地图和世界地图的图标样式。\n 点击一行以选中它（金色边框 = 当前激活）。",
        MINIMAP_SECTION        = "小地图",
        REPLACE_BLIP           = "替换暴雪图标",
        -- [TRANSLATE] English text changed in v2.0.0: " Since patch 12.0.7, Blizzard no longer lets addons replace\n its atlas on the minimap. FarmMap's pins are drawn on top\n of it instead (option below).",
        REPLACE_BLIP_DESC      = " 由于近期的一次更新，已无法在小地图上\n 替换暴雪图标。仅世界地图保留自定义标记。",
        SHOW_MINIMAP_PINS      = "在小地图上显示标记",
        SHOW_MINIMAP_BUTTON    = "显示 FarmMap 小地图按钮",
        MINIMAP_BTN_LEFT       = "左键：打开设置",
        MINIMAP_BTN_RIGHT      = "右键：显示/隐藏调试窗口",
        WORLDMAP_SECTION       = "世界地图",
        PRESET_BLANK           = "白色轮廓",
        PRESET_VIVID           = "鲜艳色彩",
        PRESET_ATLAS           = "暴雪地图",
        PRESET_DEUT            = "绿色弱视",
        PRESET_PROT            = "红色弱视",
        PRESET_TRIT            = "蓝色弱视",

        STATS_TITLE            = "采集统计",
        STATS_DESC             = " 安装以来的总采集次数。此数据在导入数据库时不会被清除。",
        STATS_RESET            = "重置统计",
        STATS_RESET_DONE       = "统计已重置。",
        STATS_TOTAL            = "总计",

        TYPE_Herbo             = "草药学",
        TYPE_Minage            = "采矿",
        TYPE_Peche             = "钓鱼",
        TYPE_Bois              = "伐木",
        TYPE_HerboR            = "原始草药",
        TYPE_MinageR           = "原始矿石",
        TYPE_PecheR            = "丰富的鱼群",

        SKILL_MISSING          = "|cffff4444未学习该专业技能|r",
        TOGGLE_ON              = "|cff00ff00已启用|r",
        TOGGLE_OFF             = "|cffff4444已禁用|r",
        TOGGLE_HINT            = "点击以启用/禁用",
        EXPANSION              = "资料片",

        EXPORT_TITLE           = "导出数据库",
        EXPORT_HINT            = " Ctrl+A 然后 Ctrl+C 复制全部内容。",
        IMPORT_TITLE           = "导入数据库",
        IMPORT_WARN            = "|cffff8800\226\154\160 导入的节点将与当前数据库合并。|r",
        IMPORT_BTN             = "导入",
        IMPORT_SUCCESS         = " 个节点导入成功。",
        IMPORT_ERROR           = "错误",
        IMPORT_DONE            = "导入完成 — ",
        IMPORT_DONE2           = " 个节点已添加。",
        CLOSE                  = "关闭",
        PROF_DISABLED          = " 未检测到 — 显示已禁用。",

        DEBUG_TITLE            = "FarmMap.调试",
        DEBUG_CAPTURE          = " 捕获",
        DEBUG_CLEAR            = "清除",
        DEBUG_COPY             = "复制",
        DEBUG_COPY_TITLE       = "复制调试日志（Ctrl+A, Ctrl+C）",

        SLASH_HELP_TITLE       = "|cffffd100=== FarmMap — 命令列表 ===|r",
        SLASH_CMD_HELP         = "显示此帮助",
        SLASH_CMD_DEBUG        = "显示/隐藏调试窗口",
        SLASH_CMD_EXPORT       = "打开数据库导出",
        SLASH_CMD_IMPORT       = "打开数据库导入",
        SLASH_CMD_CLEAR        = "清除数据库",
        SLASH_CMD_STATS        = "在聊天中显示统计",
        SLASH_CMD_MIGRATE      = "强制数据库迁移",
        SLASH_CMD_ATLAS        = "图标地图校准器（开发工具）",
        SLASH_CMD_DEFAULT      = "恢复为游戏客户端语言",
        SLASH_CMD_VERSION      = "显示插件版本",

        SLASH_VERSION          = "版本",
        SLASH_CLEAR_CONFIRM    = "数据库已通过命令清除。",
        SLASH_UNKNOWN          = "未知命令。输入 /fm help 查看帮助",
        SLASH_CONFLICT         = "|cffff8800%s 也在使用 /fm|r - FarmMap 已接管响应 |cffffffff%s|r。",
        SLASH_DEFAULT_DONE     = "语言已恢复为游戏客户端语言。输入 /reload 以生效。",

        MIGR_PREFIX            = "FarmMap 迁移：",
        MIGR_DONE              = "数据库已是最新",
        MIGR_TOTAL             = "数据库迁移完成 —",
        MIGR_ENTRIES           = " 个条目已修正。",
        UNKNOWN                = "未知",
        UNKNOWN_EXP            = "未知",

        LANG_SECTION           = "语言",
        LANG_DESC              = " 强制使用指定语言（覆盖游戏语言）。需要重新加载。",
        LANG_AUTO              = "自动（系统）",
        LANG_RELOAD            = "|cffff8800语言已更改。输入 /reload 以生效。|r",
        LANG_THANKS            = "感谢参与插件翻译的贡献者们",

        PANEL_COLORS           = "颜色",
        PANEL_PACKS            = "整合包",
        PANEL_STATS            = "统计",
        PACKS_TITLE            = "图标整合包",
        PACKS_DESC             = " 来自已安装的子插件的样式。\n 选择整合包会禁用\"颜色\"中的当前预设（反之亦然）。",
        PACKS_EMPTY            = "|cffaaaaaa 未安装任何整合包。\n 安装 FarmMap_* 子插件后即可在此处查看。|r",

        ATLAS_TITLE            = "FarmMap — 地图校准（ObjectIconsAtlas）",
        ATLAS_HINT             = "左键拖动图标以调整位置。大小固定为 32x32，仅移动位置。",
        ATLAS_PRINT            = "复制表格",
        ATLAS_RESET            = "重置",
        ATLAS_COPY_TITLE       = "FarmMap — 地图坐标",
        ATLAS_COPY_HINT        = "已选中：按 Ctrl+C，然后粘贴到 WORLD_MAP_TEXCOORDS（和 BUILTIN_PINS）。",

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
        UI_FLOAT_DESC          = "Above your character after each harvest: what you gathered, how many you now carry and, with Auctionator, what it is worth.",  -- [TRANSLATE]
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
        UI_LANG_HELP           = "FarmMap is translated by its players, and a partial translation already works: untranslated texts stay in English. Translate in the browser on FarmMap's CurseForge localization page, or send a file on the Discord.",  -- [TRANSLATE]
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
        UI_TOOLTIP_ICON        = "Node icon in the tooltip",  -- [TRANSLATE]
        UI_TOOLTIP_ICON_DESC   = "Shows the icon of the pin you hover at the top right of its tooltip, in the style chosen for that map.",  -- [TRANSLATE]
    },
}
