-- ============================================================
--  FarmMap — changelog v2.1.0, English (the fallback for every
--  language without its own file)
--  Written once, never edited after the release.
--  Shown by UI\Changelog.lua (window and "What's new" page).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.1.0"] = ns.changelog["2.1.0"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.1.0"].date = "14/10/2026"

ns.changelog["2.1.0"].enUS = {
    {
        kind = "new",
        entries = {
            { module = "Setup assistant",
              text = "A new window walks you through FarmMap's main settings, one per screen: what each one does, turned on and left off, with a small scene that shows it. It opens once; after an update, it only shows the new settings. Its first page tells you where to get help, and lets you stop it for now or never see it again. Type /fm setup to run it again." },
            { module = "Hide nearby pins",
              text = "Pins close to your character can disappear from the minimap, so they no longer cover its arrow. Choose the distance, from 50 to 300 yards. Off by default. An idea, and the code, by fiote." },
        },
    },
    {
        kind = "change",
        entries = {
            { module = "Patch 12.1.5",
              text = "FarmMap is up to date for patch 12.1.5." },
        },
    },
}
