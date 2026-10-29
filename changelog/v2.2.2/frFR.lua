-- ============================================================
--  FarmMap — changelog v2.2.2, français
--  Écrit une fois, jamais modifié après la sortie.
--  Affiché par UI\Changelog.lua (fenêtre et page « Quoi de neuf »).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.2.2"] = ns.changelog["2.2.2"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.2.2"].date = "29/10/2026"

ns.changelog["2.2.2"].frFR = {
    {
        kind = "fix",
        entries = {
            { module = "Récolte sur Retail",
              text = "Les herbes et les minerais des anciennes extensions, de l'Outreterre à Khaz Algar, sont maintenant enregistrés. Avant, la plupart de ces récoltes étaient ignorées." },
            { module = "Nom des nœuds",
              text = "Un nœud porte maintenant le nom de son herbe ou de son minerai. Avant, il pouvait prendre le nom d'un objet bonus, comme l'eau cristallisée." },
        },
    },
}
