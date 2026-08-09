-- ============================================================
--  FarmMap — Français (frFR)
--  Traduction : Kroosstii
--
--  Toute clé absente ici retombe automatiquement sur l'anglais
--  (lang/enUS.lua). Voir lang/README.md pour ajouter une langue.
-- ============================================================

local _, ns = ...

ns.locales = ns.locales or {}

ns.locales.frFR = {
    name       = "Français",
    latinName  = "French",
    translator = "Kroosstii",
    order      = 20,

    -- OPTIONNEL : votre lien, affiché sous le crédit de traduction.
    -- Le libellé est libre et n'est jamais traduit. Voir enUS.lua.
    -- contactLabel = "Twitch",
    -- contactValue = "twitch.tv/votrenom",

    -- OPTIONNEL : alias de commandes en français. L'anglais reste
    -- canonique — /fm, /farmmap et toutes les sous-commandes anglaises
    -- restent actives, donc la page CurseForge reste juste. Ce ne sont
    -- que des ajouts.
    --
    -- Exemple, à décommenter et adapter :
    --   prefix   = { "/carte" },
    --   commands = { help = { "aide" }, clear = { "vider" } },
    --
    -- Un alias identique à une commande anglaise est ignoré : impossible
    -- de casser /fm clear en définissant un alias "clear".
    slash = {
        prefix   = {},
        commands = {},
    },

    strings = {
        OPTIONS_TITLE          = "Options de FarmMap",
        CREDITS_CREATOR        = "Créateur",
        CREDITS_DISCORD        = "Discord",
        CREDITS_TRANSLATOR     = "Traduction",
        CREDITS_VERSION        = "Version",
        CREDITS_UPDATE         = "MàJ",

        DB_SECTION             = "Base de données",
        DB_CLEAR               = "Vider la base de données",
        DB_CLEARED             = "Base de données vidée.",
        DB_MIGRATE             = "Mettre à jour la DB",
        DB_MIGRATE_DESC        = "\"Mettre à jour\" corrige les entrées sans effacer vos données.",
        DB_EXPORT              = "Exporter",
        DB_IMPORT              = "Importer",
        DB_EXPORTIMPORT_DESC   = "Exportez vos nœuds pour les partager. L'import fusionne sans écraser.",

        DISPLAY_SECTION        = "Affichage",
        DISPLAY_DEBUG          = "Afficher la fenêtre debug",
        DISPLAY_FLOAT          = "Afficher le texte flottant à la récolte",
        DISPLAY_FLOAT_SIZE     = "Taille du texte",
        DISPLAY_FLOAT_DURATION = "Durée d'affichage (secondes)",
        DISPLAY_FLOAT_TIER     = "Afficher l'icône de rang",
        DELETE_NODE            = "Supprimer ce point",
        DEBUG_SECTION          = "Debug",

        COLORS_TITLE           = "Icônes & Couleurs",
        COLORS_DESC            = " Choisissez un style d'icône pour la minimap et la carte du monde.\n Cliquez sur une ligne pour la sélectionner (bordure dorée = actif).",
        MINIMAP_SECTION        = "Minimap",
        REPLACE_BLIP           = "Remplacer l'atlas Blizzard",
        REPLACE_BLIP_DESC      = " Suite à une mise à jour récente, il n'est plus possible de\n remplacer l'atlas de Blizzard sur la minimap. Seule la carte\n du monde garde les pins personnalisés.",
        SHOW_MINIMAP_PINS      = "Afficher les pins sur la minimap",
        SHOW_MINIMAP_BUTTON    = "Afficher le bouton FarmMap sur la minimap",
        MINIMAP_BTN_LEFT       = "Clic gauche : ouvrir les options",
        MINIMAP_BTN_RIGHT      = "Clic droit : afficher/masquer la fenêtre debug",
        WORLDMAP_SECTION       = "Carte du monde",
        PRESET_BLANK           = "Outline blanc",
        PRESET_VIVID           = "Couleurs vives",
        PRESET_ATLAS           = "Atlas Blizzard",
        PRESET_DEUT            = "Deuteranopia",
        PRESET_PROT            = "Protanopia",
        PRESET_TRIT            = "Tritanopia",

        STATS_TITLE            = "Statistiques de récolte",
        STATS_DESC             = " Total des récoltes depuis l'installation. Ces données ne sont jamais effacées lors d'un import de DB.",
        STATS_RESET            = "Réinitialiser les stats",
        STATS_RESET_DONE       = "Statistiques réinitialisées.",
        STATS_TOTAL            = "Total",

        TYPE_Herbo             = "Herboristerie",
        TYPE_Minage            = "Minage",
        TYPE_Peche             = "Pêche",
        TYPE_Bois              = "Bûcheronnage",
        TYPE_HerboR            = "Herbo Primordiale",
        TYPE_MinageR           = "Minage Primordial",
        TYPE_PecheR            = "Pêche Abondante",

        SKILL_MISSING          = "|cffff4444Compétence non apprise|r",
        TOGGLE_ON              = "|cff00ff00Activé|r",
        TOGGLE_OFF             = "|cffff4444Désactivé|r",
        TOGGLE_HINT            = "Clic pour activer/désactiver",
        EXPANSION              = "Expansion",

        EXPORT_TITLE           = "Exporter la base de données",
        EXPORT_HINT            = " Ctrl+A puis Ctrl+C pour tout copier.",
        IMPORT_TITLE           = "Importer une base de données",
        IMPORT_WARN            = "|cffff8800\226\154\160 Les nœuds importés seront fusionnés avec votre DB actuelle.|r",
        IMPORT_BTN             = "Importer",
        IMPORT_SUCCESS         = " nœud(s) importé(s) avec succès.",
        IMPORT_ERROR           = "Erreur",
        IMPORT_DONE            = "Import terminé — ",
        IMPORT_DONE2           = " nœud(s) ajouté(s).",
        CLOSE                  = "Fermer",
        PROF_DISABLED          = " non détecté(e) — affichage désactivé.",

        DEBUG_TITLE            = "FarmMap.debug",
        DEBUG_CAPTURE          = " Capture",
        DEBUG_CLEAR            = "Effacer",
        DEBUG_COPY             = "Copier",
        DEBUG_COPY_TITLE       = "Copier les logs debug (Ctrl+A, Ctrl+C)",

        -- Une clé par commande : une commande ajoutée plus tard
        -- s'affiche en anglais dans les langues pas encore mises à
        -- jour, au lieu de disparaître de la liste.
        SLASH_HELP_TITLE       = "|cffffd100=== FarmMap — Commandes ===|r",
        SLASH_CMD_HELP         = "afficher cette aide",
        SLASH_CMD_DEBUG        = "afficher/masquer la fenêtre debug",
        SLASH_CMD_EXPORT       = "ouvrir l'export de la DB",
        SLASH_CMD_IMPORT       = "ouvrir l'import de la DB",
        SLASH_CMD_CLEAR        = "vider la base de données",
        SLASH_CMD_STATS        = "afficher les statistiques dans le chat",
        SLASH_CMD_MIGRATE      = "forcer la migration de la DB",
        SLASH_CMD_ATLAS        = "calibreur de coordonnées d'icônes (dev)",
        SLASH_CMD_DEFAULT      = "revenir à la langue du client de jeu",
        SLASH_CMD_VERSION      = "afficher la version de l'addon",

        SLASH_VERSION          = "Version",
        SLASH_CLEAR_CONFIRM    = "DB vidée via commande.",
        SLASH_UNKNOWN          = "Commande inconnue. Tapez /fm help",
        SLASH_DEFAULT_DONE     = "Langue réinitialisée sur celle du client de jeu. Tapez /reload pour appliquer.",

        MIGR_PREFIX            = "FarmMap Migration :",
        MIGR_DONE              = "Base de données à jour",
        MIGR_TOTAL             = "Migration DB terminée —",
        MIGR_ENTRIES           = " entrée(s) corrigée(s).",
        UNKNOWN                = "Inconnu",
        UNKNOWN_EXP            = "Inconnue",

        LANG_SECTION           = "Langue",
        LANG_DESC              = " Langue forcée (ignore la langue du jeu). Rechargement requis.",
        LANG_AUTO              = "Automatique (système)",
        LANG_RELOAD            = "|cffff8800Langue modifiée. /reload pour appliquer.|r",
        LANG_THANKS            = "Merci aux contributeurs pour la traduction de l'addon",

        PANEL_COLORS           = "Couleurs",
        PANEL_PACKS            = "Packs",
        PANEL_STATS            = "Statistiques",
        PACKS_TITLE            = "Packs d'icônes",
        PACKS_DESC             = " Styles issus de sous-addons installés.\n Sélectionner un pack désactive le preset actif dans Couleurs (et inversement).",
        PACKS_EMPTY            = "|cffaaaaaa Aucun pack installé.\n Installez un sous-addon FarmMap_* pour voir les packs ici.|r",

        -- Noms d'extension affichés dans les infobulles de nœuds.
        --
        -- Volontairement laissés en commentaire. FarmMap lit les globales
        -- EXPANSION_NAME<id> de Blizzard, DÉJÀ traduites dans chaque client —
        -- un joueur coréen voit le nom officiel coréen sans que personne
        -- n'ait rien traduit. Décommenter une ligne ici passe devant Blizzard
        -- pour cette langue uniquement : à ne faire que pour la formulation
        -- avec laquelle on n'est pas d'accord.
        --
        -- EXP_0  = "Classic",
        -- EXP_1  = "Burning Crusade",
        -- EXP_2  = "Wrath of the Lich King",
        -- EXP_3  = "Cataclysm",
        -- EXP_4  = "Mists of Pandaria",
        -- EXP_5  = "Warlords of Draenor",
        -- EXP_6  = "Legion",
        -- EXP_7  = "Battle for Azeroth",
        -- EXP_8  = "Shadowlands",
        -- EXP_9  = "Dragonflight",
        -- EXP_10 = "The War Within",
        -- EXP_11 = "Midnight",

        -- /fm atlas — calibreur d'atlas d'icônes. Outil de dev, mais la
        -- page de l'addon y renvoie les créateurs de packs : il doit
        -- donc être lisible par les non-francophones aussi.
        ATLAS_TITLE            = "FarmMap — Calibrage Atlas (ObjectIconsAtlas)",
        ATLAS_HINT             = "Clic gauche + glisse sur l'icône pour la repositionner. La taille reste fixe (32x32), seule la position bouge.",
        ATLAS_PRINT            = "Copier la table",
        ATLAS_RESET            = "Réinitialiser",
        ATLAS_COPY_TITLE       = "FarmMap — Coordonnées Atlas",
        ATLAS_COPY_HINT        = "Déjà sélectionné : Ctrl+C, puis colle dans WORLD_MAP_TEXCOORDS (et BUILTIN_PINS).",
    },
}
