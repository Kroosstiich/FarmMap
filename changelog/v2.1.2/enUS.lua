-- ============================================================
--  FarmMap — changelog v2.1.2, English (the fallback for every
--  language without its own file)
--  Written once, never edited after the release.
--  Shown by UI\Changelog.lua (window and "What's new" page).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.1.2"] = ns.changelog["2.1.2"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.1.2"].date = "19/10/2026"

ns.changelog["2.1.2"].enUS = {
    {
        kind = "fix",
        entries = {
            { module = "Dashboard",
              text = "Without Auctionator or TSM, the value and gold per hour boxes are no longer shown: they could only stay empty. The same goes for the small session window." },
            { module = "Korean client",
              text = "Empty squares no longer appear in the dashboard and the credits: they came from a dash missing from the Korean font. The text asking for a price addon is shorter too, as a Korean player suggested." },
        },
    },
}
