-- ============================================================
--  FarmMap — changelog v2.4.0, English (the fallback for every
--  language without its own file)
--  Written once, never edited after the release.
--  Shown by UI\Changelog.lua (window and "What's new" page).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.4.0"] = ns.changelog["2.4.0"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.4.0"].date = "27/11/2026"

ns.changelog["2.4.0"].enUS = {
    {
        kind = "new",
        entries = {
            { module = "Route look",
              text = "Pick the route's colour, from a list or your own with the colour picker. On Retail and WoW: Forever, the minimap can show a thin line instead of dots. Set the line's width on the minimap, the radar and the world map, and turn the direction arrows on or off." },
            { module = "Radar",
              text = "Set a key to show or hide it, right from its settings or in the game's Key Bindings. It can also hide itself in combat." },
            { module = "Share in chat (beta)",
              text = "Import / Export page: put a short text in the chat, and other FarmMap players click it to receive your nodes, with the usual preview. Not tested between two players yet: please report anything odd on CurseForge or Discord." },
            { module = "Quick menu",
              text = "While the route is on, choose dots or line for the minimap right under it. An Options window line was added too." },
        },
    },
    {
        kind = "change",
        entries = {
            { module = "Route settings",
              text = "They moved to Map and icons, next to the radar. The guidance stays in Integrations, as it needs TomTom or WaypointUI." },
            { module = "Game options",
              text = "FarmMap's page in the game's options has a button to open the full options window." },
        },
    },
    {
        kind = "fix",
        entries = {
            { module = "FarmMap button",
              text = "Shift-click now always opens the options. Before, with neither click set to the options window, the button could not open them anymore." },
        },
    },
}
