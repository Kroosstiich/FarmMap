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
        HIDE_NEARBY_MINIMAP_PINS = "주변 미니맵 핀 숨기기",
        HIDE_NEARBY_MINIMAP_PINS_RADIUS = "핀 숨기기 반경",
        UNIT_YARDS             = "%d야드",
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
        SLASH_HELP_TITLE     = "|cffffd100=== FarmMap - 명령어 ===|r",
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
        MIGR_TOTAL           = "DB 갱신 완료 -",
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
        CREDITS_GAME           = "World of Warcraft",
        CLIENT_FOREVER         = "영구",
        VERSION_NOTICE         = "길드나 파티에서 더 새로운 버전이 발견되면 알림",
        UPDATE_AVAILABLE       = "더 새로운 버전을 사용할 수 있습니다: %s (현재 버전 %s). 가능한 한 빨리 애드온을 업데이트해 주세요.",
        INTEG_SECTION          = "통합 기능",
        INTEG_DESC             = "FarmMap과 연동되는 다른 애드온들입니다(설치된 경우). 필수 사항은 아닙니다.",
        INTEG_DETECTED         = "감지됨",
        INTEG_MISSING          = "설치되지 않음",
        INTEG_AUCTIONATOR_DESC = "플로팅 텍스트(화면에 뜨는 글자)에 수확물의 가치를 표시합니다. 가격은 Auctionator 자체 데이터베이스에서 가져오므로, 경매장을 최소 한 번은 스캔해야 합니다.",
        INTEG_NEEDS_FLOAT      = "(디스플레이 설정에서 플로팅 텍스트를 켜세요)",
        INTEG_TSM_DESC         = "수확물 가치를 확인하는 또 다른 출처입니다. TSM의 가격은 게임과 함께 설치된 TSM 앱에서 가져오므로, 해당 서버의 가격이 최신 상태로 유지되도록 앱을 계속 실행해 두세요.",
        INTEG_TOMTOM_DESC      = "지도나 미니맵의 노드를 클릭하면 해당 위치에 TomTom 방향 점이 설정되며, 화살표가 길을 안내합니다.",
        INTEG_WAYPOINTUI_DESC  = "지도나 미니맵의 노드를 클릭하면 WaypointUI가 길을 안내합니다. TomTom도 함께 설치되어 있다면 FarmMap이 어느 애드온을 사용할지 아래에서 선택하세요.",
        UI_WINDOW_SCALE        = "창 크기",
        UI_WINDOW_SCALE_DESC   = "설정 및 업데이트 내역 창의 크기를 키우거나 줄입니다. 이 게임 클라이언트에만 설정됩니다: 클라이언트마다 각각의 인터페이스 크기를 가집니다.",
        UI_WAYPOINT_ADDON      = "네비게이션 애드온",
        UI_WAYPOINT_ADDON_DESC = "두 애드온이 모두 설치되어 있습니다: 노드를 클릭할 때 어느 애드온으로 방향 점을 생성할지 선택하세요. TomTom을 사용하더라도 WaypointUI의 \"TomTom 방향 점 추적\" 옵션이 켜져 있다면 WaypointUI에도 방향 점이 함께 표시됩니다. TomTom만 단독으로 사용하려면 WaypointUI 설정에서 이 옵션을 끄세요.",
        WAYPOINT_CLICK_TIP     = "클릭: %s 방향 점 생성 (다시 클릭하면 제거)",
        PRESET_BLIZZARD        = "본섭 (Retail)",
        PRESET_RING            = "클래식 링",
        PRESET_RING_COLOR      = "클래식 링, 색상형",
        PACKS_MORE             = "CurseForge에서 더 많은 아이콘 팩을 사용할 수 있습니다:",
        PACKS_COPY_HINT        = "주소를 클릭한 다음 Ctrl+C를 누르세요",
        PACKS_OWN              = "직접 만들 수도 있습니다: 어떤 애드온이든 FarmMapStyles.Register를 통해 스타일을 추가할 수 있습니다.\nGitHub의 README를 참고하세요.",
        UI_TITLE               = "설정",
        UI_SEARCH              = "설정 검색…",
        UI_SETTINGS            = "설정",
        UI_NEWS                = "업데이트 내역",
        UI_NEWS_DESC           = "현재 버전 시리즈의 변경 사항 목록입니다.",
        UI_CREDITS             = "제작진",
        UI_CREDITS_DESC        = "제작자, 번역가 및 기여자 분들입니다.",
        UI_DASH                = "대시보드",
        UI_DASH_DESC           = "현재 채집 세션 정보이며, 수확할 때마다 업데이트됩니다.",
        UI_NODES               = "노드 목록",
        UI_NODES_DESC          = "기록된 모든 노드입니다: 검색, 필터링, 일괄 삭제가 가능합니다.",
        UI_ICONS               = "지도 및 아이콘",
        UI_ICONS_DESC          = "미니맵과 세계 지도에 표시될 아이콘의 스타일입니다.",
        UI_THEME               = "테마",
        UI_THEME_DESC          = "이 창의 색상입니다. 플레이어가 직접 만들어 공유할 수도 있습니다.",
        UI_DISPLAY             = "디스플레이",
        UI_DISPLAY_DESC        = "플로팅 텍스트, 필터 바, 아이콘 크기 설정입니다.",
        UI_INTEG               = "통합 기능",
        UI_INTEG_DESC          = "FarmMap과 연동되는 다른 애드온들입니다(설치된 경우).",
        UI_IO                  = "가져오기 / 내보내기",
        UI_IO_DESC             = "노드 데이터베이스를 공유하고, 최종 확인 전에 가져올 데이터에 무엇이 추가되는지 확인합니다.",
        UI_LANG                = "언어",
        UI_LANG_DESC           = "FarmMap의 언어 설정이며, 게임 언어와 별개로 지정할 수 있습니다.",
        UI_DEBUG               = "디버그",
        UI_DEBUG_DESC          = "진단 창과 관련 옵션입니다.",
        UI_RELOAD              = "UI 재적용",
        DISPLAY_NEW_WINDOW     = "새로운 설정 창 사용",
        DISPLAY_NEW_WINDOW_DESC = "체크하면 미니맵 버튼을 눌렀을 때 FarmMap 전용 설정 창이 열립니다. 체크를 해제하면 게임 기본 '애드온' 설정 메뉴의 레거시 패널이 열립니다. UI를 재적용한 후에 반영됩니다.",
        DISPLAY_NEW_WINDOW_RELOAD = "이 변경 사항을 적용하려면 인터페이스를 재적용(Reload)하세요.",
        UI_LINK_HINT           = "Ctrl+C로 복사, Escape로 닫기",
        UI_SOON                = "이 페이지는 다음 테스트 빌드에 추가될 예정입니다.",
        UI_NO_MATCH            = "일치하는 페이지가 없습니다.",
        UI_THEME_BY            = "제작: %s",
        UI_THEME_OWN_TITLE     = "애드온 형태의 테마",
        UI_THEME_OWN           = "애드온 제작용 안내: 테마는 아이콘 팩처럼 별도의 작은 애드온(FarmMapThemes.Register)으로 배포할 수 있습니다. 다른 테마들과 마찬가지로 상단의 색상만 변경할 뿐 다른 것은 바꾸지 않습니다. 아이콘은 아이콘 팩을 통해 변경되고 크기, 여백, 레이아웃은 고정되므로 테마 때문에 창이 깨질 염려는 없습니다.",
        UI_THEME_MINE          = "내 테마",
        UI_THEME_NEW_NAME      = "나의 테마 %d",
        UI_THEME_DELETE        = "이 테마 삭제",
        UI_THEME_DELETE_CONFIRM = "삭제하려면 × 버튼을 한 번 더 클릭하세요",
        UI_THEME_CUSTOM_TITLE  = "사용자 정의",
        UI_THEME_LOCKED        = "FarmMap에 기본 포함되어 있거나 다른 애드온에서 가져온 테마는 변경할 수 없습니다. 색상을 수정하려면 복사본을 만드세요. 복사본은 별도의 파일 생성 없이 FarmMap 설정에 저장됩니다.",
        UI_THEME_EDIT_TITLE    = "“%s” 편집",
        UI_THEME_EDIT          = "색상을 클릭하여 변경할 수 있으며, 변경 사항은 즉시 창에 반영됩니다. 직접 만든 테마는 별도의 파일 생성 없이 FarmMap 설정에 저장됩니다.",
        UI_THEME_NAME          = "이름",
        UI_THEME_COPY          = "복사본 만들기",
        UI_THEME_EXPORT        = "내보내기",
        UI_THEME_EXPORT_HINT   = "Ctrl+C로 테마 복사, Escape로 닫기",
        UI_THEME_EXPORT_ROW    = "테마 내보내기",
        UI_THEME_EXPORT_DESC   = "현재 활성화된 테마의 색상을 다른 사람과 공유할 수 있도록 텍스트로 복사합니다. 먼저 '테마' 메뉴에서 내보낼 테마를 선택하세요.",
        UI_THEME_GRADIENT_TITLE = "Gradients",  -- [TRANSLATE]
        UI_THEME_GRADIENT_DESC = "Blend a surface into a second colour, from top to bottom. Tick a surface, then click its square to pick the bottom colour.",  -- [TRANSLATE]
        UI_THEME_GRADIENT_OFF  = "flat",  -- [TRANSLATE]
        UI_THEME_IMPORT_TITLE  = "“%s” 테마",
        UI_THEME_IMPORT_DESC   = "테마는 이 창의 색상만 변경할 뿐, 아이콘을 포함한 다른 요소는 변경하지 않습니다. 내 테마 목록에 추가되며 즉시 적용됩니다.",
        UI_THEME_IMPORT_GO     = "테마 가져오기",
        UI_THEME_IMPORT_DONE   = "“%s” 테마를 가져와서 적용했습니다.",
        UI_THEME_IMPORT_BAD    = "올바른 FarmMap 테마 텍스트가 아니거나, 일부 데이터가 누락되었습니다.",
        UI_TOKEN_BG            = "창 배경",
        UI_TOKEN_PANEL         = "패널",
        UI_TOKEN_PANEL2        = "패널 (2단계)",
        UI_TOKEN_LINE          = "테두리",
        UI_TOKEN_ACCENT        = "강조 색상",
        UI_TOKEN_ACCENTSOFT    = "강조 색상 (은은하게)",
        UI_TOKEN_TEXT          = "텍스트",
        UI_TOKEN_DIM           = "보조 텍스트",
        UI_TOKEN_FAINT         = "흐린 텍스트",
        UI_TOKEN_GOOD          = "긍정적 (성공/안전)",
        UI_TOKEN_WARN          = "경고",
        UI_TOKEN_BAD           = "부정적 (실패/위험)",
        UI_TRANSLATORS         = "번역진",
        UI_CONTRIBUTORS        = "기여자",
        UI_CREDIT_TEAM         = "FarmMap 팀",
        UI_CREDIT_INFO         = "정보",
        UI_CREDIT_CODE         = "코드 및 아이디어",
        UI_CREDIT_TESTERS      = "테스터",
        UI_LANG_CHOICE         = "FarmMap 언어",
        LANG_RELOAD_PLAIN      = "언어가 변경되었습니다: 변경 사항을 적용하려면 인터페이스를 재적용(Reload)하세요.",
        UI_LANG_CHOICE_DESC    = "'자동'으로 설정하면 게임 언어를 따릅니다. 다른 언어를 선택하면 FarmMap의 모든 텍스트가 해당 언어로 고정되지만, 아이템 및 지역 이름은 게임의 언어로 유지됩니다. UI를 재적용한 후에 반영됩니다.",
        UI_SEC_GENERAL         = "일반 설정",
        UI_VERSION_NOTICE      = "새 버전 알림",
        UI_VERSION_NOTICE_DESC = "길드원이나 파티원 중 누군가 더 최신의 FarmMap 버전을 사용하고 있다면 채팅창에 안내선이 표시됩니다 (세션당 1회).",
        UI_SEC_FLOAT           = "플로팅 텍스트",
        UI_FLOAT               = "수확 시 플로팅 텍스트 표시",
        UI_FLOAT_DESC          = "수확할 때마다 캐릭터 위에 텍스트가 뜹니다: 채집한 아이템, 현재 소지 개수, 그리고 Auctionator나 TSM이 설치되어 있다면 해당 아이템의 가치를 보여줍니다.",
        UI_FLOAT_TIER          = "품질 등급 아이콘",
        UI_FLOAT_TIER_DESC     = "제작 재료의 이름 옆에 품질 등급 아이콘을 함께 표시합니다.",
        UI_FLOAT_SIZE          = "글꼴 크기",
        UI_FLOAT_DURATION      = "화면 표시 시간",
        UI_SEC_FILTERBAR       = "세계 지도 필터 바",
        UI_FILTERBAR_HINT      = "Shift 키를 누른 채 드래그하여 바를 이동할 수 있고, Shift + 우클릭으로 가로/세로 방향을 전환할 수 있습니다.",
        UI_FILTERBAR_SIZE      = "버튼 크기",
        UI_FILTERBAR_ALPHA     = "커서가 없을 때의 불투명도",
        UI_FILTERBAR_RESET     = "바 위치 초기화",
        UI_FILTERBAR_RESET_DESC = "필터 바를 세계 지도의 기본 모서리 위치로 되돌립니다.",
        UI_SEC_WORLDPINS       = "세계 지도 노드 아이콘",
        UI_WORLDPIN_SIZE       = "아이콘 크기",
        UI_NODE_ITEMS          = "노드 툴팁에 수확한 아이템 표시",
        UI_SEC_STYLES          = "아이콘 스타일",
        UI_STYLE_MINIMAP       = "미니맵",
        UI_STYLE_WORLDMAP      = "세계 지도",
        UI_STYLE_PACK          = "팩",
        UI_SEC_MINIMAP         = "미니맵 설정",
        UI_MINIMAP_PINS        = "미니맵에 FarmMap 핀 표시",
        UI_MINIMAP_PINS_DESC   = "체크를 해제하면 기록된 노드가 세계 지도에만 표시됩니다.",
        UI_MINIMAP_HIDE_NEARBY = "근처 핀 숨기기",
        UI_MINIMAP_HIDE_NEARBY_DESC = "미니맵을 깔끔하게 유지하기 위해 설정한 거리 이내의 핀들을 숨깁니다.",
        UI_MINIMAP_HIDE_NEARBY_RADIUS = "핀 숨김 반경",
        UI_MINIMAP_BUTTON      = "미니맵 버튼",
        UI_MINIMAP_BUTTON_DESC = "좌클릭으로 이 설정 창을 열고, 우클릭으로 디버그 창을 엽니다.",
        -- Optimal route (2.2): filter bar button and guidance.
        ROUTE_TITLE            = "Route",  -- [TRANSLATE]
        ROUTE_HINT             = "Click: show or hide the route through the known nodes of the zone shown, for the filters that are on.",  -- [TRANSLATE]
        ROUTE_SKIP_HINT        = "Shift-click: move the guidance's waypoint to the next node of the route.",  -- [TRANSLATE]
        ROUTE_INFO             = "Loop: %s nodes, about %s.",  -- [TRANSLATE]
        ROUTE_CAPPED           = "The %d most harvested nodes of the zone.",  -- [TRANSLATE]
        ROUTE_NONE             = "No route here: it needs at least 2 known nodes in this zone, for the filters that are on.",  -- [TRANSLATE]
        UI_ROUTE_GUIDE         = "Guide me along the route",  -- [TRANSLATE]
        UI_ROUTE_GUIDE_DESC    = "After each harvest of a node of the route, the TomTom or WaypointUI waypoint moves to the next node of the loop. Shift-click the Route button to skip a node. The route itself is shown with its button on the world map's filter bar.",  -- [TRANSLATE]
        SETUP_ROUTE_GUIDE_TITLE = "Guidance along the route",  -- [TRANSLATE]
        SETUP_ROUTE_GUIDE_TEXT  = "The Route button of the world map's filter bar draws a loop through the known nodes of the zone, on the world map and the minimap. FarmMap can also guide you from one node to the next with TomTom or WaypointUI.",  -- [TRANSLATE]
        SETUP_ROUTE_GUIDE_ON    = "After each harvest of a route node, the waypoint moves to the next node. Shift-click the Route button to skip a node someone else already took.",  -- [TRANSLATE]
        SETUP_ROUTE_GUIDE_OFF   = "The route is only drawn; you set your own waypoints.",  -- [TRANSLATE]
        ROUTE_TIME             = "Estimated lap: about %s (%s)",  -- [TRANSLATE]
        ROUTE_SPEED_BASE       = "ground mount speed",  -- [TRANSLATE]
        ROUTE_SPEED_MEASURED   = "your measured speed",  -- [TRANSLATE]
        UI_SEC_ROUTE           = "Route",  -- [TRANSLATE]
        UI_ROUTE_HINT          = "The Route button of the world map's filter bar draws a loop through the known nodes of the zone shown. These settings shape it.",  -- [TRANSLATE]
        UI_ROUTE_DIR           = "Direction",  -- [TRANSLATE]
        UI_ROUTE_DIR_DESC      = "The way the loop runs, and the guidance with it.",  -- [TRANSLATE]
        ROUTE_CW               = "Clockwise",  -- [TRANSLATE]
        ROUTE_CCW              = "Anticlockwise",  -- [TRANSLATE]
        UI_ROUTE_MAXTIME       = "Longest lap",  -- [TRANSLATE]
        UI_ROUTE_MAXTIME_DESC  = "The route keeps as many nodes as fit in this time, the most harvested first. Estimated with your measured speed.",  -- [TRANSLATE]
        ROUTE_NO_LIMIT         = "No limit",  -- [TRANSLATE]
        UI_ROUTE_NEW           = "Another route",  -- [TRANSLATE]
        UI_ROUTE_NEW_DESC      = "Draws another loop through the same nodes of your zone, different from the last ones when the nodes allow it.",  -- [TRANSLATE]
        ROUTE_NEW_LABEL        = "Another route",  -- [TRANSLATE]
        SESSION_DIR_TIP        = "Click to reverse the route's direction.",  -- [TRANSLATE]
        SESSION_NEW_TIP        = "Click to draw another route through the same nodes.",  -- [TRANSLATE]
        ROUTE_DIR_CW           = "Direction: clockwise",  -- [TRANSLATE]
        ROUTE_DIR_CCW          = "Direction: anticlockwise",  -- [TRANSLATE]
        ROUTE_GUIDE_FROM_HERE  = "Guide me along the route from here",  -- [TRANSLATE]
        ROUTE_GUIDE_STOP       = "Stop guiding me along the route",  -- [TRANSLATE]
        SESSION_GUIDE_ON       = "Route guidance: on",  -- [TRANSLATE]
        SESSION_GUIDE_OFF      = "Route guidance: off",  -- [TRANSLATE]
        SESSION_GUIDE_TIP      = "Click to turn the guidance along the route on or off. On, the route is shown too, and the TomTom or WaypointUI waypoint moves to the next node after each harvest.",  -- [TRANSLATE]
        UI_SEC_PACKS           = "아이콘 팩",
        UI_PACKS_DESC          = "아이콘 팩은 별도의 작은 애드온입니다. 설치하면 해당 스타일이 위 목록에 추가됩니다. CurseForge에서 더 많은 팩을 찾아보거나 FarmMapStyles.Register를 사용하여 직접 만들 수도 있습니다 (GitHub의 README 파일 참조).",
        UI_PROFIT              = "플로팅 텍스트에 수확물 가치 표시",
        UI_PROFIT_DESC         = "채집 시 각 수확물이 경매장에서 얼마의 가치를 가졌는지 표시합니다.",
        UI_PROFIT_NEEDS_AUC    = "경매장 애드온 필요 [Auctionator/TSM]",
        UI_PROFIT_NEEDS_FLOAT  = "디스플레이 설정에서 플로팅 텍스트를 먼저 켜세요.",
        UI_SEC_PRICES          = "수확물 가치 설정",
        UI_SEC_WAYPOINTS       = "내비게이션",
        UI_PRICE_SOURCE        = "가격 출처",
        UI_PRICE_SOURCE_DESC   = "두 애드온이 모두 설치되어 있습니다: 수확물 가치를 평가할 기준 애드온을 선택하세요.",
        UI_TSM_PRICE           = "TSM 가격 기준",
        UI_TSM_PRICE_DESC      = "수확물 가치를 평가하는 데 사용할 TSM 가격 기준입니다.",
        UI_TSM_DBMarket        = "시장 가격 (서버)",
        UI_TSM_DBMinBuyout     = "최저 즉시구입가 (서버)",
        UI_TSM_DBRegionMarketAvg = "평균 시장 가격 (지역)",
        UI_WAYPOINT_CLICK      = "클릭 시 방향 점 생성",
        UI_WAYPOINT_CLICK_DESC = "노드를 클릭하면 TomTom 또는 WaypointUI를 통해 방향 점을 설정하고, 다시 클릭하면 제거합니다. 이 방향 점들은 다음 게임 접속(세션)까지 유지되지 않습니다.",
        UI_INTEG_ASK_TITLE     = "다른 애드온 연동이 필요하신가요?",
        UI_INTEG_ASK           = "FarmMap과 연동되면 좋을 다른 애드온을 사용 중이신가요? Discord에 건의해 주세요: 연동 기능은 플레이어분들의 요청에 따라 추가됩니다.",
        UI_EXPORT_DESC         = "다른 사람과 공유할 수 있도록 노드 데이터베이스를 텍스트로 복사합니다.",
        UI_AGO_NOW             = "방금 전",
        UI_AGO_MIN             = "%d분 전",
        UI_AGO_H               = "%d시간 전",
        UI_DUR_MIN             = "%d분",
        UI_DUR_H               = "%d시간 %02d분",
        UI_DASH_TIME           = "진행 시간",
        UI_DASH_TIME_SUB       = "이번 세션",
        UI_DASH_NODES          = "수확한 노드 수",
        UI_DASH_PER_HOUR       = "시간당 %d개",
        UI_DASH_VALUE          = "수확한 가치",
        UI_DASH_VALUE_SUB      = "%s 가격 기준",
        UI_DASH_GPH            = "시간당 골드",
        UI_DASH_GPH_SUB        = "현재 속도 기준",
        UI_DASH_BYTYPE         = "자원별 현황",
        UI_DASH_RECENT         = "최근 수확 내역",
        UI_DASH_RECENT_EMPTY   = "이번 세션에는 아직 수확한 내역이 없습니다.",
        UI_DASH_RESET          = "세션 초기화",
        UI_DASH_RESET_DESC     = "지금 새로운 세션을 시작합니다. 로그아웃 후 15분이 지나면 자동으로 새 세션이 시작되며, /reload(UI 재적용) 시에는 세션이 유지됩니다.",
        UI_NODES_SEARCH        = "아이템 또는 지역 이름 (예: 평온초)",
        UI_NODES_ALL_ZONES     = "모든 지역",
        UI_NODES_WHERE         = "\"%s\" 발견 장소",
        UI_NODES_WHERE_LINE    = "%s - %d회 수확, 노드 %d개",
        UI_NODES_COL_ITEM      = "아이템",
        UI_NODES_COL_ZONE      = "지역",
        UI_NODES_COL_NODES     = "노드",
        UI_NODES_COL_HARVESTS  = "수확 횟수",
        UI_NODES_MORE          = "%d개의 항목이 더 있습니다: 검색어를 좁혀보세요.",
        UI_NODES_NONE          = "일치하는 노드가 없습니다.",
        UI_NODES_DELETE        = "%d개 항목 삭제",
        UI_NODES_DELETE_NAME   = "선택 항목 삭제",
        UI_NODES_DELETE_DESC   = "지도에서 선택한 노드들을 제거합니다. 수확 통계는 그대로 유지됩니다.",
        UI_NODES_DELETED       = "%d개의 노드가 삭제되었습니다.",
        UI_IMPORT_PASTE        = "다른 플레이어의 내보내기 텍스트나 테마를 아래에 붙여넣은 뒤 '분석'을 누르세요. 최종 확인 전까지는 아무것도 가져오지 않습니다.",
        UI_IMPORT_ANALYSE      = "분석",
        UI_IMPORT_CLEAR        = "초기화",
        UI_IMPORT_PREVIEW      = "가져오기 미리보기",
        UI_IMPORT_SUMMARY      = "새 노드 %d개, 이미 알고 있는 노드 %d개 (제외됨). 아직 실제 가져오기가 수행되지 않았습니다.",
        UI_IMPORT_INVALID      = "읽을 수 없는 항목 %d개는 제외되었습니다.",
        UI_IMPORT_COL_NEW      = "신규",
        UI_IMPORT_COL_KNOWN    = "이미 아는 노드",
        UI_IMPORT_GO           = "노드 %d개 가져오기",
        UI_IMPORT_CANCEL       = "취소",
        UI_IMPORT_DONE         = "%d개의 노드를 가져왔습니다.",
        UI_IMPORT_OTHER_CLIENT = "이 데이터는 %s에서 내보낸 것이며 현재 사용 중인 클라이언트는 %s입니다. 게임 클라이언트마다 지도 ID가 다르므로, 해당 노드들이 이 클라이언트에 존재하지 않는 지도에 배치될 수 있습니다.",
        UI_PACK_INSTALLED      = "설치됨",
        UI_CL_NEW              = "새로운 기능",
        UI_CL_CHANGED          = "변경 사항",
        UI_CL_FIXED            = "수정 사항",
        UI_CL_REMOVED          = "삭제된 기능",
        UI_CL_SKIPPED          = "마지막 방문 이후 변경 사항",
        UI_CL_UNREAD           = "읽지 않음",
        UI_CL_IN_ENGLISH       = "영어 원문",
        UI_CL_OLDER            = "이전 버전",
        UI_CL_SHOW_OLDER       = "이전 변경 사항 표시",
        UI_CL_HIDE_OLDER       = "이전 변경 사항 숨기기",
        UI_CL_INTRO            = "FarmMap이 %s 버전으로 업데이트되었습니다. 변경된 내용은 다음과 같습니다.",
        UI_CL_OPEN_OPTIONS     = "설정 열기",
        UI_DASH_SESSION        = "세션 정보",
        UI_DASH_MINI           = "미니 세션 창",
        UI_DASH_MINI_DESC      = "설정 창을 열지 않고도 원하는 위치에 이동시켜 배치할 수 있는 작은 창에 이 4가지 수치를 표시합니다.",
        UI_SEC_LIFETIME        = "설치 이후 누적",
        UI_DASH_LIFETIME       = "설치 이후 총 수확 횟수",
        UI_STATS_RESET_DESC    = "모든 수확 횟수 카운터를 초기화합니다: 누적 총합, 노드별 기록(지역 요약, 노드 페이지의 수확 횟수) 및 현재 세션이 포함됩니다. 지도상의 노드는 삭제되지 않고 유지됩니다.",
        UI_DEBUG_WINDOW        = "디버그 창",
        UI_DEBUG_WINDOW_DESC   = "문제를 제보할 수 있도록 FarmMap이 수확할 때마다 인식하는 정보를 표시합니다. 미니맵 버튼을 우클릭해도 열 수 있습니다.",
        UI_DEBUG_CAPTURE       = "디버그 기록 활성화",
        UI_DEBUG_CAPTURE_DESC  = "체크를 해제하면 FarmMap이 디버그 창에 아무런 기록도 남기지 않습니다.",
        UI_DB_MIGRATE          = "데이터베이스 복구",
        UI_DB_MIGRATE_DESC     = "데이터 삭제 없이 오래된 이전 항목들을 복구하고 수정합니다.",
        UI_DB_CLEAR_DESC       = "기록된 모든 노드를 삭제합니다. 개인 설정과 통계 데이터는 유지됩니다.",
        UI_DB_CLEAR_CONFIRM    = "정말 삭제하시려면 한 번 더 클릭하세요",
        UI_LANG_HELP_TITLE     = "사용하시는 언어가 없나요?",
        UI_LANG_HELP           = "FarmMap은 플레이어들의 참여로 번역되며, 일부만 번역된 상태에서도 작동합니다(번역되지 않은 텍스트는 영어로 유지됨). lang/enUS.lua 파일을 복사하여 따옴표 안의 텍스트를 번역한 뒤 Discord나 GitHub로 파일을 보내주세요.",
        UI_ROLE_AUTHOR         = "제작자",
        UI_CONTRIB_BUSEQ       = "수확물 가치 표시 기능",
        UI_CONTRIB_CRAZY       = "아이디어: 이동 가능한 필터 바 및 크기 조절, 확장팩 이름 번역",
        UI_CONTRIB_R0S0J       = "아이디어: 세계 지도 아이콘 크기 조절, 지역 요약",

        -- v2.0.0, added later (Sakura pack, filter bar): [TRANSLATE] = still English.
        UI_THEME_SITE_TIP      = "클릭하면 제작자의 사이트 링크를 복사합니다.",
        UI_CREDIT_ART          = "일러스트레이션",
        UI_FILTERBAR_ICONS     = "필터 바에 스타일 아이콘 표시",
        UI_FILTERBAR_ICONS_DESC = "체크하면 필터 바의 버튼들이 세계 지도용으로 선택된 스타일(아이콘 팩 포함)의 아이콘으로 표시되어 지도와 일치하게 됩니다. 링 스타일을 사용하거나 기능을 끄면 기본 아이콘으로 유지됩니다.",
        UI_CONTRIB_SOREL       = "FarmMap 아이콘 및 Sakura 팩 제작 (soreldesign.fr)",
        UI_CONTRIB_FIOTE       = "미니맵에서 근처 핀 숨기기 기능",

        -- Setup assistant (UI\Setup.lua): one setting per screen.
        SETUP_TITLE            = "초기 설정",
        SETUP_STEP             = "%d / %d",
        SETUP_ON               = "켜기",
        SETUP_OFF              = "끄기",
        SETUP_NEXT             = "다음",
        SETUP_PREV             = "이전",
        SETUP_DONE             = "완료",
        SETUP_SKIP             = "건너뛰기",
        SETUP_HINT             = "모든 설정은 나중에 옵션에서 변경할 수 있습니다. 이 도우미를 다시 실행하려면 /fm setup 을 입력하세요.",
        SETUP_WELCOME_TITLE    = "FarmMap에 오신 것을 환영합니다",
        SETUP_WELCOME_TEXT     = "FarmMap을 사용해 주셔서 감사합니다! 이 도우미를 통해 주요 설정을 화면별로 하나씩 안내해 드립니다.\n\n문제나 질문이 있으신가요? FarmMap Discord에 가입하시거나 CurseForge 페이지에 댓글을 남겨주세요. Discord에서 훨씬 더 빠르게 답변해 드립니다.",
        SETUP_WELCOME_DISCORD  = "Discord 링크",
        SETUP_NEVER            = "다시 표시하지 않음",
        SETUP_NEVER_TIP        = "업데이트로 새로운 설정이 추가되더라도 도우미 창이 자동으로 다시 열리지 않습니다. 다시 열고 싶다면 /fm setup 을 입력하세요.",
        SETUP_STOP             = "지금은 중단",
        SETUP_STOP_TIP         = "도우미 창을 닫습니다. 업데이트로 새로운 설정이 추가되면 해당 설정만 표시됩니다.",
        SETUP_CONTINUE         = "설정 계속하기",
        SETUP_MINIMAP_PINS_TITLE = "미니맵 핀 표시",
        SETUP_MINIMAP_PINS_TEXT  = "수확한 노드를 선택한 스타일의 아이콘으로 미니맵에 표시합니다.",
        SETUP_MINIMAP_PINS_ON    = "노드가 미니맵과 세계 지도에 모두 표시됩니다. 장시간 채집을 하면 미니맵이 꽉 찰 수 있습니다.",
        SETUP_MINIMAP_PINS_OFF   = "노드가 세계 지도에만 표시됩니다. 미니맵은 게임 기본 상태 그대로 유지됩니다.",
        SETUP_HIDE_NEARBY_TITLE  = "근처 핀 숨기기",
        SETUP_HIDE_NEARBY_TEXT   = "캐릭터 근처의 FarmMap 핀을 숨겨 미니맵의 캐릭터 화살표를 가리지 않도록 합니다. 캐릭터가 멀어지면 핀이 다시 나타납니다. fiote 님의 아이디어와 코드로 제작되었습니다.",
        SETUP_HIDE_NEARBY_ON     = "아래에서 선택한 거리 이내의 핀들이 미니맵에서 사라집니다. 가까이 다가가면 보통 게임 자체의 채집 추적 기능으로 노드가 표시됩니다.",
        SETUP_HIDE_NEARBY_ON_CLASSIC = "아래에서 선택한 거리 이내의 핀들이 미니맵에서 사라집니다. 게임에서 한 번에 한 가지 종류의 채집만 추적하는 경우, 근처에 있는 다른 종류의 노드는 아예 표시되지 않을 수 있습니다.",
        SETUP_HIDE_NEARBY_OFF    = "모든 핀이 캐릭터 바로 아래에 있더라도 미니맵에 그대로 표시됩니다.",
        SETUP_MINIMAP_BUTTON_TITLE = "미니맵 버튼",
        SETUP_MINIMAP_BUTTON_TEXT  = "미니맵 테두리에 FarmMap 버튼을 표시합니다: 좌클릭으로 설정 창을 열고, 우클릭으로 디버그 창을 엽니다.",
        SETUP_MINIMAP_BUTTON_ON    = "버튼이 미니맵에 표시됩니다. 드래그하여 테두리를 따라 이동할 수 있습니다.",
        SETUP_MINIMAP_BUTTON_OFF   = "미니맵에 버튼을 표시하지 않습니다. /fm ui 명령어로 설정 창을 열 수 있습니다.",
        SETUP_FLOAT_TITLE      = "플로팅 텍스트",
        SETUP_FLOAT_TEXT       = "수확할 때마다 캐릭터 위에 텍스트가 짧게 뜹니다: 채집한 아이템과 현재 소지 개수를 보여줍니다.",
        SETUP_FLOAT_ON         = "가방을 열지 않고도 무엇을 수확했는지 한눈에 확인할 수 있습니다.",
        SETUP_FLOAT_OFF        = "화면에 텍스트가 뜨지 않습니다. 수확 내역은 여전히 기록됩니다.",
        SETUP_PROFIT_TITLE     = "수확물 가치",
        SETUP_PROFIT_TEXT      = "Auctionator 또는 TradeSkillMaster의 가격 데이터를 사용하여 수확물이 경매장에서 얼마의 가치를 가졌는지 플로팅 텍스트에 추가합니다.",
        SETUP_PROFIT_ON        = "각 수확물의 가치가 표시됩니다. 가격은 해당 가격 애드온의 가장 최신 데이터를 기준으로 합니다.",
        SETUP_PROFIT_OFF       = "플로팅 텍스트에 가치를 제외한 아이템 정보만 표시됩니다.",
        SETUP_WAYPOINT_TITLE   = "클릭 시 방향 점 생성",
        SETUP_WAYPOINT_TEXT    = "세계 지도나 미니맵의 노드를 클릭하면 TomTom 또는 WaypointUI를 통해 해당 위치에 방향 점을 설정합니다.",
        SETUP_WAYPOINT_ON      = "클릭하면 해당 노드로 길을 안내합니다. 다시 클릭하면 방향 점이 제거됩니다.",
        SETUP_WAYPOINT_OFF     = "노드를 클릭해도 방향 점이 생성되지 않습니다. TomTom과 WaypointUI는 평소대로 작동합니다.",
        SETUP_THEME_TITLE      = "창 테마",
        SETUP_THEME_TEXT       = "이 창을 포함한 FarmMap 창들의 색상입니다. 테마를 선택하면 즉시 반영됩니다. '테마' 페이지에서 자신만의 테마를 직접 만들 수도 있습니다.",
        SETUP_STYLES_TITLE     = "아이콘 스타일",
        SETUP_STYLES_TEXT      = "미니맵과 세계 지도에 표시될 노드의 아이콘입니다. 아래 미니맵은 선택된 스타일을 보여주며, 목록의 아이콘에 마우스를 올리면 더 크게 볼 수 있습니다.",
        UI_TOOLTIP_ICON        = "툴팁에 노드 아이콘 표시",
        UI_TOOLTIP_ICON_DESC   = "마우스를 올린 핀의 아이팁 우측 상단에 해당 지도용으로 선택된 스타일의 아이콘을 표시합니다.",
    },
}
