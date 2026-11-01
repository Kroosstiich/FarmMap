-- ============================================================
--  FarmMap — changelog v2.3.0, français
--  Écrit une fois, jamais modifié après la sortie.
--  Affiché par UI\Changelog.lua (fenêtre et page « Quoi de neuf »).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.3.0"] = ns.changelog["2.3.0"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.3.0"].date = "01/11/2026"

ns.changelog["2.3.0"].frFR = {
    {
        kind = "new",
        entries = {
            { module = "Radar",
              text = "Un radar transparent au centre de l'écran affiche les nœuds connus autour de vous et la route, avec les points cardinaux. Vos clics le traversent. Activez-le et réglez-le dans Carte et icônes : portée, taille, opacité, rotation avec vous, et la touche à maintenir pour le déplacer." },
            { module = "Menu rapide",
              text = "Faites un clic droit sur le bouton FarmMap, sur la minicarte ou dans une barre comme Titan Panel ou Bazooka, pour activer ou désactiver les herbes, les minerais, les poissons, le bois, la route et son guidage, la fenêtre de session et la fenêtre debug." },
            { module = "Bouton FarmMap",
              text = "Dans Carte et icônes, choisissez ce que font ses clics gauche et droit : fenêtre d'options, menu rapide, fenêtre de session ou fenêtre debug." },
            { module = "Assistant de configuration",
              text = "Deux nouveaux écrans : le bouton FarmMap et le radar. Si vous avez déjà suivi l'assistant, il n'affiche que ces deux écrans." },
        },
    },
    {
        kind = "change",
        entries = {
            { module = "Fenêtre debug",
              text = "Le clic droit sur le bouton FarmMap ouvre maintenant le menu rapide. La fenêtre debug se trouve dans ce menu. Vous pouvez aussi la remettre sur le clic droit dans Carte et icônes." },
        },
    },
}
