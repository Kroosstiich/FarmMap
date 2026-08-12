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
  value of what you gathered (value needs [Auctionator](https://www.curseforge.com/wow/addons/auctionator),
  an optional dependency, with its auction house database already scanned once)
- Multiple icon styles, including colorblind-friendly presets
  (Deuteranopia, Protanopia, Tritanopia)
- Minimap button — left click for the options, right click for the debug window
- Export / import to share your node database with other players
- Harvest statistics per resource type
- English, French and Korean, auto-detected from the game client with a manual
  override in the options

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
| `zhCN` | 简体中文 | bluse |
| `ruRU` | Русский | ZamestoTV |

Pull requests adding a language are welcome, and translators are credited both
in-game and here. You can also send your file on the
[FarmMap Discord](https://discord.gg/4BEGpmktK7) if you would rather not use git.

## Icon packs

FarmMap exposes a public API so separate addons can register their own icon
styles. Existing packs:

- [Old Colors](https://www.curseforge.com/wow/addons/farmmap-old-colors)
- [The Artisan's Anthology](https://www.curseforge.com/wow/addons/farmmap-the-artisans-anthology)

The in-game `/fm atlas` calibrator helps find the correct icon coordinates
after a game patch shifts Blizzard's atlas layout.

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
- **Bundled libraries** in `Libs/` keep their own licenses — see
  [THIRD-PARTY-NOTICES.txt](THIRD-PARTY-NOTICES.txt).

**No AI-generated assets are used in this addon.** Every asset added by the
author was made by hand.

World of Warcraft and Blizzard Entertainment are trademarks or registered
trademarks of Blizzard Entertainment, Inc. This addon is not affiliated with
or endorsed by Blizzard Entertainment.
