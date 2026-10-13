-- =============================================================
-- FarmMap — 한국어 (koKR)
-- 번역: Crazyyoungs
--
-- 여기에 정의되지 않은 문자열(Key)은 자동으로 영문(lang/enUS.lua)을 불러옵니다.
-- 자세한 내용은 lang/README.md 파일에서 확인할 수 있습니다.
-- ------------------------------------------------------------
-- 번역가 안내 사항
--
-- 아래 [TRANSLATE] 표시가 있는 줄은 번역가 참여 이후에 새로 추가된 영문 스트링입니다.
-- 기계 번역을 돌리지 않고 의도적으로 영문 원본 그대로 남겨둔 상태입니다.
--
-- 해당 스트링을 한국어로 번역한 뒤 [TRANSLATE] 주석을 삭제하면 적용됩니다.
-- 이외에 추가 작업은 필요 없으며, 번역되지 않은 줄만 인게임에서 영문으로 출력됩니다.
--
-- 파일 내에서 [TRANSLATE]를 검색(Ctrl+F)하여 미번역 줄을 모두 찾을 수 있습니다.
--
-- /fm atlas 명령어는 자체 아이콘 팩 제작자들을 위한 개발자 도구(Dev Tool)이므로
-- 다른 텍스트에 비해 번역 우선순위가 낮습니다.
-- ------------------------------------------------------------
-- =============================================================


local _, ns = ...

ns.locales = ns.locales or {}

ns.locales.koKR = {
    name       = "한국어",
    latinName  = "Korean",
    translator = "Crazyyoungs",
    order      = 30,

    -- 선택사항: 번역가 크레디트 바로 아래 옵션에 표시되는
    -- 개인 링크입니다. 연락 수단이나 채널 홍보용 등
    -- 원하시는 용도로 자유롭게 사용하세요.
    --
    -- 라벨은 자유 텍스트이며 절대 번역되지 않습니다. "Twitch" 같은
    -- 브랜드 이름은 어느 언어에서나 동일하게 읽힙니다.
    --
    --   contactLabel = "Twitch",  contactValue = "twitch.tv/yourname"
    --   contactLabel = "Discord", contactValue = "yourname"
    --   contactLabel = "GitHub",  contactValue = "github.com/yourname"
    --
    -- 아무것도 표시하지 않으려면 둘 다 주석 처리해 두세요(기본값). 
    -- 둘 중 하나만 입력해도 줄이 표시되지 않습니다.
    -- contactLabel = "Twitch",
    -- contactValue = "twitch.tv/yourname",

    -- 선택 사항: 한국어 슬래시(/) 명령어 단축어 설정. (영문 명령어는 기본 유지)
    -- /fm, /farmmap 및 모든 영문 하위 명령어는 항상 정상 작동합니다.
    -- 이 설정은 추가 사항일 뿐이며, 설정을 비워 두어도 무방합니다.
    --
    -- 설정 예시:
    --   prefix   = { "/farm" },
    --   commands = { help = { "dm" } }, -- (예: 도움말 대신 한글 자판 매칭인 dm 설정 가능)
    --
    -- 참고: 인게임 채팅창에서 한글 슬래시 명령어를 쓰려면 한/영 키(IME)를 
    -- 전환해야 하므로, 한글 단어보다 영문 알파벳 단축어가 훨씬 실용적입니다.
    -- 단축어 지정 여부는 전적으로 번역가의 판단에 따릅니다.
    --
    -- 영문 기본 명령어와 겹치는 단축어는 자동으로 무시되므로,
    -- "clear"를 단축어로 중복 지정하더라도 기존 /fm clear 명령어가 고장 나지 않습니다.
    slash = {
        prefix   = {},
        commands = {},
    },

    strings = {
        OPTIONS_TITLE          = "FarmMap 설정",
        CREDITS_CREATOR        = "제작자",
        CREDITS_DISCORD        = "디스코드",
        CREDITS_TRANSLATOR     = "번역",
        CREDITS_VERSION        = "버전",
        CREDITS_UPDATE         = "최신 업데이트",
		
        -- 복사 가능한 크레디트 행(Discord 초대 링크 및 번역가가 
        -- 직접 입력한 경우 개인 링크). 와우에는 클립보드 API가 없으므로 
        -- 클릭하면 텍스트만 선택됩니다. 플레이어가 직접 Ctrl+C를 
        -- 눌러야 하며, CREDITS_COPIED는 복사가 완료되었음을 확인해 줍니다.
        CREDITS_COPY_CLICK     = "클릭하여 복사",
        CREDITS_COPY_KEY       = "Ctrl+C를 눌러 복사",
        CREDITS_COPIED         = "복사되었습니다!",

        DB_SECTION             = "DB",
        DB_CLEAR               = "DB 초기화",
        DB_CLEARED             = "DB 초기화되었습니다.",
        DB_MIGRATE           = "DB 업데이트",
        DB_MIGRATE_DESC        = "\"최신화\"를 진행하면 데이터를 삭제하지 않고 이전 버전의 데이터를 최신 구조로 수정합니다.",
        DB_EXPORT              = "내보내기",
        DB_IMPORT              = "가져오기",
        DB_EXPORTIMPORT_DESC   = "노드 데이터를 내보내어 공유할 수 있습니다. 가져오기 시 기존 데이터를 덮어쓰지 않고 병합합니다.",

        DISPLAY_SECTION        = "표시",
        DISPLAY_DEBUG          = "디버그 창 표시",
        DISPLAY_FLOAT          = "채집 시 알림 텍스트 표시",
        DISPLAY_FLOAT_SIZE     = "글꼴 크기",
        DISPLAY_FLOAT_DURATION = "표시 시간 (초)",
        DISPLAY_FLOAT_TIER     = "등급 아이콘 표시",
        DISPLAY_FLOAT_PROFIT   = "수익 표시",
        DISPLAY_FLOAT_PROFIT_HINT = "(Auctionator 필요)",
        FILTERBAR_SECTION      = "세계지도 필터 바",
        FILTERBAR_SIZE         = "아이콘 크기",
        FILTERBAR_ALPHA        = "마우스를 올리지 않았을 때 투명도",
        FILTERBAR_RESET        = "위치 초기화",
        FILTERBAR_DRAG_HINT    = "Shift+드래그하여 바 이동",
        FILTERBAR_FLIP_HINT    = "Shift+우클릭하여 가로/세로 전환",
        WORLDPIN_SECTION       = "세계 지도 노드 아이콘",
        WORLDPIN_SIZE          = "아이콘 크기",
        DISPLAY_NODE_ITEMS     = "노드별 획득 아이템 표시",
        -- [TRANSLATE] English text changed in v2.0.0: "Adds to each node's tooltip what it has yielded you. The node's own ore or herb is guaranteed; extras (stone, gems...) drop at random.",
        DISPLAY_NODE_ITEMS_HINT = "각 노드 툴팁에 등급별 세부 내역을 추가합니다. 개별 노드에서 나오는 품목은 무작위이며, 지역 요약에서 수치의 진정한 의미를 확인할 수 있습니다.",
        ZONE_SUMMARY_TITLE     = "지역 요약",
        ZONE_BUTTON_HINT       = "클릭하여 지역 요약 열기",
        ZONE_GATHERED          = "이 지역 채집 횟수",
        ZONE_RESOURCES         = "획득한 자원",
        ZONE_KNOWN             = "이 지역의 알려진 노드",
        ZONE_TOTAL             = "총계",
        ZONE_EMPTY             = "아직 이 지역에서 채집한 항목이 없습니다.",
        DELETE_NODE            = "이 노드 삭제",
        DEBUG_SECTION          = "디버그",

        COLORS_TITLE           = "아이콘 및 색상",
        COLORS_DESC            = " 미니맵과 세계 지도에 표시할 아이콘 스타일을 선택하세요.\n 행을 클릭하면 선택됩니다 (황금색 테두리 = 활성화).",
        MINIMAP_SECTION        = "미니맵",
        REPLACE_BLIP           = "블리자드 기본 아이콘 대체",
        -- [TRANSLATE] English text changed in v2.0.0: " Since patch 12.0.7, Blizzard no longer lets addons replace\n its atlas on the minimap. FarmMap's pins are drawn on top\n of it instead (option below).",
        REPLACE_BLIP_DESC      = " 최근 시스템 업데이트로 인해 미니맵의 기본 지도 아이콘을 대체할 수 없습니다.\n 사용자 지정 핀은 세계 지도에만 표시됩니다.",
        SHOW_MINIMAP_PINS      = "미니맵에 핀 표시",
        HIDE_NEARBY_MINIMAP_PINS = "Hide nearby pins",  -- [TRANSLATE]
        HIDE_NEARBY_MINIMAP_PINS_RADIUS = "Hide pins within",  -- [TRANSLATE]
        SHOW_MINIMAP_BUTTON    = "FarmMap 미니맵 버튼 표시",
        MINIMAP_BTN_LEFT       = "좌클릭: 옵션 열기",
        MINIMAP_BTN_RIGHT      = "우클릭: 디버그 창 표시/숨기기",
        WORLDMAP_SECTION       = "세계 지도",
        PRESET_BLANK           = "흰색 테두리",
        PRESET_VIVID           = "선명한 색상",
        PRESET_ATLAS           = "기본 아이콘",
        PRESET_DEUT            = "녹색맹",
        PRESET_PROT            = "적색맹",
        PRESET_TRIT            = "청색맹",

        STATS_TITLE            = "채집 통계",
        STATS_DESC             = " 애드온 설치 이후의 총 채집 횟수입니다. DB를 가져오더라도 이 데이터는 삭제되지 않습니다.",
        STATS_RESET            = "통계 초기화",
        STATS_RESET_DONE       = "통계가 초기화되었습니다.",
        STATS_TOTAL            = "합계",

        TYPE_Herbo             = "약초채집",
        TYPE_Minage            = "채광",
        TYPE_Peche             = "낚시",
        TYPE_Bois              = "벌목",
        TYPE_HerboR            = "풍부한 약초",
        TYPE_MinageR           = "풍부한 광석",
        TYPE_PecheR            = "풍부한 낚시터",

        SKILL_MISSING          = "|cffff4444전문 기술 미습득|r",
        TOGGLE_ON              = "|cff00ff00활성화됨|r",
        TOGGLE_OFF             = "|cffff4444비활성화됨|r",
        TOGGLE_HINT            = "클릭하여 활성화/비활성화",
        EXPANSION              = "확장팩",

        EXPORT_TITLE           = "DB 내보내기",
        EXPORT_HINT            = " Ctrl+A로 전체 선택 후 Ctrl+C로 복사하세요.",
        IMPORT_TITLE           = "DB 가져오기",
        IMPORT_WARN            = "|cffff8800\226\154\160 가져오는 노드는 기존 DB에 병합됩니다.|r",
        IMPORT_BTN             = "가져오기",
        IMPORT_SUCCESS         = "개의 노드를 성공적으로 가져왔습니다.",
        IMPORT_ERROR           = "오류",
        IMPORT_DONE            = "가져오기 완료 - ",
        IMPORT_DONE2           = "개의 노드가 추가되었습니다.",
        CLOSE                  = "닫기",
        PROF_DISABLED          = " 전문 기술 미감지 - 표시 비활성화.",

        DEBUG_TITLE            = "FarmMap.debug",
        DEBUG_CAPTURE          = " 캡처",
        DEBUG_CLEAR            = "초기화",
        DEBUG_COPY             = "복사",
        DEBUG_COPY_TITLE       = "디버그 로그 복사 (Ctrl+A, Ctrl+C)",
		
		-- 명령어당 하나의 키: 나중에 추가된 명령어는 
        -- 아직 업데이트되지 않은 언어의 경우 목록에서 사라지는 대신 
        -- 영어로 표시됩니다.
        SLASH_HELP_TITLE     = "|cffffd100=== FarmMap — 명령어 ===|r",
        SLASH_CMD_HELP       = "이 도움말 표시",
        SLASH_CMD_DEBUG      = "디버그 창 표시/숨기기",
        SLASH_CMD_EXPORT     = "DB 내보내기 창 열기",
        SLASH_CMD_IMPORT     = "DB 가져오기 창 열기",
        SLASH_CMD_CLEAR      = "DB 초기화",
        SLASH_CMD_STATS      = "대화창에 통계 표시",
        SLASH_CMD_MIGRATE    = "강제 DB 갱신",
        SLASH_CMD_ATLAS      = "아이콘 아틀라스 보정기 (개발자 도구)",
        SLASH_CMD_DEFAULT    = "게임 클라이언트 언어로 되돌리기",
        SLASH_CMD_VERSION    = "애드온 버전 표시",

        SLASH_VERSION        = "버전",
        SLASH_CLEAR_CONFIRM  = "명령어를 통해 DB가 초기화되었습니다.",
        SLASH_UNKNOWN        = "알 수 없는 명령어입니다. /fm help를 입력하세요.",
        SLASH_CONFLICT       = "|cffff8800%s님도 /fm 명령어를 사용 중입니다|r - 대신 FarmMap이 |cffffffff%s|r의 응답을 처리합니다.",
        SLASH_DEFAULT_DONE   = "게임 클라이언트 언어로 재설정되었습니다. 적용하려면 /reload를 입력하세요.",

        MIGR_PREFIX          = "FarmMap DB 갱신:",
        MIGR_DONE            = "DB가 최신 상태입니다.",
        MIGR_TOTAL           = "DB 갱신 완료 —",
        MIGR_ENTRIES         = "개의 항목이 수정되었습니다.",
        UNKNOWN              = "알 수 없음",
        UNKNOWN_EXP          = "알 수 없음",

        LANG_SECTION         = "언어",
        LANG_DESC            = " 강제 언어 설정 (게임 언어보다 우선 적용됩니다). 새로고침이 필요합니다.",
        LANG_AUTO            = "자동 (시스템)",
        LANG_RELOAD          = "|cffff8800언어가 변경되었습니다. 적용하려면 /reload를 입력하세요.|r",
        LANG_THANKS          = "애드온 번역에 기여해 주신 분들께 감사드립니다",

        PANEL_COLORS         = "색상",
        PANEL_PACKS          = "팩",
        PANEL_STATS          = "통계",
        PACKS_TITLE          = "아이콘 팩",
        PACKS_DESC           = " 설치된 하위 애드온의 스타일입니다.\n 팩을 선택하면 색상 설정의 활성 프리셋이 비활성화됩니다(그 반대의 경우도 마찬가지).",
        PACKS_EMPTY          = "|cffaaaaaa 설치된 팩이 없습니다.\n 여기에 팩을 표시하려면 FarmMap_* 하위 애드온을 설치하세요.|r",

        -- 노드 툴팁에 표시되는 확장팩 이름입니다.
        --
        -- 의도적으로 주석 처리된 상태로 둡니다. FarmMap은 블리자드가 제공하는
        -- EXPANSION_NAME<id> 전역 변수를 읽어오며, 이는 모든 게임 클라이언트에
        -- 이미 번역되어 있습니다. 따라서 한국어 플레이어는 누군가 따로 번역하지 않아도
        -- 공식 한국어 명칭을 볼 수 있습니다. 여기에 주석을 해제하면 이 언어에서만
        -- 블리자드의 명칭을 덮어쓰게 되므로, 마음에 들지 않는 표현이 있을 때만
        -- 해당 줄만 수정하고 나머지는 그대로 두세요.
        --
        -- EXP_0  = "클래식",
        -- EXP_1  = "불타는 성전",
        -- EXP_2  = "리치 왕의 분노",
        -- EXP_3  = "대격변",
        -- EXP_4  = "판다리아의 안개",
        -- EXP_5  = "드레노어의 전쟁군주",
        -- EXP_6  = "군단",
        -- EXP_7  = "격전의 아제로스",
        -- EXP_8  = "어둠땅",
        -- EXP_9  = "용군단",
        -- EXP_10 = "내부 전쟁",
        -- EXP_11 = "미드나이트",

        -- /fm atlas — 아이콘 아틀라스 보정기. 우선순위 낮음: 자체 아이콘
        -- 팩을 제작하는 사용자를 위한 개발자 도구입니다.
        ATLAS_TITLE            = "FarmMap - 아틀라스 보정 (ObjectIconsAtlas)",
        ATLAS_HINT             = "아이콘을 좌클릭 후 드래그하여 위치를 변경할 수 있습니다. 크기는 (32x32)로 고정되며 위치만 이동합니다.",
        ATLAS_PRINT            = "테이블 복사",
        ATLAS_RESET            = "초기화",
        ATLAS_COPY_TITLE       = "FarmMap - 아틀라스 좌표",
        ATLAS_COPY_HINT        = "선택 완료됨: Ctrl+C를 눌러 복사한 뒤, WORLD_MAP_TEXCOORDS (및 BUILTIN_PINS)에 붙여넣으세요.",

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
        UI_TOOLTIP_ICON        = "Node icon in the tooltip",  -- [TRANSLATE]
        UI_TOOLTIP_ICON_DESC   = "Shows the icon of the pin you hover at the top right of its tooltip, in the style chosen for that map.",  -- [TRANSLATE]
    },
}
