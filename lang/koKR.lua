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

    -- 선택 사항: 번역 크레딧 아래에 표시될 링크입니다.
    -- 라벨은 자유 텍스트이며 절대 번역되지 않습니다. enUS.lua 파일을 참조하세요.
    -- (기계 번역되지 않도록 의도적으로 영어로 남겨두었습니다.)
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
        CREDITS_COPY_CLICK     = "클릭하여 복사",
        CREDITS_COPY_KEY       = "Ctrl+C를 눌러 복사",
        CREDITS_COPIED         = "복사되었습니다!",

        DB_SECTION             = "데이터베이스",
        DB_CLEAR               = "데이터베이스 초기화",
        DB_CLEARED             = "데이터베이스가 초기화되었습니다.",
        DB_MIGRATE             = "DB 데이터 최신화",
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
        DELETE_NODE            = "이 노드 삭제",
        DEBUG_SECTION          = "디버그",

        COLORS_TITLE           = "아이콘 및 색상",
        COLORS_DESC            = " 미니맵과 세계 지도에 표시할 아이콘 스타일을 선택하세요.\n 행을 클릭하면 선택됩니다 (황금색 테두리 = 활성화).",
        MINIMAP_SECTION        = "미니맵",
        REPLACE_BLIP           = "블리자드 기본 아이콘 대체",
        REPLACE_BLIP_DESC      = " 최근 시스템 업데이트로 인해 미니맵의 기본 지도 아이콘을 대체할 수 없습니다.\n 사용자 지정 핀은 세계 지도에만 표시됩니다.",
        SHOW_MINIMAP_PINS      = "미니맵에 핀 표시",
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

        EXPORT_TITLE           = "데이터베이스 내보내기",
        EXPORT_HINT            = " Ctrl+A로 전체 선택 후 Ctrl+C로 복사하세요.",
        IMPORT_TITLE           = "데이터베이스 가져오기",
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

        SLASH_HELP_TITLE       = "|cffffd100=== FarmMap - 명령어 ===|r",
        SLASH_CMD_HELP         = "이 도움말 표시",
        SLASH_CMD_DEBUG        = "디버그 창 표시/숨기기",
        SLASH_CMD_EXPORT       = "DB 내보내기 창 열기",
        SLASH_CMD_IMPORT       = "DB 가져오기 창 열기",
        SLASH_CMD_CLEAR        = "데이터베이스 초기화",
        SLASH_CMD_STATS        = "채팅창에 채집 통계 출력",
        SLASH_CMD_MIGRATE      = "DB 데이터 최신화",
        SLASH_CMD_ATLAS        = "아이콘 아틀라스 보정기 (개발자 도구)",
        SLASH_CMD_DEFAULT      = "게임 클라이언트 언어로 돌아가기",
        SLASH_CMD_VERSION      = "애드온 버전 확인",

        SLASH_VERSION          = "버전",
        SLASH_CLEAR_CONFIRM    = "명령어로 데이터베이스를 초기화했습니다.",
        SLASH_UNKNOWN          = "알 수 없는 명령어입니다. /fm help 를 입력하세요.",

        SLASH_DEFAULT_DONE     = "FarmMap 애드온 언어가 한국어로 변경되려면 /reload를 입력하세요.",

        MIGR_PREFIX            = "FarmMap 업데이트:",
        MIGR_DONE              = "데이터베이스가 최신 상태입니다.",
        MIGR_TOTAL             = "DB 업데이트 완료 -",
        MIGR_ENTRIES           = "개의 항목이 수정되었습니다.",
        UNKNOWN                = "알 수 없음",
        UNKNOWN_EXP            = "알 수 없음",

        LANG_SECTION           = "언어",
        LANG_DESC              = " 언어 강제 지정 (게임 클라이언트 언어 무시). 변경 사항을 적용하려면 UI를 다시 불러와야 합니다 (/reload).",
        LANG_AUTO              = "자동 (기본값)",
        LANG_RELOAD            = "|cffff8800언어가 변경되었습니다. 적용하려면 /reload 를 입력하세요.|r",
        LANG_THANKS            = "애드온 번역에 기여해 주신 모든 분께 감사드립니다.",

        PANEL_COLORS           = "색상",
        PANEL_PACKS            = "팩",
        PANEL_STATS            = "통계",
        PACKS_TITLE            = "아이콘 팩",
        PACKS_DESC             = " 설치된 하위 애드온의 아이콘 스타일입니다.\n 팩을 선택하면 '색상' 탭의 프리셋이 비활성화됩니다 (반대도 마찬가지).",
        PACKS_EMPTY            = "|cffaaaaaa 설치된 팩이 없습니다.\n 여기에 팩을 표시하려면 FarmMap_* 하위 애드온을 설치하세요.|r",

        -- /fm atlas — 아이콘 아틀라스 보정기. 우선순위 낮음: 자체 아이콘
        -- 팩을 제작하는 사용자를 위한 개발자 도구입니다.
        ATLAS_TITLE            = "FarmMap - 아틀라스 보정 (ObjectIconsAtlas)",
        ATLAS_HINT             = "아이콘을 좌클릭 후 드래그하여 위치를 변경할 수 있습니다. 크기는 (32x32)로 고정되며 위치만 이동합니다.",
        ATLAS_PRINT            = "테이블 복사",
        ATLAS_RESET            = "초기화",
        ATLAS_COPY_TITLE       = "FarmMap - 아틀라스 좌표",
        ATLAS_COPY_HINT        = "선택 완료됨: Ctrl+C를 눌러 복사한 뒤, WORLD_MAP_TEXCOORDS (및 BUILTIN_PINS)에 붙여넣으세요.",
    },
}
