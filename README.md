# FarmMap

A lightweight World of Warcraft gathering addon that automatically records the
location of every herb, ore, fish and wood node you harvest — no manual input.
Pins appear on your minimap and world map so you can build your own farming
routes over time.

[Download on CurseForge](https://www.curseforge.com/wow/addons/farmmap)

## Features

- Automatic node recording on harvest — herbs, ores, fish and wood
- Pins on both the minimap and the world map, with filter buttons per resource —
  Shift-drag to move the bar, Shift-right-click to flip it horizontal / vertical,
  and a slider to fade it out when the cursor is elsewhere
- Primordial / abundant node support with a distinct visual style
- Optional floating text on harvest: quantity, tier, total bag count, and the
  value of what you gathered — value display contributed by
  [buseQ](https://github.com/buseQ); it needs
  [Auctionator](https://www.curseforge.com/wow/addons/auctionator), an optional
  dependency, with its auction house database already scanned once
- Multiple icon styles, including colorblind-friendly presets
  (Deuteranopia, Protanopia, Tritanopia)
- Minimap button — left click for the options, right click for the debug window
- Export / import to share your node database with other players
- Harvest statistics per resource type
- English, French, Korean, Simplified Chinese and Russian, auto-detected from the
  game client with a manual override in the options — Korean by Crazyyoungs,
  Simplified Chinese by buseQ, Russian by ZamestoTV

## Known limitations

- **Fishing records every catch, pool or open water.** The game reports the
  same loot source for both — the fishing bobber, not the pool — so an addon
  cannot tell whether the fish came from a school. On Retail you nearly always
  fish in pools, so it rarely shows; on Classic, where open water is common,
  expect fishing pins wherever you cast. Catches at the same spot merge into
  one pin, and the fish button on the filter bar hides them all.

## Installation

Copy the `FarmMap` folder into `World of Warcraft\_retail_\Interface\AddOns\`,
then restart the game client. A `/reload` is not enough when the file list
changes — the `.toc` is only read at startup.

## Slash commands

| Command | Description |
|---|---|
| `/fm help` | Show all available commands |
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

**The easiest route needs no file at all:** phrases can be translated directly
in the browser at
[legacy.curseforge.com/wow/addons/farmmap/localization](https://legacy.curseforge.com/wow/addons/farmmap/localization)
— use the website, not the CurseForge desktop app, which does not offer that
page.

The full step-by-step guide for the file route is in
[lang/README.md](lang/README.md).

| Locale | Language | Translator |
|---|---|---|
| `enUS` | English | Kroosstii |
| `frFR` | Français | Kroosstii |
| `koKR` | 한국어 | Crazyyoungs |
| `zhCN` | 简体中文 | buseQ (signs *bluse*) |
| `ruRU` | Русский | Hubbotu (signs *ZamestoTV*) |

Pull requests adding a language are welcome, and translators are credited both
in-game and here. You can also send your file on the
[FarmMap Discord](https://discord.gg/4BEGpmktK7) if you would rather not use git.

## Contributors

A good part of what FarmMap does today arrived from the people using it.

- **[buseQ](https://github.com/buseQ)**, who signs his translations *bluse*,
  wrote the harvest value display and sent it as
  [pull request #4](https://github.com/Kroosstiich/FarmMap/pull/4): the
  floating text can now show what the items you just gathered are worth, read
  from Auctionator through its public API and declared as an optional
  dependency. The idea and the code are entirely his, and it was merged
  unchanged. He also contributed the Simplified Chinese translation, and
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
  map. That request became the Shift-drag and the opacity slider. He also
  maintains the Korean translation, and has twice translated new strings within
  the hour, before anyone thought to tell him they existed. Thank you.

## Icon packs

FarmMap exposes a public API so separate addons can register their own icon
styles. Existing packs:

- [Old Colors](https://www.curseforge.com/wow/addons/farmmap-old-colors)
- [The Artisan's Anthology](https://www.curseforge.com/wow/addons/farmmap-the-artisans-anthology)

The in-game `/fm atlas` calibrator helps find the correct icon coordinates
after a game patch shifts Blizzard's atlas layout.

### Making your own icon pack

A pack is a small separate addon that ships its textures and registers them
with `FarmMapStyles.Register`. Its styles then appear in FarmMap's
*Colors → Packs* options panel.

`FarmMap_MyPack.toc` — `Dependencies` makes sure FarmMap is loaded first; list
the interface number of every client the pack should run on:

```
## Interface: 120100, 16001
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

Textures must be `.tga` or `.blp` with power-of-two dimensions. The
[Old Colors](https://www.curseforge.com/wow/addons/farmmap-old-colors) pack is
a complete working example.

## Development

FarmMap's Lua code is written with AI assistance (Claude Opus 5, by Anthropic).
Every change is reviewed and tested in game by the author before it is released.

This concerns the **code only**. The artwork is not AI-generated — see the
License section below for how the two differ.

## License

FarmMap's **own source code** is released under the GNU General Public License
v3.0 — see [LICENSE](LICENSE).

The GPLv3 does **not** extend to everything shipped in this repository:

- **Icon textures** (`Textures/atlas-blip-farmmap-*.tga`) are *modified* versions
  of Blizzard's in-game `Interface\Minimap\ObjectIconsAtlas`, into which the
  author's own hand-made artwork has been added — colorblind-friendly, vivid
  and white-outline variants. The underlying Blizzard artwork remains the
  property of Blizzard Entertainment and is not the author's to relicense; only
  the author's own additions and modifications are his. They are bundled so the
  addon can display icons consistent with the game.
- **Blizzard gathering icons** (`Textures/atlas-blip-farmmap-blizzard.tga`) are
  four icons cropped, unmodified, from that same Blizzard atlas. They are
  shipped so the "Blizzard atlas" style keeps working when Blizzard reshuffles
  its own file. They remain Blizzard Entertainment's property.
- **Bundled libraries** in `Libs/` keep their own licenses — see
  [THIRD-PARTY-NOTICES.txt](THIRD-PARTY-NOTICES.txt).

**No AI-generated artwork is used in this addon.** Every image asset added by
the author was made by hand.

The one exception is not artwork: the UI frame textures in `Textures/ui/` are
plain rounded rectangles computed by a small script,
[`tools/make_frame_textures.py`](tools/make_frame_textures.py) — each pixel's
opacity comes from geometry alone, not from an image generator, and anyone can
run the script to rebuild them. Like the rest of FarmMap's code, the script
itself was written with AI assistance.

World of Warcraft and Blizzard Entertainment are trademarks or registered
trademarks of Blizzard Entertainment, Inc. This addon is not affiliated with
or endorsed by Blizzard Entertainment.
