# FarmMap

A lightweight World of Warcraft gathering addon that automatically records the
location of every herb, ore, fish and wood node you harvest — no manual input.
Pins appear on your minimap and world map so you can build your own farming
routes over time.

**One download for every client:** Retail, WoW: Forever, MoP Classic and
Classic (Era, Season of Discovery and Hardcore). It also loads on TBC
Anniversary, where not every feature has been tested yet.

[Download on CurseForge](https://www.curseforge.com/wow/addons/farmmap) ·
[Discord](https://discord.gg/4BEGpmktK7)

## Features

- Automatic node recording on harvest — herbs, ores, fish and wood
- Pins on both the minimap and the world map, with the node's icon in its
  tooltip
- Filter buttons on the world map per resource — Shift-drag to move the bar,
  Shift-right-click to flip it horizontal / vertical, a slider to fade it out
  when the cursor is elsewhere; the buttons wear the icons of your world map
  style
- Primordial / abundant node support with a distinct visual style
- Optional floating text on harvest: quantity, tier, total bag count, and the
  value of what you gathered — value display contributed by
  [buseQ](https://github.com/buseQ); prices come from
  [Auctionator](https://www.curseforge.com/wow/addons/auctionator) or
  TradeSkillMaster, both optional
- **Options window** drawn by FarmMap itself, identical on every client: a menu
  by topic, a search that also finds the settings inside the pages, usable in
  combat, and a window size of its own per client. The legacy Blizzard panel is
  still available.
- **Themes** for that window — Retail, Forever, Emerald and Sakura — plus your
  own, made in game and shared as a line of text (see [Themes](#themes))
- **Icon styles**: WoW Retail, vivid colours, white outline, colorblind-friendly
  presets (Deuteranopia, Protanopia, Tritanopia), classic rings, the built-in
  **Sakura** pack, and any icon pack you install; hover a style's icons in the
  options to see them big
- **Dashboard** for the current session — duration, nodes harvested, value,
  gold per hour, latest harvests — and a small session window to keep on screen
- **Node manager**: every node grouped by item and zone, search by item, filter
  by zone or resource, delete a selection
- **Export / import** to share your node database, with a preview before
  anything is written; an export names the game client it comes from
- **Integrations**: TradeSkillMaster as a second price source, and a click on a
  node sets a waypoint with [TomTom](https://www.curseforge.com/wow/addons/tomtom)
  or WaypointUI
- A "What's new" window once per version
- Harvest statistics per resource type
- Minimap button — left click for the options, right click for the debug window
- English and French, plus Korean, Simplified Chinese and Russian by the
  community, auto-detected from the game client with a manual override in the
  options

## Known limitations

- **Fishing records every catch, pool or open water.** The game reports the
  same loot source for both — the fishing bobber, not the pool — so an addon
  cannot tell whether the fish came from a school. On Retail you nearly always
  fish in pools, so it rarely shows; on Classic, where open water is common,
  expect fishing pins wherever you cast. Catches at the same spot merge into
  one pin, and the fish button on the filter bar hides them all.
- **Blizzard's own minimap tracking dots cannot be restyled.** FarmMap draws
  its own pins instead. Retail lost the only way to do it in patch 12.0.7
  (`Minimap:SetBlipTexture` was removed) and WoW: Forever never had it. The
  Classic clients still have it, but it only swaps one whole image whose
  layout is fixed by the game engine: an addon cannot choose which part of it
  stands for herbs or ores, so FarmMap does not offer it there either.

## Installation

Copy the `FarmMap` folder into the `Interface\AddOns\` folder of your game
client — for example `World of Warcraft\_retail_\Interface\AddOns\` for Retail
— then restart the game client. A `/reload` is not enough when the file list
changes — the `.toc` is only read at startup.

## Slash commands

| Command | Description |
|---|---|
| `/fm help` | Show all available commands |
| `/fm ui` | Open the options window |
| `/fm news` | Show the "What's new" window again |
| `/fm debug` | Show/hide the debug window |
| `/fm export` | Open the database export window |
| `/fm import` | Open the database import window |
| `/fm clear` | Wipe the node database (settings are preserved) |
| `/fm stats` | Display harvest statistics in chat |
| `/fm migrate` | Manually run database migrations |
| `/fm atlas` | Open the icon atlas calibrator (for icon pack creators) |
| `/fm default` | Switch back to your game client's language |
| `/fm version` | Display the current addon version |

`/fm` is a short prefix and other addons claim it — FocusMarker registers it
too, and addons load alphabetically, so whichever sorts last wins. FarmMap
detects this at login, names the addon that took it, and switches every command
it prints to **`/farmmap`**, which always works. Nothing to configure.

## Translations

FarmMap is translated by its community. Adding a language takes **one file and
no programming knowledge** — copy `lang/enUS.lua`, translate the text between
the quotes, and the language appears in the addon options on its own. Any key
left untranslated falls back to English, so a partial translation never breaks
anything.

Send the file on the [Discord](https://discord.gg/4BEGpmktK7), or open a pull
request here if you are comfortable with git. The full step-by-step guide is in
[lang/README.md](lang/README.md).

| Locale | Language | Translator |
|---|---|---|
| `enUS` | English | Kroosstii |
| `frFR` | Français | Kroosstii |
| `koKR` | 한국어 | Crazyyoungs |
| `zhCN` | 简体中文 | buseQ (signs *bluse*) |
| `ruRU` | Русский | Hubbotu (signs *ZamestoTV*) |

The texts new in 2.0 are already in the Korean, Chinese and Russian files, in
English and marked `[TRANSLATE]`: search for that word to find what is left.
Each language arrives in a small update of its own once translated.
Translators are credited both in-game and here.

## Contributors

A good part of what FarmMap does today arrived from the people using it.

- **[buseQ](https://github.com/buseQ)**, who signs his translations *bluse*,
  wrote the harvest value display and sent it as
  [pull request #4](https://github.com/Kroosstiich/FarmMap/pull/4): the
  floating text can now show what the items you just gathered are worth. The
  idea and the code are entirely his, and it was merged unchanged. He also
  contributed the Simplified Chinese translation, and
  [pull request #1](https://github.com/Kroosstiich/FarmMap/pull/1) before that.
  Thank you.
- **[Hubbotu](https://github.com/Hubbotu)**, who signs *ZamestoTV*, contributed
  the entire Russian localization as
  [pull request #2](https://github.com/Kroosstiich/FarmMap/pull/2) — a complete
  locale, every single key, with the colour codes and escapes carried over
  untouched. Russian was not on any roadmap; it exists because he wrote it.
  Thank you.
- **Crazyyoungs** asked for the world map filter bar to be movable and to fade
  out, so it stops colliding with other addons that use the same corner of the
  map, and then for its size; he also reported the untranslated expansion
  names. He maintains the Korean translation, and has twice translated new
  strings within the hour, before anyone thought to tell him they existed.
  Thank you.
- **r0s0j** asked for the world map icon size and the zone summary. Thank you.
- **[SorelDesign](https://soreldesign.fr)** drew FarmMap's icon and the Sakura
  pack by hand. Thank you.
- **Komî** has tested FarmMap in game with the author since the very first
  version. Thank you.

## Themes

A theme sets the colours of FarmMap's options window — and nothing else. Sizes,
spacing and layout are fixed, so no theme can break the window, and icons go
through icon packs. Four themes are built in: Retail, Forever, Emerald and
Sakura; each client opens on its own default until you pick one.

**In game**, the Theme page makes a copy of any theme; click a colour of your
copy to change it, and the window shows the change at once. Your themes are
saved with your FarmMap settings — no file is written. *Export* turns a theme
into one line of text (`FMTHEME1;…`) that another player pastes into
Import / Export. That text is read as a name and colours only, never run as
code.

**As an addon**, a theme registers itself like an icon pack:

```lua
FarmMapThemes.Register("mytheme", {
    label  = "My Theme",
    author = "Me",                  -- optional, shown on the theme card
    url    = "https://example.org", -- optional, offered to copy from the card
    colors = {
        bg = "#1b1418", panel = "#241a20", panel2 = "#2f2229", line = "#4a3541",
        accent = "#f2a7c3", accentSoft = "#9c5b77",
        text = "#f6eaf0", dim = "#bfa3b1", faint = "#84697a",
        good = "#9ad4a0", warn = "#eab676", bad = "#e2574c",
    },
})
```

`bg` is the window ground, `panel` and `panel2` the cards and title bar, `line`
the borders, `accent` the titles and selection, `accentSoft` the accent at rest,
`text` / `dim` / `faint` the three levels of text, and `good` / `warn` / `bad`
the state colours. A colour left out falls back to the client's default theme.

## Icon packs

FarmMap exposes a public API so separate addons can register their own icon
styles. Existing packs:

- **Sakura** — built into FarmMap since 2.0, drawn by
  [SorelDesign](https://soreldesign.fr)
- [Old Colors](https://www.curseforge.com/wow/addons/farmmap-old-colors)
- [The Artisan's Anthology](https://www.curseforge.com/wow/addons/farmmap-the-artisans-anthology)

The in-game `/fm atlas` calibrator helps find the correct icon coordinates
after a game patch shifts Blizzard's atlas layout.

### Making your own icon pack

A pack is a small separate addon that ships its textures and registers them
with `FarmMapStyles.Register`. Its styles then appear in FarmMap's *Map and
icons* page, marked "pack".

`FarmMap_MyPack.toc` — `Dependencies` makes sure FarmMap is loaded first; list
the interface number of every client the pack should run on:

```
## Interface: 120100, 120007, 16001, 50504, 20506, 11509
## Title: FarmMap - My Pack
## Dependencies: FarmMap

FarmMap_MyPack.lua
```

`FarmMap_MyPack.lua`:

```lua
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addon)
    if addon ~= "FarmMap_MyPack" then return end
    local tex = "Interface\\AddOns\\FarmMap_MyPack\\Textures\\my-icons"
    FarmMapStyles.Register("mypack", {
        label = "My Pack",   -- name shown in the options
        pins  = {            -- one entry per node type
            -- coords = { left, right, top, bottom }, as fractions (0-1) of the texture
            Herbo  = { tex = tex, coords = { 0.00, 0.25, 0.00, 0.25 } },  -- herbs
            Minage = { tex = tex, coords = { 0.25, 0.50, 0.00, 0.25 } },  -- ore
            Peche  = { tex = tex, coords = { 0.50, 0.75, 0.00, 0.25 } },  -- fishing
            Bois   = { tex = tex, coords = { 0.75, 1.00, 0.00, 0.25 } },  -- logging (Retail only)
        },
    })
    self:UnregisterAllEvents()
end)
```

Each pin also accepts two optional fields:

- `centered = true` — the drawing sits in the middle of its cell. Previews and
  the filter bar then skip the small per-type nudge they apply to Blizzard's
  off-centre sprites.
- `grow = 2` — draws the icon that many pixels bigger, on both maps, for
  detailed drawings that read small at the default size.

The rich node types (`HerboR`, `MinageR`, `PecheR`) can reuse the same entries;
FarmMap tints them gold. Textures must be `.tga` or `.blp` with power-of-two
dimensions. The [Old Colors](https://www.curseforge.com/wow/addons/farmmap-old-colors)
pack is a complete working example.

## Development

FarmMap's Lua code is written with AI assistance (Claude, by Anthropic). Every
change is reviewed and tested in game by the author before it is released.

This concerns the **code only**. The artwork is not AI-generated — see the
License section below for how the two differ.

## License

FarmMap's **own source code** is released under the GNU General Public License
v3.0 — see [LICENSE](LICENSE).

The GPLv3 does **not** extend to everything shipped in this repository:

- **FarmMap's icon and the Sakura icons** (`Textures/icon.tga`,
  `Textures/sakura.tga`) were drawn by hand by
  [SorelDesign](https://soreldesign.fr), who keeps all rights to them. They are
  shipped with FarmMap with her permission and are not covered by the GPL: do
  not reuse them elsewhere without asking her.
- **Icon textures** (`Textures/atlas-blip-farmmap-*.tga`) are *modified* versions
  of Blizzard's in-game `Interface\Minimap\ObjectIconsAtlas`, into which the
  author's own hand-made artwork has been added — colorblind-friendly, vivid
  and white-outline variants. The underlying Blizzard artwork remains the
  property of Blizzard Entertainment and is not the author's to relicense; only
  the author's own additions and modifications are his. They are bundled so the
  addon can display icons consistent with the game.
- **Blizzard gathering icons** (`Textures/atlas-blip-farmmap-blizzard.tga`) are
  four icons cropped, unmodified, from that same Blizzard atlas. They are
  shipped so the "WoW Retail" style keeps working when Blizzard reshuffles its
  own file. They remain Blizzard Entertainment's property.
- **The KROO logo** (`Media/logo.png`, and `Media/logo-white.png`, the same
  shape in white so the window can tint it) belongs to the author, Kroosstii,
  who keeps all rights to it. It is not covered by the GPL: it may not be used
  anywhere else, in any form, without his permission. The Discord and PayPal
  icons in `Media/` belong to their respective owners.
- **Bundled libraries** in `Libs/` keep their own licenses — see
  [THIRD-PARTY-NOTICES.txt](THIRD-PARTY-NOTICES.txt).

**No AI-generated artwork is used in this addon.** Every image asset was made by
hand — by the author, by SorelDesign, or by Blizzard.

The exceptions are not artwork. The UI frame textures in `Textures/ui/` are
plain rounded rectangles computed by a small script,
[`tools/make_frame_textures.py`](tools/make_frame_textures.py) — each pixel's
opacity comes from geometry alone, not from an image generator, and anyone can
run the script to rebuild them. `data/ClassicItemExpansion.lua`, which tells
the Classic clients which expansion a gathered item belongs to, is generated
from public game data by
[`tools/make_classic_expansions.py`](tools/make_classic_expansions.py). Like
the rest of FarmMap's code, both scripts were written with AI assistance.

World of Warcraft and Blizzard Entertainment are trademarks or registered
trademarks of Blizzard Entertainment, Inc. This addon is not affiliated with
or endorsed by Blizzard Entertainment.
