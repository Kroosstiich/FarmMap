-- ============================================================
--  FarmMap — changelog v2.4.0, français
--  Écrit une fois, jamais modifié après la sortie.
--  Affiché par UI\Changelog.lua (fenêtre et page « Quoi de neuf »).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.4.0"] = ns.changelog["2.4.0"] or {}
-- Release date, shared by every language (same format as ## X-Date).
ns.changelog["2.4.0"].date = "27/11/2026"

ns.changelog["2.4.0"].frFR = {
    {
        kind = "new",
        entries = {
            { module = "Apparence de la route",
              text = "Choisissez la couleur de la route, dans une liste ou la vôtre avec le sélecteur de couleur. Sur Retail et WoW: Forever, la minicarte peut afficher une ligne fine au lieu de points. Réglez l'épaisseur de la ligne sur la minicarte, le radar et la carte du monde, et activez ou non les flèches de direction." },
            { module = "Radar",
              text = "Attribuez-lui une touche pour l'afficher ou le masquer, directement dans ses réglages ou dans les raccourcis clavier du jeu. Il peut aussi se masquer pendant les combats." },
            { module = "Partager dans le chat (bêta)",
              text = "Page Import / Export : placez un court texte dans le chat, et les autres joueurs de FarmMap cliquent dessus pour recevoir vos nœuds, avec l'aperçu habituel. Pas encore testé entre deux joueurs : signalez tout problème sur CurseForge ou sur Discord." },
            { module = "Menu rapide",
              text = "Quand la route est affichée, choisissez points ou ligne pour la minicarte juste en dessous. Une ligne Fenêtre d'options a aussi été ajoutée." },
        },
    },
    {
        kind = "change",
        entries = {
            { module = "Réglages de la route",
              text = "Ils sont maintenant dans Carte et icônes, à côté du radar. Le guidage reste dans Intégrations, car il a besoin de TomTom ou de WaypointUI." },
            { module = "Options du jeu",
              text = "La page FarmMap des options du jeu a un bouton pour ouvrir la fenêtre d'options complète." },
        },
    },
    {
        kind = "fix",
        entries = {
            { module = "Bouton FarmMap",
              text = "Maj + clic ouvre maintenant toujours les options. Avant, si aucun des deux clics n'ouvrait la fenêtre d'options, le bouton ne permettait plus de les ouvrir." },
        },
    },
}
