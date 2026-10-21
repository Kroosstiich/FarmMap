-- ============================================================
--  FarmMap — changelog v2.2.0, English (the fallback for every
--  language without its own file)
--  Written once, never edited after the release.
--  Shown by UI\Changelog.lua (window and "What's new" page).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.2.0"] = ns.changelog["2.2.0"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.2.0"].date = "21/10/2026"

ns.changelog["2.2.0"].enUS = {
    {
        kind = "new",
        entries = {
            { module = "Route",
              text = "The new Route button on the world map's filter bar draws a loop through the nodes you know in the zone shown, for the filters that are on, on the world map and the minimap. In Integrations > Route, pick its direction, the longest lap you want, or ask for another route. The button's tooltip and the session window give a lap's estimated time, which learns your speed as you go." },
            { module = "Guidance along the route",
              text = "With TomTom or WaypointUI, the waypoint moves to the next node of the loop after each harvest, or as you reach the node. Start it from a pin's right-click menu, the session window or Integrations > Route. Shift-click the Route button to skip a node someone else already took." },
            { module = "Theme gradients",
              text = "In your own themes, the background, the panels and the bands can blend into a second colour, from top to bottom. The gradients are part of the theme's shared text." },
            { module = "Your language",
              text = "On Retail and WoW: Forever, searches ignore accents, lists are sorted in your language's alphabetical order, and numbers and dates follow your language's format." },
            { module = "Setup assistant",
              text = "Two new screens explain the route and its guidance. If you have already run the assistant, it only shows these two." },
        },
    },
    {
        kind = "change",
        entries = {
            { module = "What's new",
              text = "This window now shows the notes of the current series and of the one before it. Older notes are behind the Show older changelogs button." },
        },
    },
    {
        kind = "fix",
        entries = {
            { module = "Options window",
              text = "The border of some switches is now as thick on every side, whatever the window's size and scroll position. Before, it could be thinner on one side." },
        },
    },
}
