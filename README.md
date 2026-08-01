# FarmMap

A lightweight World of Warcraft gathering addon that automatically records the
location of every herb, ore, fish and wood node you harvest — no manual input.
Pins appear on your minimap and world map so you can build your own farming
routes over time.

[Download on CurseForge](https://www.curseforge.com/wow/addons/farmmap)

## Features

- Automatic node recording on harvest — herbs, ores, fish and wood
- Pins on both the minimap and the world map, with filter buttons per resource
- Primordial / abundant node support with a distinct visual style
- Optional floating text on harvest: quantity, tier and total bag count
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

The full step-by-step guide is in [lang/README.md](lang/README.md).

| Locale | Language | Translator |
|---|---|---|
| `enUS` | English | Kroosstii |
| `frFR` | Français | Kroosstii |
| `koKR` | 한국어 | Crazyyoungs |

Pull requests adding a language are welcome, and translators are credited both
in-game and here.

## Icon packs

FarmMap exposes a public API so separate addons can register their own icon
styles. Existing packs:

- [Old Colors](https://www.curseforge.com/wow/addons/farmmap-old-colors)
- [The Artisan's Anthology](https://www.curseforge.com/wow/addons/farmmap-the-artisans-anthology)

The in-game `/fm atlas` calibrator helps find the correct icon coordinates
after a game patch shifts Blizzard's atlas layout.

## License

FarmMap is released under the **GNU General Public License v3.0** — see
[LICENSE](LICENSE).

Bundled third-party libraries keep their own licenses; see
[THIRD-PARTY-NOTICES.txt](THIRD-PARTY-NOTICES.txt).

All artwork and textures were created by hand by the author — no AI-generated
assets.
