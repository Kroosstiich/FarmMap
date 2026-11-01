-- ============================================================
--  FarmMap — changelog v2.3.0, English (the fallback for every
--  language without its own file)
--  Written once, never edited after the release.
--  Shown by UI\Changelog.lua (window and "What's new" page).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.3.0"] = ns.changelog["2.3.0"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.3.0"].date = "01/11/2026"

ns.changelog["2.3.0"].enUS = {
    {
        kind = "new",
        entries = {
            { module = "Radar",
              text = "A transparent radar in the middle of the screen shows the nodes you know around you and the route, with the cardinal points. Your clicks go through it. Turn it on and set it up in Map and icons: range, size, opacity, whether it turns with you, and the key to hold to move it." },
            { module = "Quick menu",
              text = "Right-click the FarmMap button, on the minimap or in a broker bar such as Titan Panel or Bazooka, to switch herbs, ore, fish, wood, the route and its guidance, the session window and the debug window." },
            { module = "FarmMap button",
              text = "In Map and icons, choose what its left and right clicks do: options window, quick menu, session window or debug window." },
            { module = "Setup assistant",
              text = "Two new screens: the FarmMap button and the radar. If you have already run the assistant, it only shows these two." },
        },
    },
    {
        kind = "change",
        entries = {
            { module = "Debug window",
              text = "A right click on the FarmMap button now opens the quick menu. The debug window is in that menu, or you can put it back on the right click in Map and icons." },
        },
    },
}
