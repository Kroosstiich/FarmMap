-- ============================================================
--  FarmMap — changelog v2.1.2, français
--  Écrit une fois, jamais modifié après la sortie.
--  Affiché par UI\Changelog.lua (fenêtre et page « Quoi de neuf »).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.1.2"] = ns.changelog["2.1.2"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.1.2"].date = "17/10/2026"

ns.changelog["2.1.2"].frFR = {
    {
        kind = "fix",
        entries = {
            { module = "Tableau de bord",
              text = "Sans Auctionator ni TSM, les cases de la valeur et de l'or par heure ne s'affichent plus : elles ne pouvaient que rester vides. Même chose dans la petite fenêtre de session." },
            { module = "Client coréen",
              text = "Des carrés vides n'apparaissent plus dans le tableau de bord et les crédits : ils venaient d'un tiret absent de la police coréenne. Le texte qui demande un addon de prix est aussi plus court, comme l'a proposé un joueur coréen." },
        },
    },
}
