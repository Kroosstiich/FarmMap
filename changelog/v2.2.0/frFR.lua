-- ============================================================
--  FarmMap — changelog v2.2.0, français
--  Écrit une fois, jamais modifié après la sortie.
--  Affiché par UI\Changelog.lua (fenêtre et page « Quoi de neuf »).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.2.0"] = ns.changelog["2.2.0"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.2.0"].date = "21/10/2026"

ns.changelog["2.2.0"].frFR = {
    {
        kind = "new",
        entries = {
            { module = "Route",
              text = "Le nouveau bouton Route, sur la barre de filtres de la carte du monde, trace une boucle entre les nœuds que vous connaissez dans la zone affichée, pour les filtres allumés, sur la carte du monde et sur la minicarte. Dans Intégrations > Route, choisissez son sens et la durée maximale d'un tour, ou demandez une autre route. L'infobulle du bouton et la fenêtre de session indiquent la durée estimée d'un tour, qui s'ajuste à votre vitesse." },
            { module = "Guidage le long de la route",
              text = "Avec TomTom ou WaypointUI, le point de passage passe au nœud suivant de la boucle après chaque récolte, ou en arrivant sur le nœud. Lancez-le depuis le menu du clic droit sur une épingle, la fenêtre de session ou Intégrations > Route. Maj-clic sur le bouton Route pour sauter un nœud déjà pris par un autre joueur." },
            { module = "Dégradés dans les thèmes",
              text = "Dans vos propres thèmes, le fond, les panneaux et les bandeaux peuvent passer à une seconde couleur, de haut en bas. Les dégradés font partie du texte de partage du thème." },
            { module = "Votre langue",
              text = "Sur Retail et WoW: Forever, les recherches ignorent les accents, les listes suivent l'ordre alphabétique de votre langue, et les nombres et les dates suivent son format." },
            { module = "Assistant d'installation",
              text = "Deux nouveaux écrans expliquent la route et son guidage. Si vous avez déjà fait l'assistant, il ne montre que ces deux écrans." },
        },
    },
    {
        kind = "change",
        entries = {
            { module = "Quoi de neuf",
              text = "Cette fenêtre montre maintenant les notes de la série en cours et de la précédente. Les plus anciennes restent derrière le bouton « Voir les anciens changelogs »." },
        },
    },
    {
        kind = "fix",
        entries = {
            { module = "Fenêtre des options",
              text = "Le contour de certains interrupteurs a maintenant la même épaisseur de chaque côté, quels que soient la taille de la fenêtre et le défilement. Avant, il pouvait être plus fin d'un côté." },
        },
    },
}
