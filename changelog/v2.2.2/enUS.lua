-- ============================================================
--  FarmMap — changelog v2.2.2, English (the fallback for every
--  language without its own file)
--  Written once, never edited after the release.
--  Shown by UI\Changelog.lua (window and "What's new" page).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.2.2"] = ns.changelog["2.2.2"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.2.2"].date = "29/10/2026"

ns.changelog["2.2.2"].enUS = {
    {
        kind = "fix",
        entries = {
            { module = "Gathering on Retail",
              text = "Herbs and ores from older expansions, from Outland to Khaz Algar, are now recorded. Before, most of these harvests were ignored." },
            { module = "Node names",
              text = "A node is now named after its herb or ore. Before, a bonus item such as Crystallized Water could give it its name." },
        },
    },
}
