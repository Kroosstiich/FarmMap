-- ============================================================
--  FarmMap — changelog v2.1.0, français
--  Écrit une fois, jamais modifié après la sortie.
--  Affiché par UI\Changelog.lua (fenêtre et page « Quoi de neuf »).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.1.0"] = ns.changelog["2.1.0"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.1.0"].date = "14/10/2026"

ns.changelog["2.1.0"].frFR = {
    {
        kind = "new",
        entries = {
            { module = "Assistant d'installation",
              text = "Une nouvelle fenêtre vous présente les principaux réglages de FarmMap, un par écran : à quoi sert chacun, activé ou non, avec une petite scène qui le montre. Elle s'ouvre une fois ; après une mise à jour, elle ne montre que les nouveaux réglages. Sa première page indique où trouver de l'aide, et permet de l'arrêter pour l'instant ou de ne plus jamais la voir. Tapez /fm setup pour la relancer." },
            { module = "Masquer les épingles proches",
              text = "Les épingles proches de votre personnage peuvent disparaître de la minicarte, pour ne plus cacher sa flèche. Choisissez la distance, de 50 à 300 mètres. Désactivé par défaut. Une idée et un code de fiote." },
        },
    },
    {
        kind = "change",
        entries = {
            { module = "Patch 12.1.5",
              text = "FarmMap est à jour pour le patch 12.1.5." },
        },
    },
}
