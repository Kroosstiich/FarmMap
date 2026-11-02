-- ============================================================
--  FarmMap — changelog v2.3.1, English (the fallback for every
--  language without its own file)
--  Written once, never edited after the release.
--  Shown by UI\Changelog.lua (window and "What's new" page).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.3.1"] = ns.changelog["2.3.1"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.3.1"].date = "02/11/2026"

ns.changelog["2.3.1"].enUS = {
    {
        kind = "new",
        entries = {
            { module = "Localisation update",
              text = "Korean" },
        },
    },
}
