-- ============================================================
--  FarmMap — changelog v2.0.0, français
--  Écrit une fois, jamais modifié après la sortie de la version.
--  Affiché par UI\Changelog.lua (fenêtre et page « Quoi de neuf »).
-- ============================================================

local _, ns = ...

ns.changelog = ns.changelog or {}
ns.changelog["2.0.0"] = ns.changelog["2.0.0"] or {}

ns.changelog["2.0.0"].frFR = {
    {
        kind = "new",
        entries = {
            { module = "Nouveaux clients du jeu",
              text = "FarmMap fonctionne maintenant sur WoW: Forever, sur MoP Classic et sur Classic (Era, Saison de la découverte et Hardcore), en plus de Retail. Un seul téléchargement sert pour tous les clients. La Saison de la découverte et Hardcore n'ont pas été testés en jeu, mais ils utilisent le même client que Classic Era. FarmMap se lance aussi sur TBC Anniversary et son interface s'y affiche, mais toutes ses fonctions n'y ont pas encore été testées : signalez-nous tout problème sur le Discord." },
            { module = "Fenêtre d'options",
              text = "Une nouvelle fenêtre réunit tous les réglages, avec un menu par thème et une recherche qui trouve aussi les réglages à l'intérieur des pages. Elle s'ouvre même en combat. L'ancien panneau reste disponible : décochez « Nouvelle fenêtre d'options » dans Affichage." },
            { module = "Taille des fenêtres",
              text = "Agrandissez ou réduisez les fenêtres de FarmMap dans Affichage. Chaque client du jeu garde son propre réglage." },
            { module = "Thèmes",
              text = "Choisissez les couleurs de la fenêtre : Retail (bleu), Forever (brun et or), Émeraude ou Sakura. Chaque client a son thème par défaut. Créez aussi vos propres thèmes dans la page Thème : copiez un thème, changez ses couleurs, puis partagez-le sous forme de texte depuis Import/Export. Un thème ne change que les couleurs, pas les icônes." },
            { module = "Sakura",
              text = "Un nouveau style d'icônes et un thème assorti, dessinés par SorelDesign. Choisissez le style dans Carte et icônes, et le thème dans Thème." },
            { module = "Nouvelle icône",
              text = "FarmMap a une nouvelle icône, dessinée elle aussi par SorelDesign." },
            { module = "Tableau de bord",
              text = "Suivez votre session de farm : durée, nœuds récoltés, valeur aux prix d'Auctionator ou de TSM, or par heure et dernières récoltes. La session continue après un rechargement de l'interface." },
            { module = "Petite fenêtre de session",
              text = "Les mêmes chiffres dans une petite fenêtre à placer où vous voulez, sans ouvrir les options." },
            { module = "Nœuds",
              text = "Retrouvez tous vos nœuds, regroupés par objet et par zone. Cherchez un objet pour savoir où le trouver, filtrez par zone ou par ressource, et supprimez une sélection." },
            { module = "Aperçu de l'import",
              text = "Avant d'importer la base d'un autre joueur, un aperçu indique, zone par zone, les nœuds nouveaux et ceux que vous connaissez déjà. Rien n'est importé sans votre confirmation." },
            { module = "Styles d'icônes",
              text = "Deux nouveaux styles : « WoW Retail », avec les icônes de Blizzard, et l'anneau classique, en blanc ou en couleur. Dans Carte et icônes, survolez une icône pour la voir en grand." },
            { module = "Icône dans l'infobulle",
              text = "L'infobulle d'un nœud affiche maintenant son icône, dans le style choisi pour la carte. Vous pouvez la masquer dans Affichage." },
            { module = "Barre de filtres",
              text = "Les boutons de la barre reprennent maintenant les icônes du style choisi pour la carte du monde, pour que la barre corresponde à la carte. Pour garder les icônes habituelles, décochez « Icônes du style dans la barre » dans Affichage." },
            { module = "Avis de nouvelle version",
              text = "Quand quelqu'un de votre guilde ou de votre groupe utilise une version plus récente de FarmMap, une ligne dans le chat vous le signale. Vous pouvez le désactiver dans Affichage." },
            { module = "TradeSkillMaster",
              text = "TSM peut maintenant estimer vos récoltes, dans le texte flottant et dans le tableau de bord. Si Auctionator est aussi installé, choisissez celui que FarmMap utilise, ainsi que le prix TSM. Testé sur Retail et sur Classic Era." },
            { module = "TomTom et WaypointUI",
              text = "Cliquez sur un nœud de la carte ou de la minicarte pour y placer un point TomTom, avec sa flèche, ou pour que WaypointUI vous y guide. Cliquez à nouveau pour le retirer. Si les deux sont installés, choisissez celui que FarmMap utilise." },
            { module = "Intégrations",
              text = "Une page indique lesquels de ces addons sont installés, avec leur version, et regroupe leurs options. Vous utilisez un autre addon avec lequel FarmMap pourrait fonctionner ? Demandez-le sur le Discord." },
            { module = "Quoi de neuf",
              text = "Cette fenêtre s'ouvre une fois à chaque nouvelle version. Vous la retrouvez à tout moment dans les options." },
        },
    },
    {
        kind = "change",
        entries = {
            { module = "Style « Atlas Blizzard »",
              text = "Il devient « WoW Retail » et utilise des icônes fournies avec FarmMap, car le patch 12.1.0 avait déplacé celles du jeu. Si vous utilisiez l'ancien style, vous passez automatiquement au nouveau." },
            { module = "Infobulle des nœuds",
              text = "Le jeu de base s'affiche maintenant « Vanilla »." },
            { module = "Export",
              text = "L'export indique maintenant le client du jeu dont il vient. À l'import, FarmMap vous prévient si l'export vient d'un autre client, car les cartes n'y portent pas les mêmes numéros. Les exports restent compatibles avec la v1.8, dans les deux sens." },
            { module = "Métiers",
              text = "Un métier appris en cours de session est détecté tout de suite, et les filtres que FarmMap avait désactivés faute de ce métier se réactivent." },
            { module = "Fenêtre de debug",
              text = "Elle a été refaite et n'affiche plus que ce qui concerne vos récoltes." },
        },
    },
    {
        kind = "fix",
        entries = {
            { module = "Valeur dans le texte flottant",
              text = "La valeur d'une récolte est maintenant juste. Avant, la quantité s'ajoutait en pièces de cuivre : 3 objets à 14 pc affichaient 45 pc au lieu de 42." },
            { module = "Sécurité de l'import",
              text = "Un texte importé ne peut plus que décrire des nœuds. Avant, un export piégé, partagé par un autre joueur, pouvait exécuter des actions au nom de FarmMap." },
            { module = "Options en combat",
              text = "Ouvrir l'ancien panneau en combat affiche maintenant le message d'erreur du jeu. Avant, cela déclenchait une erreur d'addon bloqué." },
            { module = "Texte flottant sur un client russe",
              text = "Le texte flottant utilise maintenant la bonne police. Avant, FarmMap cherchait un fichier de police qui n'existe pas." },
            { module = "Vider la base de données",
              text = "La taille et la durée du texte flottant sont maintenant conservées." },
        },
    },
}
