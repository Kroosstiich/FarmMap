-- ============================================================
--  FarmMap — changelog v2.2.1, français
--  Écrit une fois, jamais modifié après la sortie.
--  Affiché par UI\Changelog.lua (fenêtre et page « Quoi de neuf »).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.2.1"] = ns.changelog["2.2.1"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.2.1"].date = "22/10/2026"

ns.changelog["2.2.1"].frFR = {
    {
        kind = "new",
        entries = {
            { module = "Mise à jour des traductions",
              text = "Coréen" },
        },
    },
    {
        kind = "fix",
        entries = {
            { module = "Dégradés dans les thèmes",
              text = "Les noms des surfaces s'affichent maintenant en entier, et une case décochée se voit bien sur les thèmes sombres." },
        },
    },
}
