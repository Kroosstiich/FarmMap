-- ============================================================
--  FarmMap — changelog v2.0.1, français
--  Écrit une fois, jamais modifié après la sortie.
--  Affiché par UI\Changelog.lua (fenêtre et page « Quoi de neuf »).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.0.1"] = ns.changelog["2.0.1"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.0.1"].date = "10/10/2026"

ns.changelog["2.0.1"].frFR = {
    {
        kind = "new",
        entries = {
            { module = "Chinois simplifié",
              text = "FarmMap est de nouveau entièrement en chinois, grâce à la traduction de bluse : tous les textes ajoutés par la 2.0, y compris la fenêtre « Quoi de neuf ». Rien d'autre ne change dans cette version." },
        },
    },
}
