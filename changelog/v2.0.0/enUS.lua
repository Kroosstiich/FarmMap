-- ============================================================
--  FarmMap — changelog v2.0.0, English (the fallback for every
--  language without its own file)
--  Written once, never edited after the release.
--  Shown by UI\Changelog.lua (window and "What's new" page).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.0.0"] = ns.changelog["2.0.0"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.0.0"].date = "09/10/2026"

ns.changelog["2.0.0"].enUS = {
    {
        kind = "new",
        entries = {
            { module = "New game clients",
              text = "FarmMap now runs on WoW: Forever, MoP Classic and Classic (Era, Season of Discovery and Hardcore), as well as Retail. One download covers every client. Season of Discovery and Hardcore were not tested in game, but they run on the same client as Classic Era. FarmMap also loads on TBC Anniversary, with its interface, but not every feature has been tested there yet: please report any problem on the Discord." },
            { module = "Options window",
              text = "A new window gathers every setting, with a menu by topic and a search that also finds the settings inside the pages. It opens in combat too. The legacy panel is still there: untick \"New options window\" in Display." },
            { module = "Window size",
              text = "Make FarmMap's windows bigger or smaller in Display. Each game client keeps its own setting." },
            { module = "Themes",
              text = "Pick the window's colours: Retail (blue), Forever (brown and gold), Emerald or Sakura. Each client has its own default. Make your own themes in the Theme page too: copy a theme, change its colours, then share it as text from Import/Export. A theme changes colours only, not icons." },
            { module = "Sakura",
              text = "A new icon style and a matching theme, drawn by SorelDesign. Pick the style in Map and icons, and the theme in Theme." },
            { module = "New icon",
              text = "FarmMap has a new icon, also drawn by SorelDesign." },
            { module = "Dashboard",
              text = "Follow your farming session: duration, nodes harvested, value at Auctionator or TSM prices, gold per hour and latest harvests. The session carries on through a UI reload." },
            { module = "Small session window",
              text = "The same numbers in a small window you can place anywhere, without opening the options." },
            { module = "Nodes",
              text = "See all your nodes, grouped by item and zone. Search an item to find where it grows, filter by zone or resource, and delete a selection." },
            { module = "Import preview",
              text = "Before importing another player's database, a preview shows, zone by zone, which nodes are new and which you already know. Nothing is imported until you confirm." },
            { module = "Icon styles",
              text = "Two new styles: \"WoW Retail\", with Blizzard's icons, and the classic ring, in white or in colour. In Map and icons, hover an icon to see it big." },
            { module = "Icon in the tooltip",
              text = "A node's tooltip now shows its icon, in the style chosen for that map. You can hide it in Display." },
            { module = "Filter bar",
              text = "The bar's buttons now wear the icons of the style chosen for the world map, so the bar matches the map. To keep the usual icons, untick \"Style icons in the bar\" in Display." },
            { module = "New version notice",
              text = "When someone in your guild or group runs a newer FarmMap, a line in the chat tells you. You can turn it off in Display." },
            { module = "TradeSkillMaster",
              text = "TSM can now value your harvests, in the floating text and on the dashboard. If Auctionator is installed too, choose which one FarmMap uses, and which TSM price. Tested on Retail and Classic Era." },
            { module = "TomTom and WaypointUI",
              text = "Click a node on the map or the minimap to set a TomTom waypoint there, with its arrow, or to be guided to it by WaypointUI. Click it again to remove it. With both installed, choose which one FarmMap uses." },
            { module = "Integrations",
              text = "A page shows which of these addons are installed, with their version, and holds their options. You use another addon FarmMap could work with? Ask on the Discord." },
            { module = "What's new",
              text = "This window opens once for each new version. You can find it again at any time in the options." },
        },
    },
    {
        kind = "change",
        entries = {
            { module = "\"Blizzard atlas\" style",
              text = "It becomes \"WoW Retail\" and uses icons shipped with FarmMap, because patch 12.1.0 moved the game's own. If you used the old style, you switch to the new one automatically." },
            { module = "Node tooltips",
              text = "The base game now reads \"Vanilla\"." },
            { module = "Export",
              text = "An export now names the game client it comes from. When importing, FarmMap warns you if it comes from another client, since maps are not numbered the same there. Exports stay compatible with v1.8, both ways." },
            { module = "Professions",
              text = "A profession learned during the session is detected right away, and the filters FarmMap had turned off for lack of it come back on." },
            { module = "Debug window",
              text = "It was rebuilt and now only shows what concerns your harvests." },
        },
    },
    {
        kind = "fix",
        entries = {
            { module = "Value in the floating text",
              text = "A harvest's value is now right. The quantity used to be added as copper: 3 items at 14c showed 45c instead of 42c." },
            { module = "Import safety",
              text = "Imported text can now only describe nodes. A booby-trapped export shared by another player could run actions in FarmMap's name." },
            { module = "Options in combat",
              text = "Opening the legacy panel in combat now shows the game's error message, instead of a blocked-addon error." },
            { module = "Floating text on a Russian client",
              text = "The floating text now uses the right font. FarmMap used to ask for a font file that does not exist." },
            { module = "Clearing the database",
              text = "The floating text's size and duration are now kept." },
        },
    },
}
