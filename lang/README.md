# FarmMap — Translations / Traductions

Thanks for helping translate FarmMap! Adding a language takes about 15 minutes
and requires **no programming knowledge** — you copy one file, translate the text
between the quotes, and add one line to `FarmMap.toc`.

*Merci de contribuer à la traduction de FarmMap ! Ajouter une langue prend environ
15 minutes et ne demande **aucune connaissance en programmation**.*

---

## 0. The easy way: translate in your browser / Le plus simple : dans votre navigateur

Before anything else — **you may not need this file at all.** FarmMap's phrases
can be translated directly in your browser, one at a time, with nothing to
download and no Lua to edit:

**https://legacy.curseforge.com/wow/addons/farmmap/localization**

> **Important:** use the **website** for this, not the CurseForge desktop app —
> the app does not offer the localization page.

*Avant tout : **vous n'avez peut-être pas besoin de ce fichier.** Les phrases de
FarmMap se traduisent directement dans le navigateur, une par une, sans rien
télécharger. Utilisez bien le **site web**, pas l'application CurseForge.*

The rest of this guide is for people who would rather work on a file — which is
still the fastest route for a full language, and the only one that lets you test
in game before sending anything.

---

## 1. Create your file / Créez votre fichier

Copy `lang/enUS.lua` and rename it to your WoW locale code:

| Code | Language | Code | Language |
|------|----------|------|----------|
| `deDE` | Deutsch | `ruRU` | Русский |
| `esES` | Español (EU) | `zhCN` | 简体中文 |
| `esMX` | Español (AL) | `zhTW` | 繁體中文 |
| `itIT` | Italiano | `ptBR` | Português |

English is the reference language. **Any key you leave out automatically falls
back to English** — a partial translation will never break the addon, so you can
ship what you have and finish later.

## 2. Fill in the header / Remplissez l'en-tête

```lua
ns.locales.deDE = {
    name       = "Deutsch",   -- your language, written in your language
    latinName  = "German",    -- latin-alphabet name (shown as a fallback)
    translator = "YourName",  -- credited in-game, in the Options panel
    order      = 60,          -- position in the language list (next free number)
    strings = {
        ...
    },
}
```

`translator` is displayed in the addon's credits — put whatever name you want to
be known by.

### Optional: your link / Votre lien

You can add a line of your own right under the translation credit. It is yours —
a way to be reached, or a plug for your channel. Both fields are optional and
commented out by default:

```lua
    translator   = "YourName",
    contactLabel = "Twitch",
    contactValue = "twitch.tv/yourname",
```

```
Creator     : Dkroosstii-Dalaran
Discord     : Kroosstii
Translation : YourName
Twitch      : twitch.tv/yourname     <- your line
Version     : v1.6.2
```

The label is free text — `Twitch`, `Discord`, `GitHub`, `YouTube`, anything —
and it is **never translated**: a brand name reads the same in every language.
The line only shows for players using *your* language. Leave both out for no
line at all; filling only one of the two drops it as well.

*Vous pouvez ajouter votre propre ligne sous le crédit de traduction : un moyen
d'être contacté, ou la pub de votre chaîne. Le libellé est libre et n'est jamais
traduit. La ligne n'apparaît que pour les joueurs qui utilisent **votre** langue.
Laissez les deux champs commentés pour ne rien afficher.*

## 3. Translate / Traduisez

Only translate the text **between the quotes**. Everything else must stay exactly
as it is:

```lua
DB_CLEAR = "Clear database",       -- ✅ translate "Clear database"
DB_CLEAR = "Datenbank leeren",     -- ✅ correct
Datenbank = "Clear database",      -- ❌ never rename the key
```

### Things you must keep

| Code | What it does | Rule |
|------|--------------|------|
| `\|cffff4444` … `\|r` | Colour codes | Keep them around the same text |
| `\n` | Line break | Keep roughly the same number of lines |
| `%s`, `%d` | Value inserted by the addon | Keep, and keep the same order |
| Leading space `" text"` | Indentation in panels | Keep it |
| `/fm help` | Slash commands | **Never translate** — they are typed by the user |

### Strings that get glued to a number

Some strings are concatenated after a number, so they may need a leading space in
your language (or none at all — Korean and Chinese usually need none):

```lua
IMPORT_SUCCESS = " node(s) successfully imported.",   -- "12 node(s) successfully..."
MIGR_ENTRIES   = " entry/entries corrected.",
PROF_DISABLED  = " not detected — display disabled.",
```

### `SLASH_HELP` alignment

`SLASH_HELP` uses spaces to align the command descriptions. If your script uses
wide characters (Korean, Chinese, Japanese), the alignment will not match — that
is fine, readability matters more than alignment.

## 3b. Optional: translate the commands / Traduire les commandes

You can add chat commands in your own language. **The English commands always
keep working** — `/fm`, `/farmmap` and every English sub-command stay active no
matter what, so the addon page and any English guide stay correct. Aliases are
additions, never replacements.

```lua
slash = {
    prefix   = { "/carte" },                              -- /carte help works
    commands = { help = { "aide" }, clear = { "vider" } },-- /fm aide works
},
```

With the example above, all of these do the same thing:

```
/fm help      /fm aide      /carte help      /carte aide
```

Rules and warnings:

- An alias identical to an English command is **ignored**. You cannot break
  `/fm clear` by defining `clear` as an alias for something else.
- A chat prefix (`/carte`) is global to the game: if another add-on already uses
  it, one of the two loses. Prefer something distinctive, and test it.
- Sub-command aliases (`/fm aide`) carry no such risk — they are only read
  inside FarmMap.
- Leave both tables empty if you do not want any. That is the default.
- For non-latin scripts, remember that typing a command in your script means
  switching your IME in the middle of the chat box. Latin aliases are often
  more practical. Your call.

*Vous pouvez ajouter des commandes dans votre langue. **Les commandes anglaises
restent toujours actives** : les alias s'ajoutent, ils ne remplacent jamais. Un
alias identique à une commande anglaise est ignoré. Attention, un préfixe de
chat (`/carte`) est global au jeu : s'il est déjà pris par un autre addon, l'un
des deux perd — testez-le.*

## 4. Register it / Déclarez-le

Add one line to `FarmMap.toc`, next to the other languages:

```
lang\enUS.lua
lang\frFR.lua
lang\koKR.lua
lang\deDE.lua      <- your file
```

`lang\enUS.lua` **must stay first** — it is the fallback for every other language.

## 5. Test in game / Testez en jeu

1. Put the addon in `World of Warcraft\_retail_\Interface\AddOns\FarmMap`
2. Launch the game, then type `/reload`
3. Open **Options → AddOns → FarmMap → Language**, pick your language, `/reload` again

Your language appears in that list automatically — there is nothing else to code.

### If the text shows as empty boxes

The WoW client only ships the fonts for its own language. A Korean, Chinese,
Japanese, or Russian translation displays correctly on a client of that language,
but shows as `□□□` on an English or French client. Install a font add-on such as
[UnicodeFont](https://www.curseforge.com/wow/addons/unicode-font) to fix it.

## 6. Send it / Envoyez-le

Join the **FarmMap Discord server** — the invite link is on the
[CurseForge project page](https://www.curseforge.com/wow/addons/farmmap)
(look for the Discord link in the right-hand sidebar, or at the bottom of the
page on mobile). Post your `.lua` file there and it will be reviewed and included
in the next release, with you credited in-game and on the project page.

You can also leave a comment on the CurseForge page if you prefer.

Please send the **file itself**, not a screenshot or pasted text — the file is
what gets shipped, and copy-pasting text through chat is what breaks encoding.

*Rejoignez le **serveur Discord de FarmMap** — le lien d'invitation est sur la
[page CurseForge du projet](https://www.curseforge.com/wow/addons/farmmap)
(colonne de droite, ou en bas de page sur mobile). Déposez-y votre fichier
`.lua` : il sera relu et intégré à la prochaine version, avec votre crédit en jeu
et sur la page du projet. Envoyez bien **le fichier**, pas une capture d'écran ni
du texte collé — c'est le copier-coller par chat qui casse l'encodage.*

---

## File encoding — important / Encodage — important

Your file **must** be saved as **UTF-8 without BOM**, with no exception.
Notepad, VS Code, and Notepad++ all support this:

- **VS Code**: bottom-right status bar → click the encoding → *Save with Encoding* → *UTF-8*
- **Notepad++**: menu *Encoding* → *UTF-8* (not *UTF-8-BOM*)
- **Windows Notepad**: *Save as…* → *Encoding* dropdown → *UTF-8*

If you save it as UTF-8 **with** BOM, the game shows stray characters at the top
of the screen. If you save it as ANSI/Latin-1, all accented and non-latin
characters are destroyed.

## Current translations / Traductions actuelles

| Locale | Language | Translator |
|--------|----------|------------|
| `enUS` | English | Kroosstii |
| `frFR` | Français | Kroosstii |
| `koKR` | 한국어 | Crazyyoungs |
| `zhCN` | 简体中文 | bluse |
| `ruRU` | Русский | ZamestoTV |
