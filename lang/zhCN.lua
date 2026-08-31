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
    },
}
