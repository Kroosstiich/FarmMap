-- ============================================================
--  FarmMap — Addon principal
--  Auteur  : Kroosstii (Dkroosstii-Dalaran)
--  Version : v1.5.0
--  MàJ     : 31/07/2026
-- ============================================================

-- ns : table partagée entre tous les fichiers de l'addon.
-- Les fichiers lang\*.lua y déposent leurs traductions avant
-- que ce fichier ne soit chargé (cf. ordre du .toc).
local addonName, ns = ...
local addonVersion = "v1.5.0"
local lastUpdate   = "31/07/2026"

-- Libs
local HBD     = LibStub("HereBeDragons-2.0")
local HBDPins = LibStub("HereBeDragons-Pins-2.0")

-- Frame principal pour les events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterAllEvents()

-- Version de la structure de la DB (migrations)
local DB_VERSION = 2

-- Locale détectée une seule fois au chargement
local gameLocale = GetLocale()

-- ============================================================
-- DÉCLARATIONS ANTICIPÉES
-- (fonctions définies plus bas mais référencées plus haut)
-- ============================================================

local RefreshAllPins
local RefreshWorldMapPins
local OpenDebugCopyPopup
local RecordStat
local OpenExportPopup
local OpenImportPopup

-- ============================================================
-- CONSTANTES & DONNÉES STATIQUES
-- ============================================================

-- Noms d'extensions par expID (retourné par GetItemInfo)
local expNames = {
    [0]  = "Classic",       [1]  = "TBC",
    [2]  = "WotLK",         [3]  = "Cata",
    [4]  = "MoP",           [5]  = "WoD",
    [6]  = "Legion",        [7]  = "BfA",
    [8]  = "Shadowlands",   [9]  = "Dragonflight",
    [10] = "The War Within",[11] = "Midnight",
}

-- IDs de compétence pour la détection de profession
local PROFESSION_SKILL_IDS = {
    Herbo  = 182,
    Minage = 186,
    Peche  = 356,
}

-- SpellIDs de récolte → type de nœud
-- Ajouter ici les IDs découverts via le debug [SPELL_RAW]
local HARVEST_SPELLS = {
    -- Herbo
        -- Midnight
    [471009] = "Herbo",
        -- Classic
    [265819] = "Herbo",

    -- Minage
        -- Midnight
    [471013] = "Minage",
        -- Classic
    [265837] = "Minage",

    -- Pêche
    [131474]  = "Peche",
    [131476]  = "Peche",
    [1225292] = "Peche",

    -- Bûcheronnage
    [1239682] = "Bois",
}

-- Couleurs RGB par type (utilisées pour les pins et l'UI)
local TYPE_COLORS = {
    Herbo   = {0.2, 0.8, 0.2},
    Minage  = {0.8, 0.5, 0.0},
    Peche   = {0.2, 0.6, 1.0},
    Bois    = {0.9, 0.6, 0.1},
    -- Nœuds primordiaux / abondants (teinte or)
    HerboR  = {0.6, 1.0, 0.2},
    MinageR = {1.0, 0.82, 0.0},
    PecheR  = {0.4, 0.9, 1.0},
}

-- Lookup rapide pour les nœuds riches (teinture or sur les pins)
local RICH_TYPES = { HerboR = true, MinageR = true, PecheR = true }

-- Ordre d'affichage des types dans le panel couleurs
local TYPE_ORDER = { "Peche", "Herbo", "Minage", "Bois" }

-- Chemins de textures
local TEX_PATH     = "Interface\\AddOns\\FarmMap\\Textures\\"
local BLIP_DEFAULT = "Interface\\Minimap\\ObjectIconsAtlas"

-- Compat 12.0.7+ : Minimap:SetBlipTexture() (et les méthodes sœurs SetIconTexture,
-- SetPlayerTexture, SetPOIArrowTexture, SetCorpsePOIArrowTexture, SetStaticPOIArrowTexture)
-- ont été retirées par Blizzard en 12.0.7, SANS remplacement (changelog Widgets officieux :
-- 6 retraits, 0 ajout). Fonctionnalité de remplacement d'atlas natif désactivée en
-- conséquence : HAS_NATIVE_BLIP est figé à false ci-dessous. Si Blizzard restaure un jour
-- ces méthodes, décommente la ligne de détection dynamique (et supprime le "= false" en
-- dessous) : tout le reste (ApplyMinimapStyle, les checks useBlip, etc.) retombe
-- automatiquement sur le système natif sans aucun autre changement nécessaire.
-- local HAS_NATIVE_BLIP = type(Minimap.SetBlipTexture) == "function"
local HAS_NATIVE_BLIP = false

local function SetNativeBlip(tex)
    if HAS_NATIVE_BLIP then
        Minimap:SetBlipTexture(tex)
    end
end

-- Atlas blip pour remplacement Blizzard (minimap uniquement)
local BLIP_TEXTURES = {
    blank        = TEX_PATH .. "atlas-blip-farmmap-whiteoutline",
    vivid        = TEX_PATH .. "atlas-blip-farmmap-vivid",
    deuteranopia = TEX_PATH .. "atlas-blip-farmmap-deuteranopia",
    protanopia   = TEX_PATH .. "atlas-blip-farmmap-protanopia",
    tritanopia   = TEX_PATH .. "atlas-blip-farmmap-tritanopia",
}

-- Coordonnées UV dans l'atlas Blizzard (ObjectIconsAtlas) — worldmap et fallback
-- Calibrées pour le patch 12.0.7 via le calibreur /fm atlas (glisser-déposer,
-- canvas 1024x1024, icônes 32x32). MinageR garde son ancienne position
-- (le minerai brillant n'a pas bougé) : c'est la seule variante "riche"
-- qui ne suit pas automatiquement son type de base.
local WORLD_MAP_TEXCOORDS = {
    Minage  = {0.5073, 0.5385, 0.6070, 0.6352},
    Herbo   = {0.5095, 0.5407, 0.5753, 0.6066},
    Peche   = {0.5081, 0.5401, 0.5389, 0.5684},
    Bois    = {0.4420, 0.4732, 0.4728, 0.5041},
    MinageR = {0.5073, 0.5385, 0.6070, 0.6352},
    HerboR  = {0.5095, 0.5407, 0.5753, 0.6066},
    PecheR  = {0.5081, 0.5401, 0.5389, 0.5684},
}

-- Pins built-in : coordonnées UV dans chaque atlas blip pour les pins HBDPins
-- Même structure que les packs externes (pins par type). Référence
-- WORLD_MAP_TEXCOORDS plutôt que de dupliquer les coordonnées : à chaque
-- patch, une seule table à mettre à jour (cf. /fm atlas).
local BUILTIN_PINS = {}
for presetKey, texPath in pairs(BLIP_TEXTURES) do
    BUILTIN_PINS[presetKey] = {
        Minage  = { tex = texPath, coords = WORLD_MAP_TEXCOORDS.Minage  },
        Herbo   = { tex = texPath, coords = WORLD_MAP_TEXCOORDS.Herbo   },
        Peche   = { tex = texPath, coords = WORLD_MAP_TEXCOORDS.Peche   },
        Bois    = { tex = texPath, coords = WORLD_MAP_TEXCOORDS.Bois    },
        MinageR = { tex = texPath, coords = WORLD_MAP_TEXCOORDS.MinageR },
        HerboR  = { tex = texPath, coords = WORLD_MAP_TEXCOORDS.HerboR  },
        PecheR  = { tex = texPath, coords = WORLD_MAP_TEXCOORDS.PecheR  },
    }
end

-- Couleurs de rareté WoW (qualité 0→6)
local QUALITY_COLORS = {
    [0] = "ff9d9d9d",  -- Gris
    [1] = "ffffffff",  -- Blanc
    [2] = "ff1eff00",  -- Vert
    [3] = "ff0070dd",  -- Bleu
    [4] = "ffa335ee",  -- Violet
    [5] = "ffff8000",  -- Orange
    [6] = "ffe6cc80",  -- Beige
}

-- Textures icônes de rang de craft (tier 1 et 2)
local TIER_TEXTURES = {
    [1] = "Interface\\Professions\\professionsquality12tier1.blp",
    [2] = "Interface\\Professions\\professionsquality12tier2.blp",
}

-- ============================================================
-- SYSTÈME DE STYLES EXTERNES
-- API publique pour les sous-addons (FarmMap_Colors_*)
--
-- Exemple d'utilisation depuis un sous-addon :
--   FarmMapStyles.Register("monpack", {
--       label = "Mon Pack",
--       pins  = {
--           Herbo  = { tex = "Interface\\AddOns\\MonPack\\icons", coords = {...} },
--           Minage = { tex = "...", coords = {...} },
--           Peche  = { tex = "...", coords = {...} },
--           Bois   = { tex = "...", coords = {...} },
--       },
--       blip = "Interface\\AddOns\\MonPack\\atlas-blip",  -- optionnel
--   })
-- ============================================================

FarmMapStyles = {}
local _registeredStyles = {}

-- Enregistre un pack de style. Déclenche un rebuild du panel Couleurs si l'UI est déjà chargée.
function FarmMapStyles.Register(styleKey, data)
    if _registeredStyles[styleKey] then
        print("|cffffd100FarmMap :|r Style déjà enregistré : " .. styleKey)
        return
    end
    if not data or not data.label then
        print("|cffffd100FarmMap :|r Style invalide (label manquant) : " .. tostring(styleKey))
        return
    end
    _registeredStyles[styleKey] = data
    if FarmMap_OnStyleRegistered then FarmMap_OnStyleRegistered(styleKey, data) end
end

-- Retourne les données d'un style enregistré (nil si inconnu)
function FarmMapStyles.Get(styleKey)
    return _registeredStyles[styleKey]
end

-- Retourne la liste de tous les styles : { key, label, hasBlip }
function FarmMapStyles.GetAll()
    local list = {}
    for k, v in pairs(_registeredStyles) do
        table.insert(list, { key = k, label = v.label, hasBlip = v.blip ~= nil })
    end
    return list
end

-- ============================================================
-- LOCALISATION
-- Les langues vivent dans lang\<locale>.lua et s'enregistrent
-- elles-mêmes dans ns.locales (voir lang\README.md).
--
-- Ajouter une langue = déposer un fichier + une ligne dans le
-- .toc. Aucune modification de ce fichier n'est nécessaire.
--
-- Toute clé absente d'une traduction retombe automatiquement
-- sur l'anglais : une traduction partielle ne casse jamais
-- l'addon et n'affiche jamais de texte vide.
-- ============================================================

ns.locales = ns.locales or {}

local L = {}

-- Reconstruit L en place : les closures de l'UI gardent la même
-- référence de table. Base anglaise, puis surcharge par la langue
-- demandée — d'où le repli automatique sur l'anglais.
local function ApplyLanguage(lang)
    wipe(L)

    local base = ns.locales.enUS and ns.locales.enUS.strings
    if base then
        for k, v in pairs(base) do L[k] = v end
    end

    local target = ns.locales[lang] and ns.locales[lang].strings
    if target and target ~= base then
        for k, v in pairs(target) do L[k] = v end
    end

    gameLocale = lang
end

-- Liste des langues disponibles, triée pour le panneau Langue.
local function GetAvailableLocales()
    local list = {}
    for code, data in pairs(ns.locales) do
        list[#list + 1] = { code = code, data = data }
    end
    table.sort(list, function(a, b)
        local oa, ob = a.data.order or 999, b.data.order or 999
        if oa ~= ob then return oa < ob end
        return a.code < b.code
    end)
    return list
end

-- Libellé d'une langue : endonyme + nom latin en repli.
-- Sur un client FR/EN, "한국어" s'affiche en carrés vides ; le
-- suffixe latin garantit que l'entrée reste identifiable.
local function GetLocaleLabel(data)
    if data.latinName and data.latinName ~= data.name then
        return data.name .. " (" .. data.latinName .. ")"
    end
    return data.name or "?"
end

-- Renvoie une chaîne dans la langue du CLIENT, indépendamment de la
-- langue forcée dans l'addon. Sert à /fm default : c'est la commande
-- de secours quand on a forcé une langue qu'on ne sait pas lire — ou
-- qu'on arrive à lire sans la comprendre. Confirmer dans la langue
-- vers laquelle on rebascule est la seule chose sûrement utile.
local function ClientString(key)
    local loc = ns.locales[GetLocale()] or ns.locales.enUS
    return (loc and loc.strings and loc.strings[key]) or L[key] or ""
end

ApplyLanguage(gameLocale)

-- ============================================================
-- MIGRATION DE BASE DE DONNÉES
-- ============================================================

local migrations = {}

-- V1 : ajout des champs name, expName, items, type
migrations[1] = function()
    local fixed = 0
    for mapID, nodes in pairs(FarmMapDB) do
        if type(nodes) == "table" then
            for _, node in ipairs(nodes) do
                if node.name    == nil then node.name    = node.type or L.UNKNOWN ; fixed = fixed + 1 end
                if node.expName == nil then node.expName = L.UNKNOWN_EXP          ; fixed = fixed + 1 end
                if node.items   == nil then node.items   = {}                     ; fixed = fixed + 1 end
                if node.type    == nil then node.type    = L.UNKNOWN              ; fixed = fixed + 1 end
            end
        end
    end
    return fixed
end

-- V2 : ajout des champs itemIDs, nameID, locale
migrations[2] = function()
    local fixed = 0
    for mapID, nodes in pairs(FarmMapDB) do
        if type(nodes) == "table" then
            for _, node in ipairs(nodes) do
                if node.itemIDs == nil then node.itemIDs = {} ; fixed = fixed + 1 end
                if node.nameID  == nil then node.nameID  = 0  ; fixed = fixed + 1 end
                if node.locale  == nil then node.locale  = "unknown" ; fixed = fixed + 1 end
            end
        end
    end
    return fixed
end

local function RunMigrations(verbose)
    local currentVersion = FarmMapDB.version or 0
    if currentVersion >= DB_VERSION then
        if verbose then
            print("|cffffd100FarmMap :|r " .. L.MIGR_DONE .. " (v" .. DB_VERSION .. ").")
        end
        return
    end
    local totalFixed = 0
    for v = currentVersion + 1, DB_VERSION do
        if migrations[v] then
            local fixed = migrations[v]()
            totalFixed = totalFixed + (fixed or 0)
            print("|cffffd100" .. L.MIGR_PREFIX .. "|r v" .. v .. " : " .. (fixed or 0) .. (gameLocale == "frFR" and " correction(s)" or " fix(es)"))
        end
    end
    FarmMapDB.version = DB_VERSION
    if totalFixed > 0 then
        print("|cffffd100FarmMap :|r " .. L.MIGR_TOTAL .. " " .. totalFixed .. L.MIGR_ENTRIES)
    else
        print("|cffffd100FarmMap :|r " .. L.MIGR_DONE .. " (v" .. DB_VERSION .. ").")
    end
end

local function ManualMigration()
    RunMigrations(true)
end

-- ============================================================
-- PROFESSIONS
-- ============================================================

local playerProfessions = {}

local function CheckProfessions()
    playerProfessions = {}
    -- GetProfessions() : prof1, prof2, archéo, pêche, cuisine
    -- ipairs s'arrête au premier nil → pêche jamais détectée sans ce fix
    local p1, p2, p3, p4, p5 = GetProfessions()
    for _, index in ipairs({ p1 or false, p2 or false, p3 or false, p4 or false, p5 or false }) do
        if index then
            local _, _, _, _, _, _, skillLine = GetProfessionInfo(index)
            for profType, id in pairs(PROFESSION_SKILL_IDS) do
                if skillLine == id then playerProfessions[profType] = true end
            end
        end
    end
    -- Si aucune profession détectée, les données ne sont pas encore prêtes :
    -- on ne touche pas aux états persistés pour éviter de les écraser à tort.
    local anyProfFound = next(playerProfessions) ~= nil
    if not anyProfFound then return end
    local checks = {
        { key = "showHerbo",  prof = "Herbo",  label = L.TYPE_Herbo  },
        { key = "showMinage", prof = "Minage", label = L.TYPE_Minage },
        { key = "showPeche",  prof = "Peche",  label = L.TYPE_Peche  },
    }
    for _, c in ipairs(checks) do
        if FarmMapDB[c.key] and not playerProfessions[c.prof] then
            FarmMapDB[c.key] = false
            print("|cffffd100FarmMap :|r " .. c.label .. L.PROF_DISABLED)
        end
    end
end

-- ============================================================
-- SÉRIALISATION DB (import / export)
-- ============================================================

local function SerializeDB()
    local lines = { "return {" }
    for mapID, nodes in pairs(FarmMapDB) do
        if type(nodes) == "table" and #nodes > 0 then
            table.insert(lines, "  [" .. mapID .. "]={")
            for _, n in ipairs(nodes) do
                local items = {}
                for _, item in ipairs(n.items or {}) do
                    table.insert(items, string.format("%q", item))
                end
                table.insert(lines, string.format(
                    "    {x=%.6f,y=%.6f,type=%q,name=%q,expName=%q,items={%s}},",
                    n.x, n.y, n.type or "", n.name or "", n.expName or "",
                    table.concat(items, ",")
                ))
            end
            table.insert(lines, "  },")
        end
    end
    table.insert(lines, "}")
    return table.concat(lines, "\n")
end

local function DeserializeDB(str)
    local fn, err = loadstring(str)
    if not fn then return nil, "Syntaxe invalide : " .. (err or "") end
    local ok, data = pcall(fn)
    if not ok then return nil, "Erreur d'exécution : " .. (data or "") end
    if type(data) ~= "table" then return nil, "Format non reconnu (table attendue)" end
    return data
end

-- ============================================================
-- MINIMAP : STYLE & BLIP
-- ============================================================

-- Retourne la table pins d'un style (built-in ou externe)
local function GetStylePins(styleKey)
    local ext = FarmMapStyles.Get(styleKey)
    if ext and ext.pins then return ext.pins end
    return BUILTIN_PINS[styleKey]
end

local function ApplyMinimapStyle(style)
    local extStyle = FarmMapStyles.Get(style)
    local blipTex  = (extStyle and extStyle.blip) or BLIP_TEXTURES[style]

    if HAS_NATIVE_BLIP and FarmMapDB and FarmMapDB.replaceBlip and blipTex then
        SetNativeBlip(blipTex)
        HBDPins:RemoveAllMinimapIcons(addonName)
        RefreshWorldMapPins()
    else
        SetNativeBlip(BLIP_DEFAULT)
        RefreshAllPins()
    end
end

-- ============================================================
-- FENÊTRE DEBUG
-- ============================================================

local debugHistory = {}
local debugActive  = false

local debugFrame = CreateFrame("Frame", "FarmMapDebug", UIParent, "BackdropTemplate")
debugFrame:SetSize(300, 200)
debugFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -120)
debugFrame:SetBackdrop({
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = {left=3, right=3, top=3, bottom=3}
})
debugFrame:SetBackdropColor(0, 0, 0.15, 0.92)
debugFrame:SetBackdropBorderColor(0.4, 0.4, 0.6, 1)
debugFrame:SetMovable(true)
debugFrame:SetResizable(true)
debugFrame:SetResizeBounds(220, 120)
debugFrame:EnableMouse(true)
debugFrame:Hide()

local debugTitleBar = CreateFrame("Frame", nil, debugFrame, "BackdropTemplate")
debugTitleBar:SetHeight(20)
debugTitleBar:SetPoint("TOPLEFT",  debugFrame, "TOPLEFT",  3, -3)
debugTitleBar:SetPoint("TOPRIGHT", debugFrame, "TOPRIGHT", -3, -3)
debugTitleBar:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground"})
debugTitleBar:SetBackdropColor(0, 0.05, 0.2, 0.95)
debugTitleBar:EnableMouse(true)
debugTitleBar:RegisterForDrag("LeftButton")
debugTitleBar:SetScript("OnDragStart", function() debugFrame:StartMoving() end)
debugTitleBar:SetScript("OnDragStop",  function() debugFrame:StopMovingOrSizing() end)

local debugIcon = debugTitleBar:CreateTexture(nil, "OVERLAY")
debugIcon:SetSize(14, 14)
debugIcon:SetPoint("LEFT", debugTitleBar, "LEFT", 4, 0)
debugIcon:SetTexture("Interface\\Minimap\\ObjectIconsAtlas")
debugIcon:SetTexCoord(0.444, 0.475, 0.805, 0.837)

local debugTitleText = debugTitleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
debugTitleText:SetPoint("LEFT", debugTitleBar, "LEFT", 22, 0)
debugTitleText:SetText(L.DEBUG_TITLE)
debugTitleText:SetTextColor(0.7, 0.8, 1, 1)

local debugCloseBtn = CreateFrame("Button", nil, debugTitleBar)
debugCloseBtn:SetSize(16, 16)
debugCloseBtn:SetPoint("RIGHT", debugTitleBar, "RIGHT", -4, 0)
local debugCloseTex = debugCloseBtn:CreateTexture(nil, "OVERLAY")
debugCloseTex:SetAllPoints()
debugCloseTex:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
debugCloseBtn:SetScript("OnClick", function()
    FarmMapDB.showDebug = false
    debugFrame:Hide()
    if FarmMapShowDebugCheck then FarmMapShowDebugCheck:SetChecked(false) end
end)

local debugText = debugFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
debugText:SetPoint("TOPLEFT",     debugFrame, "TOPLEFT",     8, -28)
debugText:SetPoint("BOTTOMRIGHT", debugFrame, "BOTTOMRIGHT", -8, 34)
debugText:SetJustifyH("LEFT")
debugText:SetJustifyV("TOP")
debugText:SetWordWrap(true)

local debugBottomBar = CreateFrame("Frame", nil, debugFrame, "BackdropTemplate")
debugBottomBar:SetHeight(26)
debugBottomBar:SetPoint("BOTTOMLEFT",  debugFrame, "BOTTOMLEFT",  3, 3)
debugBottomBar:SetPoint("BOTTOMRIGHT", debugFrame, "BOTTOMRIGHT", -3, 3)
debugBottomBar:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground"})
debugBottomBar:SetBackdropColor(0, 0, 0.1, 0.8)

local debugCheckCapture = CreateFrame("CheckButton", nil, debugBottomBar, "UICheckButtonTemplate")
debugCheckCapture:SetSize(20, 20)
debugCheckCapture:SetPoint("LEFT", debugBottomBar, "LEFT", 2, 0)
local debugCheckLabel = debugBottomBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
debugCheckLabel:SetPoint("LEFT", debugCheckCapture, "RIGHT", 0, 0)
debugCheckLabel:SetText("|cffaaaaaa" .. L.DEBUG_CAPTURE .. "|r")
debugCheckCapture:SetScript("OnClick", function(self)
    debugActive = self:GetChecked()
    FarmMapDB.debugCapture = debugActive
end)

local debugClearBtn = CreateFrame("Button", nil, debugBottomBar, "UIPanelButtonTemplate")
debugClearBtn:SetSize(55, 18)
debugClearBtn:SetPoint("LEFT", debugCheckLabel, "RIGHT", 8, 0)
debugClearBtn:SetText(L.DEBUG_CLEAR)
debugClearBtn:SetScript("OnClick", function()
    debugHistory = {}
    debugFrame:SetContent("")
end)

local debugCopyBtn = CreateFrame("Button", nil, debugBottomBar, "UIPanelButtonTemplate")
debugCopyBtn:SetSize(55, 18)
debugCopyBtn:SetPoint("LEFT", debugClearBtn, "RIGHT", 4, 0)
debugCopyBtn:SetText(L.DEBUG_COPY)
debugCopyBtn:SetScript("OnClick", function() OpenDebugCopyPopup() end)

local debugGrip = CreateFrame("Button", nil, debugFrame)
debugGrip:SetSize(14, 14)
debugGrip:SetPoint("BOTTOMRIGHT", debugFrame, "BOTTOMRIGHT", -2, 26)
local debugGripTex = debugGrip:CreateTexture(nil, "OVERLAY")
debugGripTex:SetAllPoints()
debugGripTex:SetTexture("Interface\\Buttons\\UI-MicroButton-MainMenu-Up")
debugGripTex:SetTexCoord(0, 1, 0, 1)
debugGrip:SetScript("OnMouseDown", function() debugFrame:StartSizing("BOTTOMRIGHT") end)
debugGrip:SetScript("OnMouseUp",   function() debugFrame:StopMovingOrSizing() end)

debugFrame:SetScript("OnSizeChanged", function(self)
    debugText:SetPoint("TOPLEFT",     self, "TOPLEFT",     8, -28)
    debugText:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -8, 34)
end)

debugFrame.SetContent = function(self, txt)
    debugText:SetText(txt or "")
end

local function RenderDebug()
    local txt = ""
    for _, line in ipairs(debugHistory) do txt = txt .. line .. "\n" end
    debugFrame:SetContent(txt)
end

local function AddDebug(event, detail)
    if not debugActive then return end
    local msg = "|cffaaaaaa[" .. event .. "]|r " .. (detail or "")
    table.insert(debugHistory, 1, msg)
    if #debugHistory > 200 then table.remove(debugHistory) end
    RenderDebug()
end

OpenDebugCopyPopup = function()
    local function PopulateEditBox(eb)
        local rawLines = {}
        for _, line in ipairs(debugHistory) do
            local clean = line:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
            table.insert(rawLines, clean)
        end
        eb:SetText(table.concat(rawLines, "\n"))
        eb:HighlightText()
    end

    if FarmMapDebugCopy then
        if FarmMapDebugCopy.editBox then PopulateEditBox(FarmMapDebugCopy.editBox) end
        FarmMapDebugCopy:Show()
        return
    end
    local popup = CreateFrame("Frame", "FarmMapDebugCopy", UIParent, "BackdropTemplate")
    popup:SetSize(400, 300)
    popup:SetPoint("CENTER")
    popup:SetFrameStrata("DIALOG")
    popup:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true, tileSize=16, edgeSize=16, insets={left=4,right=4,top=4,bottom=4}})
    popup:SetBackdropColor(0, 0, 0, 0.95)
    popup:EnableMouse(true)

    local popupTitle = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    popupTitle:SetPoint("TOP", popup, "TOP", 0, -10)
    popupTitle:SetText(L.DEBUG_COPY_TITLE)
    popupTitle:SetTextColor(1, 0.82, 0, 1)

    local editBox = CreateFrame("EditBox", nil, popup)
    editBox:SetMultiLine(true)
    editBox:SetMaxLetters(0)
    editBox:SetFontObject(GameFontNormalSmall)
    editBox:SetPoint("TOPLEFT",     popup, "TOPLEFT",     10, -30)
    editBox:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -10, 30)
    editBox:SetAutoFocus(true)
    popup.editBox = editBox

    local closePopup = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    closePopup:SetSize(80, 22)
    closePopup:SetPoint("BOTTOM", popup, "BOTTOM", 0, 6)
    closePopup:SetText(L.CLOSE)
    closePopup:SetScript("OnClick", function() popup:Hide() end)

    PopulateEditBox(editBox)
    popup:Show()
end

-- ============================================================
-- PINS & TOOLTIPS
-- ============================================================

local function CreatePoint(nodeData, isMinimap)
    local f = CreateFrame("Frame", nil, nil)
    f:SetSize(16, 16)
    f:EnableMouse(true)

    f.tex = f:CreateTexture(nil, "OVERLAY")
    f.tex:SetAllPoints()

    local isRich = RICH_TYPES[nodeData.type]

    if isMinimap then
        local style = FarmMapDB and FarmMapDB.minimapStyle or "blank"
        local pins  = GetStylePins(style)
        local pin   = pins and pins[nodeData.type]
        if pin then
            f.tex:SetTexture(pin.tex)
            f.tex:SetTexCoord(unpack(pin.coords))
        else
            local coords = WORLD_MAP_TEXCOORDS[nodeData.type]
            if coords then
                f.tex:SetTexture(BLIP_DEFAULT)
                f.tex:SetTexCoord(unpack(coords))
            else
                f.tex:SetTexture("Interface\\Minimap\\UI-Minimap-Ping-Center")
                f.tex:SetVertexColor(1, 1, 1)
            end
        end
    else
        local style = FarmMapDB and FarmMapDB.worldmapStyle or "atlas"
        local pins  = GetStylePins(style)
        local pin   = pins and pins[nodeData.type]
        if pin then
            f.tex:SetTexture(pin.tex)
            f.tex:SetTexCoord(unpack(pin.coords))
        else
            local coords = WORLD_MAP_TEXCOORDS[nodeData.type]
            if coords then
                f.tex:SetTexture(BLIP_DEFAULT)
                f.tex:SetTexCoord(unpack(coords))
            else
                f.tex:SetTexture("Interface\\Minimap\\UI-Minimap-Ping-Center")
                f.tex:SetVertexColor(1, 1, 1)
            end
        end
    end

    -- Teinture or pour les nœuds riches
    if isRich then
        f.tex:SetVertexColor(1, 0.85, 0.1)
    end

    -- Tooltip au survol
    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        local displayName = nodeData.name
        if nodeData.nameID and nodeData.nameID > 0 then
            local localName = GetItemInfo(nodeData.nameID)
            if localName then displayName = localName end
        end
        GameTooltip:AddLine(displayName or nodeData.type, 1, 0.82, 0)
        if nodeData.expName and nodeData.type ~= "Bois" then
            GameTooltip:AddLine(L.EXPANSION .. " : " .. nodeData.expName, 0.4, 0.6, 1)
        end
        if nodeData.items and #nodeData.items > 0 then
            GameTooltip:AddLine(" ")
            local seen = {}
            for idx, item in ipairs(nodeData.items) do
                local displayItem = item
                local iid = nodeData.itemIDs and nodeData.itemIDs[idx]
                if iid and iid > 0 then
                    local ln = GetItemInfo(iid)
                    if ln then displayItem = ln end
                end
                if not seen[displayItem] then
                    seen[displayItem] = true
                    GameTooltip:AddLine("- " .. displayItem, 1, 1, 1)
                end
            end
        end
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Clic droit : menu contextuel de suppression
    f:SetScript("OnMouseUp", function(self, button)
        if button ~= "RightButton" then return end
        GameTooltip:Hide()

        local menu = CreateFrame("Frame", "FarmMapNodeContextMenu", UIParent, "BackdropTemplate")
        menu:SetSize(180, 32)
        menu:SetFrameStrata("TOOLTIP")
        menu:SetBackdrop({
            bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = {left=2, right=2, top=2, bottom=2}
        })
        menu:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
        menu:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

        local mx, my = GetCursorPosition()
        local s = UIParent:GetEffectiveScale()
        menu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", mx / s, my / s)

        local btnDel = CreateFrame("Button", nil, menu)
        btnDel:SetAllPoints()
        btnDel:SetScript("OnEnter", function(self) self:GetParent():SetBackdropColor(0.8, 0.1, 0.1, 0.9) end)
        btnDel:SetScript("OnLeave", function(self) self:GetParent():SetBackdropColor(0.05, 0.05, 0.05, 0.95) end)

        local lbl = menu:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("LEFT", menu, "LEFT", 8, 0)
        lbl:SetText(L.DELETE_NODE)
        lbl:SetTextColor(1, 0.3, 0.3, 1)

        btnDel:SetScript("OnClick", function()
            if FarmMapDB then
                for mapID, nodes in pairs(FarmMapDB) do
                    if type(nodes) == "table" then
                        for idx, node in ipairs(nodes) do
                            if math.abs(node.x - nodeData.x) + math.abs(node.y - nodeData.y) < 0.0001 then
                                table.remove(nodes, idx)
                                AddDebug("DELETE", nodeData.name or nodeData.type)
                                break
                            end
                        end
                    end
                end
            end
            menu:Hide()
            RefreshAllPins()
        end)

        local dismissFrame = CreateFrame("Frame", nil, UIParent)
        dismissFrame:SetAllPoints(UIParent)
        dismissFrame:SetFrameStrata("DIALOG")
        dismissFrame:EnableMouse(true)
        dismissFrame:SetScript("OnMouseDown", function()
            menu:Hide()
            dismissFrame:Hide()
        end)
        menu:SetFrameStrata("TOOLTIP")
        menu:Show()
    end)

    return f
end

-- ============================================================
-- REFRESH DES PINS
-- ============================================================

local refreshPending = false
local refreshQueued  = false
local MINIMAP_BATCH  = 50
local BATCH_SIZE     = 30

local function ShouldShowNode(nodeType)
    return (nodeType == "Herbo"   and FarmMapDB.showHerbo)  or
           (nodeType == "HerboR"  and FarmMapDB.showHerbo)  or
           (nodeType == "Minage"  and FarmMapDB.showMinage) or
           (nodeType == "MinageR" and FarmMapDB.showMinage) or
           (nodeType == "Peche"   and FarmMapDB.showPeche)  or
           (nodeType == "PecheR"  and FarmMapDB.showPeche)  or
           (nodeType == "Bois"    and FarmMapDB.showBois)
end

local function CollectVisibleNodes()
    local list = {}
    if not FarmMapDB then return list end
    local anyActive = FarmMapDB.showHerbo or FarmMapDB.showMinage or
                      FarmMapDB.showPeche or FarmMapDB.showBois
    if not anyActive then return list end
    for mapID, nodes in pairs(FarmMapDB) do
        if type(nodes) == "table" then
            for _, node in ipairs(nodes) do
                if ShouldShowNode(node.type) then
                    list[#list + 1] = { node = node, mapID = mapID }
                end
            end
        end
    end
    return list
end

local function BatchAddMinimapPins(list, index)
    local limit = math.min(index + MINIMAP_BATCH - 1, #list)
    for i = index, limit do
        local e = list[i]
        HBDPins:AddMinimapIconMap(addonName, CreatePoint(e.node, true), e.mapID, e.node.x, e.node.y, true)
    end
    if limit < #list then
        C_Timer.After(0, function() BatchAddMinimapPins(list, limit + 1) end)
    end
end

local function BatchAddWorldMapPins(list, index)
    local limit = math.min(index + BATCH_SIZE - 1, #list)
    for i = index, limit do
        local e = list[i]
        HBDPins:AddWorldMapIconMap(addonName, CreatePoint(e.node, false), e.mapID, e.node.x, e.node.y)
    end
    if limit < #list then
        C_Timer.After(0, function() BatchAddWorldMapPins(list, limit + 1) end)
    end
end

RefreshWorldMapPins = function()
    HBDPins:RemoveAllWorldMapIcons(addonName)
    if not WorldMapFrame:IsShown() then return end
    local list = CollectVisibleNodes()
    if #list > 0 then BatchAddWorldMapPins(list, 1) end
end

local function DoRefresh()
    refreshPending = false
    HBDPins:RemoveAllMinimapIcons(addonName)
    RefreshWorldMapPins()
    if not FarmMapDB then return end
    -- N'utilise pas les pins HBDPins minimap seulement si un blip natif est actif
    local mmStyle = FarmMapDB.minimapStyle
    local ext     = FarmMapStyles.Get(mmStyle)
    local useBlip = HAS_NATIVE_BLIP and FarmMapDB.replaceBlip and ((ext and ext.blip) or BLIP_TEXTURES[mmStyle])
    if not useBlip and FarmMapDB.showMinimapPins ~= false then
        local list = CollectVisibleNodes()
        if #list > 0 then BatchAddMinimapPins(list, 1) end
    end
    if refreshQueued then
        refreshQueued  = false
        refreshPending = true
        C_Timer.After(0.05, DoRefresh)
    end
end

RefreshAllPins = function()
    if refreshPending then
        refreshQueued = true
        return
    end
    refreshPending = true
    C_Timer.After(0.05, DoRefresh)
end

-- ============================================================
-- TEXTE FLOTTANT À LA RÉCOLTE
-- ============================================================

local function ShowFloatingLoot(items, itemIDs, quantities)
    if not FarmMapDB.showFloatingText then return end
    if not items or #items == 0 then return end

    local duration = FarmMapDB.floatDuration or 5
    local fscale   = FarmMapDB.floatSize     or 1.0
    local showTier = FarmMapDB.showFloatTier ~= false
    local lineH    = math.floor(20 * fscale)
    local padding  = math.floor(4  * fscale)
    local blockW   = math.floor(320 * fscale)
    local blockH   = #items * (lineH + padding)
    local fontSize = math.floor(13 * fscale)
    local iconSize = math.floor(16 * fscale)

    local screenW = UIParent:GetWidth()
    local screenH = UIParent:GetHeight()
    local baseX   = screenW / 2 + math.random(-80, 80)
    local baseY   = screenH * 0.35 + math.random(20, 60)

    local block = CreateFrame("Frame", nil, UIParent)
    block:SetSize(blockW, blockH)
    block:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", baseX - blockW / 2, baseY)

    for i, name in ipairs(items) do
        local colorHex   = "ffffffff"
        local iid        = itemIDs    and itemIDs[i]    or 0
        local qty        = quantities and quantities[i] or 1
        local craftRank  = 0
        local totalInBag = qty

        if iid and iid > 0 then
            local _, _, quality = GetItemInfo(iid)
            if quality then colorHex = QUALITY_COLORS[quality] or "ffffffff" end
            local r = C_TradeSkillUI and C_TradeSkillUI.GetItemReagentQualityByItemInfo and
                      C_TradeSkillUI.GetItemReagentQualityByItemInfo(iid)
            if r and r > 0 then craftRank = r end
            totalInBag = (GetItemCount(iid, false) or 0) + qty
        end

        local lineY   = (i - 1) * (lineH + padding)
        local gap     = 6

        local txtName = block:CreateFontString(nil, "OVERLAY")
        txtName:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
        txtName:SetPoint("BOTTOMLEFT", block, "BOTTOMLEFT", 0, lineY)
        txtName:SetHeight(lineH)
        txtName:SetJustifyH("LEFT")
        txtName:SetJustifyV("MIDDLE")
        txtName:SetText(string.format("|c%s%s|r", colorHex, name))

        local iconTex = nil
        if showTier and craftRank > 0 and TIER_TEXTURES[craftRank] then
            iconTex = block:CreateTexture(nil, "OVERLAY")
            iconTex:SetSize(iconSize, iconSize)
            iconTex:SetTexture(TIER_TEXTURES[craftRank])
            iconTex:SetTexCoord(0.078, 0.094, 0.898, 0.930)
            iconTex:SetPoint("BOTTOMLEFT", block, "BOTTOMLEFT", 0, lineY)
        end

        local txtQty = block:CreateFontString(nil, "OVERLAY")
        txtQty:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
        txtQty:SetHeight(lineH)
        txtQty:SetJustifyH("LEFT")
        txtQty:SetJustifyV("MIDDLE")
        txtQty:SetText(string.format("x%d  |cffaaaaaa(%d)|r", qty, totalInBag))
        txtQty:SetPoint("BOTTOMLEFT", block, "BOTTOMLEFT", 0, lineY)

        C_Timer.After(0, function()
            local nameW = txtName:GetStringWidth()
            if iconTex then
                iconTex:ClearAllPoints()
                iconTex:SetPoint("BOTTOMLEFT", block, "BOTTOMLEFT", nameW + gap, lineY + (lineH - iconSize) / 2)
                txtQty:ClearAllPoints()
                txtQty:SetPoint("BOTTOMLEFT", block, "BOTTOMLEFT", nameW + iconSize + gap * 2, lineY)
            else
                txtQty:ClearAllPoints()
                txtQty:SetPoint("BOTTOMLEFT", block, "BOTTOMLEFT", nameW + gap, lineY)
            end
        end)
    end

    local ag   = block:CreateAnimationGroup()
    local move = ag:CreateAnimation("Translation")
    move:SetDuration(duration)
    move:SetOffset(0, 40)
    move:SetSmoothing("IN")
    local fade = ag:CreateAnimation("Alpha")
    fade:SetDuration(duration)
    fade:SetFromAlpha(1)
    fade:SetToAlpha(0)
    fade:SetSmoothing("OUT")
    ag:SetScript("OnFinished", function() block:Hide() end)
    ag:Play()
end

-- ============================================================
-- CAPTURE ET TRAITEMENT DU LOOT
-- ============================================================

local lastHarvestType = nil
local pendingLoot     = false
local pendingLootData = nil

-- Décalage de position pour la pêche :
-- Le joueur doit se tenir ~15 yards en arrière du pool pour pouvoir lancer.
-- On avance la position dans la direction où il regarde pour marquer le pool.
local FISHING_OFFSET_YARDS = 15

local function GetFishingPosition(mapID)
    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then return nil end

    local facing = GetPlayerFacing()
    if not facing then return pos end

    -- Coordonnées monde (yards) via HBD
    local wx, wy = HBD:GetWorldCoordinatesFromZone(pos.x, pos.y, mapID)
    if not wx then return pos end

    -- Dans WoW : facing 0 = nord, sens horaire.
    -- En coords monde : X croît vers l'est, Y croît vers le nord.
    local dx =  math.sin(facing) * FISHING_OFFSET_YARDS
    local dy = -math.cos(facing) * FISHING_OFFSET_YARDS

    local nx, ny = HBD:GetZoneCoordinatesFromWorld(wx + dx, wy + dy, mapID)
    if not nx or not ny then return pos end

    AddDebug("FISH_OFFSET", string.format("%.4f,%.4f → %.4f,%.4f (facing %.2f°)", pos.x, pos.y, nx, ny, math.deg(facing)))
    return { x = nx, y = ny }
end

local function GetItemIDFromLink(link)
    if not link then return 0 end
    return tonumber(link:match("item:(%d+)")) or 0
end

-- GameObjects à ignorer : spawns invoqués ou contextuels, pas des bancs naturels
local GAMEOBJECT_BLACKLIST = {
    [524813] = true,  -- Oceanic Vortex (Voidstorm / Angler's Anomaly)
}

-- Items à ne pas sauvegarder dans la DB :
-- drops aléatoires présents sur tous les nœuds d'un même type,
-- non spécifiques à la position (motes, knowledge points, bonus random)
local ITEM_BLACKLIST = {
    [237496] = true,  -- (à identifier)
    [238465] = true,  -- (à identifier)
    [238466] = true,  -- (à identifier)
    [237506] = true,  -- (à identifier)
    [238467] = true,  -- (à identifier)
    [237507] = true,  -- (à identifier)
    [236780] = true,  -- (à identifier)
    [237497] = true,  -- (à identifier)
    [237366] = true,  -- (à identifier)
}

local function CaptureLootData()
    -- Vérifie que la source est un GameObject (nœud de récolte, pas un mob)
    local sourceGUID = GetLootSourceInfo(1)
    if sourceGUID then
        local sourceType = sourceGUID:match("^([^%-]+)")
        if sourceType ~= "GameObject" then
            AddDebug("LOOT_SKIP", "source non-GameObject : " .. sourceType)
            return
        end
        -- Extrait l'entryID du GUID (format : Type-0-X-X-X-EntryID-X)
        local entryID = tonumber(sourceGUID:match("%-(%d+)%-%x+$"))
        if entryID and GAMEOBJECT_BLACKLIST[entryID] then
            AddDebug("LOOT_SKIP", "GameObject blacklisté (entryID:" .. entryID .. ")")
            return
        end
    end

    local mapID  = C_Map.GetBestMapForUnit("player")
    local pos    = mapID and C_Map.GetPlayerMapPosition(mapID, "player")
    if not mapID or not pos then return end

    -- Pré-calcul du décalage pêche (le type de récolte n'est pas encore connu ici,
    -- ProcessHarvestLoot choisira entre pos et posFishing selon le type détecté)
    local posFishing = GetFishingPosition(mapID)

    local lootItems, lootItemIDs, lootQuantities, lootQualities = {}, {}, {}, {}
    local nodeName, nodeNameID, extensionName = L.UNKNOWN, 0, L.UNKNOWN_EXP

    for i = 1, GetNumLootItems() do
        local link = GetLootSlotLink(i)
        if link then
            local itemID = GetItemIDFromLink(link)
            local _, slotName, quantity = GetLootSlotInfo(i)
            quantity = (type(quantity) == "number" and quantity > 0) and quantity or 1
            local name, _, quality, _, _, _, _, _, _, _, _, _, _, _, expID = GetItemInfo(link)
            name = name or slotName
            if name and not ITEM_BLACKLIST[itemID] then
                if nodeName == L.UNKNOWN then
                    nodeName      = name
                    nodeNameID    = itemID
                    extensionName = expNames[expID] or ("ID: " .. (expID or "?"))
                end
                table.insert(lootItems,      name)
                table.insert(lootItemIDs,    itemID)
                table.insert(lootQuantities, quantity)
                table.insert(lootQualities,  quality or 1)
                AddDebug("LOOT_SLOT", name .. " x" .. quantity)
            end
        end
    end

    pendingLootData = {
        mapID         = mapID,
        pos           = pos,
        posFishing    = posFishing,
        items         = lootItems,
        itemIDs       = lootItemIDs,
        quantities    = lootQuantities,
        qualities     = lootQualities,
        nodeName      = nodeName,
        nodeNameID    = nodeNameID,
        extensionName = extensionName,
    }
    AddDebug("LOOT_CAPTURE", nodeName .. " (" .. #lootItems .. " slots)")
end

local function ProcessHarvestLoot()
    if not lastHarvestType then
        AddDebug("LOOT", "no harvest spell, ignored")
        return
    end
    if not pendingLootData then
        AddDebug("LOOT", "no loot data, ignored")
        return
    end

    local foundType  = lastHarvestType
    local data       = pendingLootData
    lastHarvestType  = nil
    pendingLootData  = nil

    local mapID          = data.mapID
    local pos            = ((foundType == "Peche" or foundType == "PecheR") and data.posFishing) or data.pos
    pos                  = pos or data.pos  -- fallback si GetFishingPosition a échoué
    local lootItems      = data.items
    local lootItemIDs    = data.itemIDs
    local lootQuantities = data.quantities
    local nodeName       = data.nodeName
    local nodeNameID     = data.nodeNameID
    local extensionName  = data.extensionName

    if nodeName == L.UNKNOWN and #lootItems == 0 then
        AddDebug("LOOT", "empty items, ignored")
        return
    end

    AddDebug("LOOT", foundType .. " : " .. nodeName)

    FarmMapDB[mapID] = FarmMapDB[mapID] or {}
    local isUpdated = false
    for _, existingNode in ipairs(FarmMapDB[mapID]) do
        if existingNode.type == foundType and
           math.abs(existingNode.x - pos.x) + math.abs(existingNode.y - pos.y) < 0.003 then

            existingNode.name    = nodeName
            existingNode.nameID  = nodeNameID
            existingNode.expName = extensionName
            existingNode.locale  = gameLocale
            -- Pêche : fusion des items (le même spot peut donner des poissons différents)
            -- Herbo/Minage : écrase (le nœud repousse avec les mêmes items)
            if foundType == "Peche" or foundType == "PecheR" then
                local seenIDs = {}
                for _, id in ipairs(existingNode.itemIDs or {}) do seenIDs[id] = true end
                for i, id in ipairs(lootItemIDs) do
                    if not seenIDs[id] then
                        seenIDs[id] = true
                        table.insert(existingNode.items,   lootItems[i])
                        table.insert(existingNode.itemIDs, id)
                    end
                end
            else
                existingNode.items   = lootItems
                existingNode.itemIDs = lootItemIDs
            end
            isUpdated = true
            break
        end
    end

    if not isUpdated then
        local node = {
            x       = pos.x,       y       = pos.y,
            type    = foundType,   name    = nodeName,
            nameID  = nodeNameID,  items   = lootItems,
            itemIDs = lootItemIDs, expName = extensionName,
            locale  = gameLocale,
        }
        table.insert(FarmMapDB[mapID], node)
        if ShouldShowNode(foundType) then
            local mmStyle = FarmMapDB.minimapStyle
            local ext     = FarmMapStyles.Get(mmStyle)
            local useBlip = HAS_NATIVE_BLIP and FarmMapDB.replaceBlip and ((ext and ext.blip) or BLIP_TEXTURES[mmStyle])
            if not useBlip and FarmMapDB.showMinimapPins ~= false then
                HBDPins:AddMinimapIconMap(addonName, CreatePoint(node, true), mapID, pos.x, pos.y, true)
            end
            HBDPins:AddWorldMapIconMap(addonName, CreatePoint(node, false), mapID, pos.x, pos.y)
        end
    else
        RefreshAllPins()
    end

    RecordStat(foundType)
    ShowFloatingLoot(lootItems, lootItemIDs, lootQuantities)
end

-- ============================================================
-- STATISTIQUES
-- ============================================================

RecordStat = function(foundType)
    FarmMapStatsDB        = FarmMapStatsDB        or { counts = {} }
    FarmMapStatsDB.counts = FarmMapStatsDB.counts or {}
    -- Les nœuds riches (R) comptent sous la même clé que leur parent
    local statKey = foundType:gsub("R$", "")
    FarmMapStatsDB.counts[statKey] = (FarmMapStatsDB.counts[statKey] or 0) + 1
    if FarmMap_RefreshStats then FarmMap_RefreshStats() end
end

-- ============================================================
-- POPUPS EXPORT / IMPORT
-- ============================================================

OpenExportPopup = function()
    if FarmMapExportPopup then
        if FarmMapExportPopup.eb then
            FarmMapExportPopup.eb:SetText(SerializeDB())
            FarmMapExportPopup.eb:HighlightText()
        end
        FarmMapExportPopup:Show()
        return
    end
    local pop = CreateFrame("Frame", "FarmMapExportPopup", UIParent, "BackdropTemplate")
    pop:SetSize(520, 400)
    pop:SetPoint("CENTER")
    pop:SetFrameStrata("DIALOG")
    pop:SetMovable(true)
    pop:EnableMouse(true)
    pop:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true, tileSize=16, edgeSize=16, insets={left=4,right=4,top=4,bottom=4}})
    pop:SetBackdropColor(0, 0, 0, 0.95)

    local titleBar = CreateFrame("Frame", nil, pop)
    titleBar:SetHeight(24)
    titleBar:SetPoint("TOPLEFT",  pop, "TOPLEFT",  5, -5)
    titleBar:SetPoint("TOPRIGHT", pop, "TOPRIGHT", -5, -5)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() pop:StartMoving() end)
    titleBar:SetScript("OnDragStop",  function() pop:StopMovingOrSizing() end)

    local titleTxt = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleTxt:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    titleTxt:SetText(L.EXPORT_TITLE)
    titleTxt:SetTextColor(1, 0.82, 0, 1)

    local hint = pop:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, -2)
    hint:SetText("|cffaaaaaa" .. L.EXPORT_HINT .. "|r")

    local sf = CreateFrame("ScrollFrame", nil, pop, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT",     pop, "TOPLEFT",     8,  -54)
    sf:SetPoint("BOTTOMRIGHT", pop, "BOTTOMRIGHT", -28, 34)

    local eb = CreateFrame("EditBox", nil, sf)
    eb:SetMultiLine(true)
    eb:SetMaxLetters(0)
    eb:SetFontObject(GameFontNormalSmall)
    eb:SetWidth(sf:GetWidth())
    eb:SetAutoFocus(false)
    eb:SetScript("OnEscapePressed", function() pop:Hide() end)
    sf:SetScrollChild(eb)
    pop.eb = eb

    local btnClose = CreateFrame("Button", nil, pop, "UIPanelButtonTemplate")
    btnClose:SetSize(90, 22)
    btnClose:SetPoint("BOTTOM", pop, "BOTTOM", 0, 7)
    btnClose:SetText(L.CLOSE)
    btnClose:SetScript("OnClick", function() pop:Hide() end)

    eb:SetText(SerializeDB())
    eb:HighlightText()
    pop:Show()
end

OpenImportPopup = function()
    if FarmMapImportPopup then FarmMapImportPopup:Show() return end
    local pop = CreateFrame("Frame", "FarmMapImportPopup", UIParent, "BackdropTemplate")
    pop:SetSize(520, 420)
    pop:SetPoint("CENTER")
    pop:SetFrameStrata("DIALOG")
    pop:SetMovable(true)
    pop:EnableMouse(true)
    pop:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true, tileSize=16, edgeSize=16, insets={left=4,right=4,top=4,bottom=4}})
    pop:SetBackdropColor(0, 0, 0, 0.95)

    local titleBar = CreateFrame("Frame", nil, pop)
    titleBar:SetHeight(24)
    titleBar:SetPoint("TOPLEFT",  pop, "TOPLEFT",  5, -5)
    titleBar:SetPoint("TOPRIGHT", pop, "TOPRIGHT", -5, -5)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() pop:StartMoving() end)
    titleBar:SetScript("OnDragStop",  function() pop:StopMovingOrSizing() end)

    local t = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    t:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    t:SetText(L.IMPORT_TITLE)
    t:SetTextColor(1, 0.82, 0, 1)

    local warn = pop:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    warn:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, -2)
    warn:SetText(L.IMPORT_WARN)

    local status = pop:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("BOTTOMLEFT", pop, "BOTTOMLEFT", 10, 34)
    status:SetText("")

    local sf = CreateFrame("ScrollFrame", nil, pop, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT",     pop, "TOPLEFT",     8,  -56)
    sf:SetPoint("BOTTOMRIGHT", pop, "BOTTOMRIGHT", -28, 58)

    local eb = CreateFrame("EditBox", nil, sf)
    eb:SetMultiLine(true)
    eb:SetMaxLetters(0)
    eb:SetFontObject(GameFontNormalSmall)
    eb:SetWidth(sf:GetWidth())
    eb:SetAutoFocus(true)
    eb:SetScript("OnEscapePressed", function() pop:Hide() end)
    sf:SetScrollChild(eb)

    local btnImport = CreateFrame("Button", nil, pop, "UIPanelButtonTemplate")
    btnImport:SetSize(100, 22)
    btnImport:SetPoint("BOTTOMLEFT", pop, "BOTTOMLEFT", 10, 7)
    btnImport:SetText(L.IMPORT_BTN)
    btnImport:SetScript("OnClick", function()
        local str = eb:GetText()
        local data, err = DeserializeDB(str)
        if not data then
            status:SetText("|cffff4444" .. L.IMPORT_ERROR .. " : " .. (err or "?") .. "|r")
            return
        end
        local added = 0
        for mapID, nodes in pairs(data) do
            if type(nodes) == "table" then
                FarmMapDB[mapID] = FarmMapDB[mapID] or {}
                for _, node in ipairs(nodes) do
                    local dup = false
                    for _, ex in ipairs(FarmMapDB[mapID]) do
                        if math.abs(ex.x - node.x) + math.abs(ex.y - node.y) < 0.003 then
                            dup = true ; break
                        end
                    end
                    if not dup then
                        table.insert(FarmMapDB[mapID], node)
                        added = added + 1
                    end
                end
            end
        end
        RefreshAllPins()
        status:SetText("|cff00ff00" .. added .. L.IMPORT_SUCCESS .. "|r")
        print("|cffffd100FarmMap :|r " .. L.IMPORT_DONE .. added .. L.IMPORT_DONE2)
    end)

    local btnClose = CreateFrame("Button", nil, pop, "UIPanelButtonTemplate")
    btnClose:SetSize(90, 22)
    btnClose:SetPoint("BOTTOMRIGHT", pop, "BOTTOMRIGHT", -10, 7)
    btnClose:SetText(L.CLOSE)
    btnClose:SetScript("OnClick", function() pop:Hide() end)

    pop:Show()
end

-- ============================================================
-- BOUTONS FILTRES (carte du monde)
-- ============================================================

local function CreateFilterButtons()
    local DEFAULT_INSET = { l=3, r=-3, t=-3, b=3 }
    local ICON_INSETS = {
        Herbo  = { l=4, r=-2, t=-4, b=2 },
        Minage = { l=2, r=-4, t=-2, b=4 },
        Peche  = { l=4, r=-2, t=-1, b=5 },
        Bois   = { l=3, r=-3, t=-1, b=5 },
    }

    local function MakeButton(name, nodeType, anchorTo, offsetY)
        local btn = CreateFrame("Button", name, UIParent, "BackdropTemplate")
        btn:SetSize(32, 32)
        btn:SetFrameStrata("HIGH")
        if anchorTo == "map" then
            btn:SetPoint("LEFT", WorldMapFrame, "LEFT", 8, offsetY)
        else
            btn:SetPoint("TOP", anchorTo, "BOTTOM", 0, -4)
        end
        btn:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true, tileSize=16, edgeSize=16, insets={left=2,right=2,top=2,bottom=2}})
        btn:SetBackdropColor(0, 0, 0, 0.8)
        btn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        local tex = btn:CreateTexture(nil, "ARTWORK")
        local ins = ICON_INSETS[nodeType] or DEFAULT_INSET
        tex:SetPoint("TOPLEFT",     btn, "TOPLEFT",     ins.l, ins.t)
        tex:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", ins.r, ins.b)
        local pin = BUILTIN_PINS.vivid and BUILTIN_PINS.vivid[nodeType]
        if pin then
            tex:SetTexture(pin.tex)
            tex:SetTexCoord(unpack(pin.coords))
        end
        btn.tex      = tex
        btn.nodeType = nodeType
        return btn
    end

    local btnHerbo  = MakeButton("FarmMapBtnHerbo",  "Herbo",  "map",    20)
    local btnMinage = MakeButton("FarmMapBtnMinage",  "Minage", btnHerbo,  0)
    local btnPeche  = MakeButton("FarmMapBtnPeche",   "Peche",  btnMinage, 0)
    local btnBois   = MakeButton("FarmMapBtnBois",    "Bois",   btnPeche,  0)

    local allBtns = {
        { btn = btnHerbo,  key = "showHerbo",  prof = "Herbo",  label = L.TYPE_Herbo,  color = TYPE_COLORS.Herbo  },
        { btn = btnMinage, key = "showMinage", prof = "Minage", label = L.TYPE_Minage, color = TYPE_COLORS.Minage },
        { btn = btnPeche,  key = "showPeche",  prof = "Peche",  label = L.TYPE_Peche,  color = TYPE_COLORS.Peche  },
        { btn = btnBois,   key = "showBois",   prof = nil,      label = L.TYPE_Bois,   color = TYPE_COLORS.Bois   },
    }

    for _, b in ipairs(allBtns) do b.btn:SetShown(WorldMapFrame:IsShown()) end

    WorldMapFrame:HookScript("OnShow", function()
        for _, b in ipairs(allBtns) do b.btn:Show() end
        RefreshWorldMapPins()
    end)
    WorldMapFrame:HookScript("OnHide", function()
        for _, b in ipairs(allBtns) do b.btn:Hide() end
        HBDPins:RemoveAllWorldMapIcons(addonName)
    end)

    local function UpdateButtons()
        for _, b in ipairs(allBtns) do
            local locked = b.prof and not playerProfessions[b.prof]
            local active = FarmMapDB[b.key] and not locked
            if active then
                b.btn:SetBackdropBorderColor(b.color[1], b.color[2], b.color[3], 1)
                b.btn.tex:SetDesaturated(false)
                b.btn.tex:SetAlpha(1)
            else
                b.btn:SetBackdropBorderColor(locked and 0.6 or 0.3, locked and 0.1 or 0.3, locked and 0.1 or 0.3, 1)
                b.btn.tex:SetDesaturated(true)
                b.btn.tex:SetAlpha(0.4)
            end
        end
    end

    for _, b in ipairs(allBtns) do
        local data = b
        data.btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            local c = data.color
            GameTooltip:AddLine("FarmMap - " .. data.label, c[1], c[2], c[3])
            if data.prof and not playerProfessions[data.prof] then
                GameTooltip:AddLine(L.SKILL_MISSING, 1, 1, 1)
            else
                GameTooltip:AddLine(FarmMapDB[data.key] and L.TOGGLE_ON or L.TOGGLE_OFF, 1, 1, 1)
                GameTooltip:AddLine(L.TOGGLE_HINT, 0.7, 0.7, 0.7)
            end
            GameTooltip:Show()
        end)
        data.btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        data.btn:SetScript("OnClick", function(self)
            if data.prof and not playerProfessions[data.prof] then return end
            FarmMapDB[data.key] = not FarmMapDB[data.key]
            UpdateButtons()
            RefreshAllPins()
            if GameTooltip:GetOwner() == self then self:GetScript("OnEnter")(self) end
        end)
    end

    FarmMap_UpdateFilterButtons = UpdateButtons
    UpdateButtons()
end

-- ============================================================
-- INTERFACE OPTIONS
-- ============================================================

-- Helper : rangée de preset cliquable dans le panel Couleurs
local function MakePresetRow(parent, anchorFrame, anchorOffsetY, presetKey, dbKey, label)
    local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetSize(280, 30)
    row:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, anchorOffsetY)
    row:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true, tileSize=8, edgeSize=6, insets={left=2,right=2,top=2,bottom=2}})
    row:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    row:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    row.dbKey     = dbKey
    row.presetKey = presetKey

    local lbl = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("LEFT", row, "LEFT", 6, 0)
    lbl:SetWidth(110)
    lbl:SetJustifyH("LEFT")
    lbl:SetText(label)
    lbl:SetTextColor(0.9, 0.9, 0.9, 1)

    local iconSize  = 20
    local startX    = 122
    local ICON_ROW_Y = { Herbo = -2, Peche = 2 }   -- offset vertical (pixels) pour corriger le padding UV

    for i, nodeType in ipairs(TYPE_ORDER) do
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(iconSize, iconSize)
        icon:SetPoint("LEFT", row, "LEFT", startX + (i-1) * (iconSize + 6), ICON_ROW_Y[nodeType] or 0)
        local pins = GetStylePins(presetKey)
        local pin  = pins and pins[nodeType]
        if pin then
            icon:SetTexture(pin.tex)
            icon:SetTexCoord(unpack(pin.coords))
        else
            local coords = WORLD_MAP_TEXCOORDS[nodeType]
            if coords then
                icon:SetTexture(BLIP_DEFAULT)
                icon:SetTexCoord(unpack(coords))
            end
        end
    end

    row:EnableMouse(true)
    row:SetScript("OnMouseDown", function()
        FarmMapDB[dbKey] = presetKey
        if dbKey == "minimapStyle" then
            -- Ancien : activait automatiquement replaceBlip pour les packs externes.
            -- Désactivé avec la fonctionnalité de remplacement d'atlas natif (12.0.7+).
            -- if FarmMapStyles.Get(presetKey) then
            --     FarmMapDB.replaceBlip = true
            --     if FarmMapReplaceBlipCheck then
            --         FarmMapReplaceBlipCheck:SetChecked(true)
            --     end
            -- end
            ApplyMinimapStyle(presetKey)
        else
            RefreshAllPins()
        end
        if FarmMap_SyncColorPanel then FarmMap_SyncColorPanel() end
        if FarmMap_SyncPackPanel  then FarmMap_SyncPackPanel()  end
    end)
    row:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(0.7, 0.7, 0.7, 1) end)
    row:SetScript("OnLeave", function()
        if FarmMap_SyncColorPanel then FarmMap_SyncColorPanel() end
        if FarmMap_SyncPackPanel  then FarmMap_SyncPackPanel()  end
    end)

    return row
end

local function CreateOptions()

    -- ---- PANEL PRINCIPAL ----
    local panel = CreateFrame("Frame", "FarmMapOptionsPanel", UIParent)
    panel.name  = addonName

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(L.OPTIONS_TITLE)

    -- Crédit du traducteur de la langue actuellement affichée.
    local activeLocale   = ns.locales[gameLocale] or ns.locales.enUS
    local translatorName = (activeLocale and activeLocale.translator) or "—"

    local credits = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    credits:SetPoint("TOPLEFT", 16, -45)
    credits:SetJustifyH("LEFT")
    credits:SetText(string.format(
        "|cff00ff00%s :|r Dkroosstii-Dalaran\n|cff00dbff%s :|r Kroosstii\n|cffffd100%s :|r %s\n|cffffffff%s :|r %s\n|cffffffff%s :|r %s",
        L.CREDITS_CREATOR,    L.CREDITS_DISCORD,
        L.CREDITS_TRANSLATOR, translatorName,
        L.CREDITS_VERSION,    addonVersion,
        L.CREDITS_UPDATE,     lastUpdate))

    local dbSep = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dbSep:SetPoint("TOPLEFT", 16, -126)
    dbSep:SetText(L.DB_SECTION)
    dbSep:SetTextColor(1, 0.82, 0, 1)

    local btnReset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnReset:SetSize(160, 25)
    btnReset:SetPoint("TOPLEFT", dbSep, "BOTTOMLEFT", 0, -6)
    btnReset:SetText(L.DB_CLEAR)
    btnReset:SetScript("OnClick", function()
        FarmMapDB = {
            version          = DB_VERSION,
            showDebug        = FarmMapDB.showDebug,
            debugCapture     = FarmMapDB.debugCapture,
            showHerbo        = FarmMapDB.showHerbo,
            showMinage       = FarmMapDB.showMinage,
            showPeche        = FarmMapDB.showPeche,
            showBois         = FarmMapDB.showBois,
            minimapStyle     = FarmMapDB.minimapStyle,
            worldmapStyle    = FarmMapDB.worldmapStyle,
            replaceBlip      = FarmMapDB.replaceBlip,
            showMinimapPins  = FarmMapDB.showMinimapPins,
            language         = FarmMapDB.language,
            showFloatingText = FarmMapDB.showFloatingText,
            -- Position et visibilité du bouton minimap : vider la base
            -- de nœuds ne doit pas replacer le bouton.
            minimapIcon      = FarmMapDB.minimapIcon,
        }
        HBDPins:RemoveAllMinimapIcons(addonName)
        HBDPins:RemoveAllWorldMapIcons(addonName)
        print("|cffffd100FarmMap :|r " .. L.DB_CLEARED)
    end)

    local btnMigrate = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnMigrate:SetSize(160, 25)
    btnMigrate:SetPoint("LEFT", btnReset, "RIGHT", 8, 0)
    btnMigrate:SetText(L.DB_MIGRATE)
    btnMigrate:SetScript("OnClick", function() ManualMigration() end)

    local migrateDesc = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    migrateDesc:SetPoint("TOPLEFT", btnReset, "BOTTOMLEFT", 0, -4)
    migrateDesc:SetText("|cffaaaaaa" .. L.DB_MIGRATE_DESC .. "|r")
    migrateDesc:SetJustifyH("LEFT")

    local btnExport = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnExport:SetSize(100, 25)
    btnExport:SetPoint("TOPLEFT", migrateDesc, "BOTTOMLEFT", 0, -8)
    btnExport:SetText(L.DB_EXPORT)
    btnExport:SetScript("OnClick", function() OpenExportPopup() end)

    local btnImport = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnImport:SetSize(100, 25)
    btnImport:SetPoint("LEFT", btnExport, "RIGHT", 8, 0)
    btnImport:SetText(L.DB_IMPORT)
    btnImport:SetScript("OnClick", function() OpenImportPopup() end)

    local importExportDesc = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    importExportDesc:SetPoint("TOPLEFT", btnExport, "BOTTOMLEFT", 0, -4)
    importExportDesc:SetText("|cffaaaaaa" .. L.DB_EXPORTIMPORT_DESC .. "|r")
    importExportDesc:SetJustifyH("LEFT")

    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)

    -- Mémorisé pour que le bouton minimap puisse ouvrir ce panneau.
    ns.optionsCategory = category

    -- ---- PANEL AFFICHAGE ----
    local displayPanel = CreateFrame("Frame", "FarmMapDisplayPanel", UIParent)
    displayPanel.name  = L.DISPLAY_SECTION

    local displayTitle = displayPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    displayTitle:SetPoint("TOPLEFT", 16, -16)
    displayTitle:SetText(L.DISPLAY_SECTION)

    local checkFloat = CreateFrame("CheckButton", "FarmMapShowFloatCheck", displayPanel, "InterfaceOptionsCheckButtonTemplate")
    checkFloat:SetPoint("TOPLEFT", displayTitle, "BOTTOMLEFT", 0, -10)
    _G[checkFloat:GetName() .. "Text"]:SetText(L.DISPLAY_FLOAT)
    checkFloat:SetChecked(FarmMapDB and FarmMapDB.showFloatingText or false)

    local sliderCount = 0
    local function MakeSlider(parent, anchorFrame, label, minVal, maxVal, step, dbKey, fmt)
        sliderCount = sliderCount + 1
        local sliderName = "FarmMapSlider" .. sliderCount
        local container  = CreateFrame("Frame", nil, parent)
        container:SetSize(280, 50)
        container:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -14)

        local lbl = container:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        lbl:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
        lbl:SetText(label)
        lbl:SetJustifyH("LEFT")

        local valTxt = container:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        valTxt:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)
        valTxt:SetJustifyH("RIGHT")

        local slider = CreateFrame("Slider", sliderName, container, "OptionsSliderTemplate")
        slider:SetSize(260, 16)
        slider:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -18)
        slider:SetMinMaxValues(minVal, maxVal)
        slider:SetValueStep(step)
        slider:SetObeyStepOnDrag(true)
        slider:SetValue(FarmMapDB[dbKey] or minVal)
        _G[sliderName .. "Low"]:SetText(tostring(minVal))
        _G[sliderName .. "High"]:SetText(tostring(maxVal))
        _G[sliderName .. "Text"]:SetText("")
        slider:SetScript("OnValueChanged", function(self)
            local v = self:GetValue()
            valTxt:SetText(string.format(fmt, v))
            FarmMapDB[dbKey] = v
        end)
        valTxt:SetText(string.format(fmt, FarmMapDB[dbKey] or minVal))
        container.slider = slider
        container.lbl    = lbl
        container.valTxt = valTxt
        return container
    end

    local checkTier = CreateFrame("CheckButton", "FarmMapShowTierCheck", displayPanel, "InterfaceOptionsCheckButtonTemplate")
    checkTier:SetPoint("TOPLEFT", checkFloat, "BOTTOMLEFT", 0, -28)
    _G[checkTier:GetName() .. "Text"]:SetText(L.DISPLAY_FLOAT_TIER)
    checkTier:SetChecked(FarmMapDB and FarmMapDB.showFloatTier ~= false)
    checkTier:SetScript("OnClick", function(self) FarmMapDB.showFloatTier = self:GetChecked() end)

    local sliderSize = MakeSlider(displayPanel, checkTier,  L.DISPLAY_FLOAT_SIZE,     0.5, 2.0, 0.1, "floatSize",     "%.1f")
    local sliderDur  = MakeSlider(displayPanel, sliderSize, L.DISPLAY_FLOAT_DURATION, 1,   15,  1,   "floatDuration", "%ds")

    local function UpdateFloatDependents()
        local enabled = FarmMapDB.showFloatingText
        local alpha   = enabled and 1 or 0.4
        checkTier:SetEnabled(enabled)
        _G[checkTier:GetName() .. "Text"]:SetAlpha(alpha)
        for _, s in ipairs({ sliderSize, sliderDur }) do
            s.slider:SetEnabled(enabled)
            s.lbl:SetAlpha(alpha)
            s.valTxt:SetAlpha(alpha)
            _G[s.slider:GetName() .. "Low"]:SetAlpha(alpha)
            _G[s.slider:GetName() .. "High"]:SetAlpha(alpha)
        end
    end

    checkFloat:SetScript("OnClick", function(self)
        FarmMapDB.showFloatingText = self:GetChecked()
        UpdateFloatDependents()
    end)
    displayPanel:SetScript("OnShow", UpdateFloatDependents)
    UpdateFloatDependents()

    Settings.RegisterCanvasLayoutSubcategory(category, displayPanel, L.DISPLAY_SECTION)

    -- ---- PANEL DEBUG ----
    local debugPanel = CreateFrame("Frame", "FarmMapDebugPanel", UIParent)
    debugPanel.name  = L.DEBUG_SECTION

    local debugPanelTitle = debugPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    debugPanelTitle:SetPoint("TOPLEFT", 16, -16)
    debugPanelTitle:SetText(L.DEBUG_SECTION)

    local checkDebug = CreateFrame("CheckButton", "FarmMapShowDebugCheck", debugPanel, "InterfaceOptionsCheckButtonTemplate")
    checkDebug:SetPoint("TOPLEFT", debugPanelTitle, "BOTTOMLEFT", 0, -10)
    _G[checkDebug:GetName() .. "Text"]:SetText(L.DISPLAY_DEBUG)
    checkDebug:SetChecked(FarmMapDB and FarmMapDB.showDebug or false)
    checkDebug:SetScript("OnClick", function(self)
        FarmMapDB.showDebug = self:GetChecked()
        if FarmMapDB.showDebug then FarmMapDebug:Show() else FarmMapDebug:Hide() end
    end)

    -- ---- PANEL LANGUE ----
    local langPanel = CreateFrame("Frame", "FarmMapLangPanel", UIParent)
    langPanel.name  = L.LANG_SECTION

    local langPanelTitle = langPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    langPanelTitle:SetPoint("TOPLEFT", 16, -16)
    langPanelTitle:SetText(L.LANG_SECTION)

    local langDesc = langPanel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    langDesc:SetPoint("TOPLEFT", langPanelTitle, "BOTTOMLEFT", 0, -10)
    langDesc:SetText("|cffaaaaaa" .. L.LANG_DESC .. "|r")
    langDesc:SetJustifyH("LEFT")

    -- Message « /reload requis », ancré sous le sélecteur.
    local langReloadMsg = langPanel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    langReloadMsg:SetText("")

    -- Options construites dynamiquement depuis lang\*.lua : déposer un
    -- fichier de langue suffit, il n'y a rien à modifier ici.
    local LANG_OPTS = { { key = "auto", label = L.LANG_AUTO } }
    for _, entry in ipairs(GetAvailableLocales()) do
        LANG_OPTS[#LANG_OPTS + 1] = {
            key   = entry.code,
            label = GetLocaleLabel(entry.data),
        }
    end

    -- Sélecteur : API Blizzard_Menu (11.0+), l'ancien UIDropDownMenu
    -- ayant été retiré en 11.0. Le libellé du bouton est déduit
    -- automatiquement de l'entrée radio cochée.
    local langDropdown = CreateFrame("DropdownButton", nil, langPanel, "WowStyle1DropdownTemplate")
    langDropdown:SetPoint("TOPLEFT", langDesc, "BOTTOMLEFT", 0, -12)
    langDropdown:SetSize(220, 30)

    local function IsLangSelected(key)
        return (FarmMapDB.language or "auto") == key
    end

    local function SetLangSelected(key)
        FarmMapDB.language = key
        langReloadMsg:SetText(L.LANG_RELOAD)
    end

    langDropdown:SetupMenu(function(_, rootDescription)
        for _, opt in ipairs(LANG_OPTS) do
            rootDescription:CreateRadio(opt.label, IsLangSelected, SetLangSelected, opt.key)
        end
    end)

    langReloadMsg:SetPoint("TOPLEFT", langDropdown, "BOTTOMLEFT", 0, -10)

    -- ---- REMERCIEMENTS TRADUCTEURS ----
    -- Construits depuis les fichiers de langue installés : un nouveau
    -- traducteur apparaît ici sans aucune modification de code.
    local thanksTitle = langPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    thanksTitle:SetPoint("TOPLEFT", langDropdown, "BOTTOMLEFT", 0, -48)
    thanksTitle:SetText(L.LANG_THANKS)
    thanksTitle:SetTextColor(1, 0.82, 0, 1)

    local thanksLines = {}
    for _, entry in ipairs(GetAvailableLocales()) do
        thanksLines[#thanksLines + 1] = string.format(
            "|cffffffff%s|r  -  |cff00dbff%s|r",
            entry.data.name or entry.code,
            entry.data.translator or "?")
    end

    local thanksList = langPanel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    thanksList:SetPoint("TOPLEFT", thanksTitle, "BOTTOMLEFT", 0, -10)
    thanksList:SetJustifyH("LEFT")
    thanksList:SetSpacing(4)
    thanksList:SetText(table.concat(thanksLines, "\n"))

    -- /fm default peut changer la langue pendant que le panneau est
    -- ouvert : on régénère pour que le libellé du bouton suive.
    langPanel:SetScript("OnShow", function()
        langDropdown:GenerateMenu()
    end)

    -- ---- PANEL COULEURS ----
    local colorPanel = CreateFrame("Frame", "FarmMapColorPanel", UIParent)
    colorPanel.name  = L.PANEL_COLORS

    local colorTitle = colorPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    colorTitle:SetPoint("TOPLEFT", 16, -16)
    colorTitle:SetText(L.COLORS_TITLE)

    local colorDesc = colorPanel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    colorDesc:SetPoint("TOPLEFT", 16, -42)
    colorDesc:SetText("|cffaaaaaa" .. L.COLORS_DESC .. "|r")
    colorDesc:SetJustifyH("LEFT")

    local mmSep = colorPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    mmSep:SetPoint("TOPLEFT", colorDesc, "BOTTOMLEFT", 0, -10)
    mmSep:SetText(L.MINIMAP_SECTION)
    mmSep:SetTextColor(1, 0.82, 0, 1)

    -- Compat 12.0.7+ : Minimap:SetBlipTexture n'existe plus (voir HAS_NATIVE_BLIP en
    -- haut du fichier). La case reste visible mais grisée (Disable + texte du label
    -- grisé manuellement) pour que le joueur comprenne que ce n'est pas un bug, juste
    -- une fonctionnalité retirée par Blizzard. blipDesc explique la situation à la place
    -- de l'ancienne description. Si Blizzard restaure les méthodes natives un jour :
    -- remettre SetChecked sur FarmMapDB.replaceBlip, ré-Enable(), remettre l'OnClick
    -- d'origine (cf. historique), et restaurer les anciens textes L.REPLACE_BLIP_DESC.
    local checkBlip = CreateFrame("CheckButton", "FarmMapReplaceBlipCheck", colorPanel, "InterfaceOptionsCheckButtonTemplate")
    checkBlip:SetPoint("TOPLEFT", mmSep, "BOTTOMLEFT", 0, -4)
    _G[checkBlip:GetName() .. "Text"]:SetText(L.REPLACE_BLIP)
    _G[checkBlip:GetName() .. "Text"]:SetTextColor(0.5, 0.5, 0.5)
    checkBlip:SetChecked(false)
    checkBlip:Disable()

    local blipDesc = colorPanel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    blipDesc:SetPoint("TOPLEFT", checkBlip, "BOTTOMLEFT", 20, -2)
    blipDesc:SetText("|cffaaaaaa" .. L.REPLACE_BLIP_DESC .. "|r")
    blipDesc:SetJustifyH("LEFT")

    -- Case fonctionnelle, indépendante de checkBlip : affiche ou masque les pins
    -- FarmMap (HBDPins) sur la minimap. La carte du monde n'est jamais concernée,
    -- elle garde toujours ses pins personnalisés.
    local checkPins = CreateFrame("CheckButton", "FarmMapShowMinimapPinsCheck", colorPanel, "InterfaceOptionsCheckButtonTemplate")
    checkPins:SetPoint("TOPLEFT", blipDesc, "BOTTOMLEFT", -20, -8)
    _G[checkPins:GetName() .. "Text"]:SetText(L.SHOW_MINIMAP_PINS)
    checkPins:SetChecked(FarmMapDB and FarmMapDB.showMinimapPins ~= false)
    checkPins:SetScript("OnClick", function(self)
        FarmMapDB.showMinimapPins = self:GetChecked()
        RefreshAllPins()
    end)

    -- Bouton minimap (LibDBIcon). La case est masquée si les libs sont
    -- absentes — l'addon reste fonctionnel sans elles.
    local checkMinimapBtn
    if ns.HasMinimapButton and ns.HasMinimapButton() then
        checkMinimapBtn = CreateFrame("CheckButton", "FarmMapShowMinimapButtonCheck", colorPanel, "InterfaceOptionsCheckButtonTemplate")
        checkMinimapBtn:SetPoint("TOPLEFT", checkPins, "BOTTOMLEFT", 0, -4)
        _G[checkMinimapBtn:GetName() .. "Text"]:SetText(L.SHOW_MINIMAP_BUTTON)
        checkMinimapBtn:SetChecked(not (FarmMapDB.minimapIcon and FarmMapDB.minimapIcon.hide))
        checkMinimapBtn:SetScript("OnClick", function(self)
            ns.SetMinimapButtonShown(self:GetChecked())
        end)
    end

    local mmAnchor = colorPanel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    mmAnchor:SetPoint("TOPLEFT", checkMinimapBtn or checkPins, "BOTTOMLEFT", 0, -6)
    mmAnchor:SetText("")

    local wmSep = colorPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    wmSep:SetText(L.WORLDMAP_SECTION)
    wmSep:SetTextColor(1, 0.82, 0, 1)

    local wmAnchor = colorPanel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    wmAnchor:SetText("")

    local mmRows = {}
    local wmRows = {}

    -- Presets intégrés (fixes)
    local MM_PRESETS_BASE = {
        { key = "blank",        label = L.PRESET_BLANK },
        { key = "vivid",        label = L.PRESET_VIVID },
        { key = "deuteranopia", label = L.PRESET_DEUT  },
        { key = "protanopia",   label = L.PRESET_PROT  },
        { key = "tritanopia",   label = L.PRESET_TRIT  },
    }
    local WM_PRESETS_BASE = {
        { key = "atlas",        label = L.PRESET_ATLAS },
        { key = "blank",        label = L.PRESET_BLANK },
        { key = "vivid",        label = L.PRESET_VIVID },
        { key = "deuteranopia", label = L.PRESET_DEUT  },
        { key = "protanopia",   label = L.PRESET_PROT  },
        { key = "tritanopia",   label = L.PRESET_TRIT  },
    }

    -- Rebuild des rows built-in uniquement (pas de styles externes ici)
    local function BuildPresetRows()
        for _, row in ipairs(mmRows) do row:Hide() ; row:SetParent(nil) end
        for _, row in ipairs(wmRows) do row:Hide() ; row:SetParent(nil) end
        wipe(mmRows)
        wipe(wmRows)

        for i, preset in ipairs(MM_PRESETS_BASE) do
            local row = MakePresetRow(colorPanel, mmAnchor, -(i-1)*34 - 2, preset.key, "minimapStyle", preset.label)
            table.insert(mmRows, row)
        end

        wmSep:ClearAllPoints()
        wmSep:SetPoint("TOPLEFT", mmRows[#mmRows], "BOTTOMLEFT", 0, -14)

        wmAnchor:ClearAllPoints()
        wmAnchor:SetPoint("TOPLEFT", wmSep, "BOTTOMLEFT", 0, -4)

        for i, preset in ipairs(WM_PRESETS_BASE) do
            local row = MakePresetRow(colorPanel, wmAnchor, -(i-1)*34 - 2, preset.key, "worldmapStyle", preset.label)
            table.insert(wmRows, row)
        end

        if FarmMap_SyncColorPanel then FarmMap_SyncColorPanel() end
    end

    -- Sync visuel : désactive la sélection si le style actif est un pack externe
    local function SyncColorPanel()
        local mmStyle = FarmMapDB.minimapStyle  or "blank"
        local wmStyle = FarmMapDB.worldmapStyle or "atlas"
        -- checkBlip est désactivée (Disable) et toujours décochée, rien à synchroniser ici
        for _, row in ipairs(mmRows) do
            local active = (row.presetKey == mmStyle) and not FarmMapStyles.Get(mmStyle)
            if active then
                row:SetBackdropBorderColor(1, 0.82, 0, 1)
                row:SetBackdropColor(0.15, 0.12, 0, 0.9)
            else
                row:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                row:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
            end
        end
        for _, row in ipairs(wmRows) do
            local active = (row.presetKey == wmStyle) and not FarmMapStyles.Get(wmStyle)
            if active then
                row:SetBackdropBorderColor(1, 0.82, 0, 1)
                row:SetBackdropColor(0.15, 0.12, 0, 0.9)
            else
                row:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                row:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
            end
        end
    end

    FarmMap_SyncColorPanel = SyncColorPanel
    colorPanel:SetScript("OnShow", SyncColorPanel)
    BuildPresetRows()

    -- ---- PANEL PACKS ----
    local packPanel = CreateFrame("Frame", "FarmMapPackPanel", UIParent)
    packPanel.name  = L.PANEL_PACKS

    local packTitle = packPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    packTitle:SetPoint("TOPLEFT", 16, -16)
    packTitle:SetText(L.PACKS_TITLE)

    local packDesc = packPanel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    packDesc:SetPoint("TOPLEFT", 16, -42)
    packDesc:SetText("|cffaaaaaa" .. L.PACKS_DESC .. "|r")
    packDesc:SetJustifyH("LEFT")

    local packScroll = CreateFrame("ScrollFrame", "FarmMapPackScroll", packPanel, "UIPanelScrollFrameTemplate")
    packScroll:SetPoint("TOPLEFT",     packDesc,  "BOTTOMLEFT",  0,  -10)
    packScroll:SetPoint("BOTTOMRIGHT", packPanel, "BOTTOMRIGHT", -28, 10)

    local packContent = CreateFrame("Frame", nil, packScroll)
    packContent:SetWidth(320)
    packScroll:SetScrollChild(packContent)

    local packEmpty = packContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    packEmpty:SetPoint("TOPLEFT", packContent, "TOPLEFT", 0, -10)
    packEmpty:SetJustifyH("LEFT")
    packEmpty:SetText(L.PACKS_EMPTY)

    local pkMmSep = packContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    pkMmSep:SetText(L.MINIMAP_SECTION)
    pkMmSep:SetTextColor(1, 0.82, 0, 1)

    local pkMmAnchor = packContent:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    pkMmAnchor:SetText("")

    local pkWmSep = packContent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    pkWmSep:SetText(L.WORLDMAP_SECTION)
    pkWmSep:SetTextColor(1, 0.82, 0, 1)

    local pkWmAnchor = packContent:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    pkWmAnchor:SetText("")

    local pkMmRows = {}
    local pkWmRows = {}

    -- Rebuild des rows de packs externes
    local function BuildPackRows()
        for _, row in ipairs(pkMmRows) do row:Hide() ; row:SetParent(nil) end
        for _, row in ipairs(pkWmRows) do row:Hide() ; row:SetParent(nil) end
        wipe(pkMmRows)
        wipe(pkWmRows)

        local packs = FarmMapStyles.GetAll()
        local hasPacks = #packs > 0

        packEmpty:SetShown(not hasPacks)
        pkMmSep:SetShown(hasPacks)
        pkMmAnchor:SetShown(hasPacks)
        pkWmSep:SetShown(hasPacks)
        pkWmAnchor:SetShown(hasPacks)

        if not hasPacks then
            packContent:SetHeight(40)
            return
        end

        pkMmSep:ClearAllPoints()
        pkMmSep:SetPoint("TOPLEFT", packContent, "TOPLEFT", 0, -10)

        pkMmAnchor:ClearAllPoints()
        pkMmAnchor:SetPoint("TOPLEFT", pkMmSep, "BOTTOMLEFT", 0, -4)

        for i, s in ipairs(packs) do
            local row = MakePresetRow(packContent, pkMmAnchor, -(i-1)*34 - 2, s.key, "minimapStyle", s.label)
            table.insert(pkMmRows, row)
        end

        pkWmSep:ClearAllPoints()
        pkWmSep:SetPoint("TOPLEFT", pkMmRows[#pkMmRows], "BOTTOMLEFT", 0, -14)

        pkWmAnchor:ClearAllPoints()
        pkWmAnchor:SetPoint("TOPLEFT", pkWmSep, "BOTTOMLEFT", 0, -4)

        for i, s in ipairs(packs) do
            local row = MakePresetRow(packContent, pkWmAnchor, -(i-1)*34 - 2, s.key, "worldmapStyle", s.label)
            table.insert(pkWmRows, row)
        end

        local n = #packs
        packContent:SetHeight(10 + 20 + n * 34 + 14 + 20 + n * 34 + 20)

        if FarmMap_SyncPackPanel then FarmMap_SyncPackPanel() end
    end

    -- Sync visuel packs : désactive si le style actif est un preset built-in
    local function SyncPackPanel()
        local mmStyle = FarmMapDB.minimapStyle  or "blank"
        local wmStyle = FarmMapDB.worldmapStyle or "atlas"
        for _, row in ipairs(pkMmRows) do
            local active = (row.presetKey == mmStyle) and FarmMapStyles.Get(mmStyle) ~= nil
            if active then
                row:SetBackdropBorderColor(1, 0.82, 0, 1)
                row:SetBackdropColor(0.15, 0.12, 0, 0.9)
            else
                row:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                row:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
            end
        end
        for _, row in ipairs(pkWmRows) do
            local active = (row.presetKey == wmStyle) and FarmMapStyles.Get(wmStyle) ~= nil
            if active then
                row:SetBackdropBorderColor(1, 0.82, 0, 1)
                row:SetBackdropColor(0.15, 0.12, 0, 0.9)
            else
                row:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                row:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
            end
        end
    end

    FarmMap_SyncPackPanel = SyncPackPanel
    packPanel:SetScript("OnShow", SyncPackPanel)

    -- Callback déclenché par FarmMapStyles.Register (sous-addon chargé après l'UI)
    FarmMap_OnStyleRegistered = function(styleKey, data)
        BuildPackRows()
        -- Sync Couleurs aussi (pour déselectionner si besoin)
        if FarmMap_SyncColorPanel then FarmMap_SyncColorPanel() end
    end

    BuildPackRows()

    local colorCategory = Settings.RegisterCanvasLayoutSubcategory(category, colorPanel, L.PANEL_COLORS)
    Settings.RegisterCanvasLayoutSubcategory(colorCategory, packPanel, L.PANEL_PACKS)
    Settings.RegisterCanvasLayoutSubcategory(category, langPanel,    L.LANG_SECTION)

    -- ---- PANEL STATISTIQUES ----
    local statsPanel = CreateFrame("Frame", "FarmMapStatsPanel", UIParent)
    statsPanel.name  = L.PANEL_STATS

    local statsTitle = statsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    statsTitle:SetPoint("TOPLEFT", 16, -16)
    statsTitle:SetText(L.STATS_TITLE)

    local statsDesc = statsPanel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    statsDesc:SetPoint("TOPLEFT", 16, -42)
    statsDesc:SetText("|cffaaaaaa" .. L.STATS_DESC .. "|r")
    statsDesc:SetJustifyH("LEFT")

    local TYPE_LABELS = {
        { key = "Herbo",  label = L.TYPE_Herbo,  color = TYPE_COLORS.Herbo  },
        { key = "Minage", label = L.TYPE_Minage, color = TYPE_COLORS.Minage },
        { key = "Peche",  label = L.TYPE_Peche,  color = TYPE_COLORS.Peche  },
        { key = "Bois",   label = L.TYPE_Bois,   color = TYPE_COLORS.Bois   },
    }

    local statLines = {}
    for i, t in ipairs(TYPE_LABELS) do
        local row = statsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        row:SetPoint("TOPLEFT", 16, -70 - (i-1) * 24)
        row:SetJustifyH("LEFT")
        row.typeKey = t.key
        row.label   = t.label
        row.color   = t.color
        table.insert(statLines, row)
    end

    local totalLine = statsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    totalLine:SetPoint("TOPLEFT", 16, -70 - #TYPE_LABELS * 24 - 8)
    totalLine:SetJustifyH("LEFT")

    local btnResetStats = CreateFrame("Button", nil, statsPanel, "UIPanelButtonTemplate")
    btnResetStats:SetSize(160, 22)
    btnResetStats:SetPoint("TOPLEFT", 16, -70 - #TYPE_LABELS * 24 - 40)
    btnResetStats:SetText(L.STATS_RESET)
    btnResetStats:SetScript("OnClick", function()
        FarmMapStatsDB = { counts = {} }
        if FarmMap_RefreshStats then FarmMap_RefreshStats() end
        print("|cffffd100FarmMap :|r " .. L.STATS_RESET_DONE)
    end)

    local function RefreshStats()
        local counts = FarmMapStatsDB and FarmMapStatsDB.counts or {}
        local total  = 0
        for _, row in ipairs(statLines) do
            local n   = counts[row.typeKey] or 0
            total     = total + n
            local c   = row.color
            local hex = string.format("%02x%02x%02x", c[1]*255, c[2]*255, c[3]*255)
            row:SetText(string.format("|cff%s%s|r  :  |cffffffff%d|r", hex, row.label, n))
        end
        totalLine:SetText(string.format("|cffffd100%s :|r  |cffffffff%d|r", L.STATS_TOTAL, total))
    end

    FarmMap_RefreshStats = RefreshStats
    RefreshStats()
    statsPanel:SetScript("OnShow", RefreshStats)

    Settings.RegisterCanvasLayoutSubcategory(category, statsPanel,   L.PANEL_STATS)
    Settings.RegisterCanvasLayoutSubcategory(category, debugPanel,   L.DEBUG_SECTION)
end

-- ============================================================
-- BOUTON MINIMAP (LibDBIcon)
-- Les deux libs sont traitées comme optionnelles : si elles
-- manquent, l'addon se charge normalement et seul le bouton est
-- absent (la case correspondante est alors masquée des options).
-- ============================================================

local LDB     = LibStub and LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)

function ns.HasMinimapButton()
    return (LDB ~= nil and LDBIcon ~= nil)
end

function ns.SetMinimapButtonShown(shown)
    if not ns.HasMinimapButton() then return end
    FarmMapDB.minimapIcon = FarmMapDB.minimapIcon or {}
    FarmMapDB.minimapIcon.hide = not shown
    if shown then
        LDBIcon:Show(addonName)
    else
        LDBIcon:Hide(addonName)
    end
end

local function CreateMinimapButton()
    if not ns.HasMinimapButton() then return end
    if LDBIcon:IsRegistered(addonName) then return end

    -- NewDataObject renvoie nil si le nom est déjà pris (rechargement
    -- de l'addon sans relog) : on récupère l'objet existant.
    local dataObject = LDB:GetDataObjectByName(addonName) or LDB:NewDataObject(addonName, {
        type = "launcher",
        text = addonName,
        icon = TEX_PATH .. "icon",

        OnClick = function(_, button)
            if button == "RightButton" then
                FarmMapDB.showDebug = not FarmMapDB.showDebug
                if FarmMapDB.showDebug then FarmMapDebug:Show() else FarmMapDebug:Hide() end
                if FarmMapShowDebugCheck then
                    FarmMapShowDebugCheck:SetChecked(FarmMapDB.showDebug)
                end
            elseif ns.optionsCategory then
                Settings.OpenToCategory(ns.optionsCategory:GetID())
            end
        end,

        OnTooltipShow = function(tooltip)
            tooltip:AddLine(addonName, 1, 0.82, 0)
            tooltip:AddLine(" ")
            tooltip:AddLine(L.MINIMAP_BTN_LEFT,  0.9, 0.9, 0.9)
            tooltip:AddLine(L.MINIMAP_BTN_RIGHT, 0.9, 0.9, 0.9)
        end,
    })

    if not dataObject then return end

    -- LibDBIcon écrit la position du bouton dans cette table, elle doit
    -- donc être persistée dans les SavedVariables.
    FarmMapDB.minimapIcon = FarmMapDB.minimapIcon or { hide = false }
    LDBIcon:Register(addonName, dataObject, FarmMapDB.minimapIcon)
end

-- ============================================================
-- GESTION DES EVENTS
-- ============================================================

-- Filtre pour AddDebug (seuls ces events sont loggés)
local farmMapEvents = {
    ADDON_LOADED             = true,
    LOOT_READY               = true,
    PLAYER_LOGIN             = true,
    UNIT_SPELLCAST_SUCCEEDED = true,
}

eventFrame:SetScript("OnEvent", function(self, event, ...)
    local arg1 = ...

    if farmMapEvents[event] then
        AddDebug(event, tostring(arg1 or ""))
    end

    -- ---- Chargement de l'addon ----
    if event == "ADDON_LOADED" and arg1 == addonName then
        FarmMapDB = FarmMapDB or {}
        -- Valeurs par défaut
        FarmMapDB.showDebug        = FarmMapDB.showDebug        ~= nil and FarmMapDB.showDebug        or false
        FarmMapDB.debugCapture     = FarmMapDB.debugCapture     ~= nil and FarmMapDB.debugCapture     or false
        FarmMapDB.showFloatingText = FarmMapDB.showFloatingText ~= nil and FarmMapDB.showFloatingText or false
        FarmMapDB.floatSize        = FarmMapDB.floatSize        ~= nil and FarmMapDB.floatSize        or 1.0
        FarmMapDB.floatDuration    = FarmMapDB.floatDuration    ~= nil and FarmMapDB.floatDuration    or 5
        if FarmMapDB.showFloatTier == nil then FarmMapDB.showFloatTier = true end
        if FarmMapDB.showHerbo    == nil then FarmMapDB.showHerbo    = true end
        if FarmMapDB.showMinage   == nil then FarmMapDB.showMinage   = true end
        if FarmMapDB.showPeche    == nil then FarmMapDB.showPeche    = true end
        if FarmMapDB.showBois     == nil then FarmMapDB.showBois     = true end
        if FarmMapDB.showMinimapPins == nil then FarmMapDB.showMinimapPins = true end
        FarmMapDB.minimapStyle     = FarmMapDB.minimapStyle     ~= nil and FarmMapDB.minimapStyle     or "blank"
        FarmMapDB.worldmapStyle    = FarmMapDB.worldmapStyle    ~= nil and FarmMapDB.worldmapStyle    or "atlas"
        FarmMapDB.replaceBlip      = FarmMapDB.replaceBlip      ~= nil and FarmMapDB.replaceBlip      or false
        FarmMapDB.language         = FarmMapDB.language         or "auto"
        -- Table gérée par LibDBIcon (position angulaire + hide).
        FarmMapDB.minimapIcon      = FarmMapDB.minimapIcon      or { hide = false }

        FarmMapStatsDB        = FarmMapStatsDB        or {}
        FarmMapStatsDB.counts = FarmMapStatsDB.counts or {}

        -- Applique la langue sauvegardée si elle diffère du système
        local savedLang = FarmMapDB.language
        if savedLang ~= "auto" and savedLang ~= GetLocale() then
            ApplyLanguage(savedLang)
        end

        -- Alias de commandes localisés. Après ApplyLanguage, pour
        -- suivre la langue réellement active, et pas celle du client.
        ns.SetupSlashLocalization()

        -- Restaure l'état de la capture debug
        debugActive = FarmMapDB.debugCapture
        debugCheckCapture:SetChecked(debugActive)

        RunMigrations()
        -- Avant CreateOptions : initialise FarmMapDB.minimapIcon, que la
        -- case « afficher le bouton minimap » lit pour son état initial.
        CreateMinimapButton()
        CreateOptions()
        CreateFilterButtons()

        if FarmMapDB.showDebug then FarmMapDebug:Show() end

        C_Timer.After(1, function()
            ApplyMinimapStyle(FarmMapDB.minimapStyle or "blank")
        end)

    -- ---- Login joueur ----
    elseif event == "PLAYER_LOGIN" then
        C_Timer.After(0.5, function()
            CheckProfessions()
            if FarmMap_UpdateFilterButtons then FarmMap_UpdateFilterButtons() end
            ApplyMinimapStyle(FarmMapDB.minimapStyle or "blank")
        end)

    -- ---- Détection de récolte ----
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = ...
        if unit == "player" then
            AddDebug("SPELL_RAW", "spellID:" .. tostring(spellID))
            local harvestType = HARVEST_SPELLS[spellID]
            if harvestType then
                lastHarvestType = harvestType
                AddDebug("SPELL", harvestType .. " (spellID:" .. spellID .. ")")
                if pendingLoot then
                    pendingLoot = false
                    ProcessHarvestLoot()
                else
                    C_Timer.After(5, function() lastHarvestType = nil end)
                end
            end
        end

    -- ---- Remise à jour du blip après changement de zone ----
    elseif event == "MINIMAP_UPDATE_TRACKING" or event == "ZONE_CHANGED_NEW_AREA" then
        if FarmMapDB and FarmMapDB.replaceBlip then
            ApplyMinimapStyle(FarmMapDB.minimapStyle or "blank")
        end

    -- ---- Loot prêt ----
    elseif event == "LOOT_READY" then
        CaptureLootData()
        pendingLoot = true
        if lastHarvestType then
            pendingLoot = false
            ProcessHarvestLoot()
        else
            C_Timer.After(5, function()
                if pendingLoot then
                    pendingLoot     = false
                    pendingLootData = nil
                    AddDebug("LOOT", "timeout — no spell detected, ignored")
                end
            end)
        end
    end
end)

-- ============================================================
-- CALIBREUR D'ATLAS (OUTIL DEV — /fm atlas)
-- Sert à retrouver visuellement les coordonnées UV des icônes
-- de récolte dans Interface\Minimap\ObjectIconsAtlas après un
-- changement de patch. Glisse directement l'icône zoomée pour la
-- repositionner (la taille du cadre reste fixe, seule la position
-- bouge), ou tape les valeurs à la main dans les 4 petits champs.
-- Le bouton "Imprimer la table" sort une table Lua prête à coller
-- dans WORLD_MAP_TEXCOORDS et BUILTIN_PINS (MinageR/HerboR/PecheR
-- copient simplement Minage/Herbo/Peche, comme dans la table d'origine).
-- ============================================================

local calibFrame

local CALIB_TYPES = {
    { key = "Minage", label = L.TYPE_Minage or "Minage", color = {1,    0.3,  0.3 } },
    { key = "Herbo",  label = L.TYPE_Herbo  or "Herbo",  color = {0.3,  1,    0.3 } },
    { key = "Peche",  label = L.TYPE_Peche  or "Peche",  color = {0.3,  0.6,  1   } },
    { key = "Bois",   label = L.TYPE_Bois   or "Bois",   color = {1,    0.85, 0.2 } },
}

-- Petite fenêtre avec le texte déjà sélectionné (Ctrl+A/Ctrl+C marche tel quel),
-- même principe que OpenExportPopup un peu plus haut dans le fichier.
local function OpenAtlasCopyPopup(text)
    if FarmMapAtlasCopyPopup then
        FarmMapAtlasCopyPopup.eb:SetText(text)
        FarmMapAtlasCopyPopup.eb:HighlightText()
        FarmMapAtlasCopyPopup:Show()
        return
    end

    local pop = CreateFrame("Frame", "FarmMapAtlasCopyPopup", UIParent, "BackdropTemplate")
    pop:SetSize(460, 280)
    pop:SetPoint("CENTER")
    pop:SetFrameStrata("FULLSCREEN_DIALOG")
    pop:SetMovable(true)
    pop:EnableMouse(true)
    pop:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16, insets = {left=4,right=4,top=4,bottom=4}
    })
    pop:SetBackdropColor(0, 0, 0, 0.95)

    local titleBar = CreateFrame("Frame", nil, pop)
    titleBar:SetHeight(24)
    titleBar:SetPoint("TOPLEFT",  pop, "TOPLEFT",  5, -5)
    titleBar:SetPoint("TOPRIGHT", pop, "TOPRIGHT", -5, -5)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() pop:StartMoving() end)
    titleBar:SetScript("OnDragStop",  function() pop:StopMovingOrSizing() end)

    local titleTxt = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleTxt:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    titleTxt:SetText(L.ATLAS_COPY_TITLE)
    titleTxt:SetTextColor(1, 0.82, 0, 1)

    local hint = pop:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, -2)
    hint:SetText("|cffaaaaaa" .. L.ATLAS_COPY_HINT .. "|r")

    local sf = CreateFrame("ScrollFrame", nil, pop, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT",     pop, "TOPLEFT",     8,  -54)
    sf:SetPoint("BOTTOMRIGHT", pop, "BOTTOMRIGHT", -28, 34)

    local eb = CreateFrame("EditBox", nil, sf)
    eb:SetMultiLine(true)
    eb:SetMaxLetters(0)
    eb:SetFontObject(GameFontNormalSmall)
    eb:SetWidth(sf:GetWidth())
    eb:SetAutoFocus(false)
    eb:SetScript("OnEscapePressed", function() pop:Hide() end)
    sf:SetScrollChild(eb)
    pop.eb = eb

    local btnClose = CreateFrame("Button", nil, pop, "UIPanelButtonTemplate")
    btnClose:SetSize(90, 22)
    btnClose:SetPoint("BOTTOM", pop, "BOTTOM", 0, 7)
    btnClose:SetText(L.CLOSE)
    btnClose:SetScript("OnClick", function() pop:Hide() end)

    eb:SetText(text)
    eb:HighlightText()
    pop:Show()
end

local function CreateAtlasCalibrator()
    local f = CreateFrame("Frame", "FarmMapAtlasCalibrator", UIParent, "BackdropTemplate")
    f:SetSize(560, 680)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetBackdrop({
        bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = {left=3, right=3, top=3, bottom=3}
    })
    f:SetBackdropColor(0, 0, 0.1, 0.95)
    f:SetBackdropBorderColor(0.4, 0.4, 0.6, 1)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function() f:StartMoving() end)
    f:SetScript("OnDragStop",  function() f:StopMovingOrSizing() end)
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 12, -10)
    title:SetText(L.ATLAS_TITLE)

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function() f:Hide() end)

    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", 16, -30)
    hint:SetText("|cffaaaaaa" .. L.ATLAS_HINT .. "|r")

    local rows     = {}
    local zoomSize  = 190
    local cellW     = 260
    local cellH     = 290
    local gridLeft  = 16
    local gridTop   = -52

    for index, info in ipairs(CALIB_TYPES) do
        local coords  = WORLD_MAP_TEXCOORDS[info.key] or {0, 0.03, 0, 0.03}
        local col     = (index - 1) % 2
        local rowIdx  = math.floor((index - 1) / 2)
        local cellX   = gridLeft + col * cellW
        local cellY   = gridTop - rowIdx * cellH

        local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", cellX, cellY)
        label:SetText(info.label)
        label:SetTextColor(info.color[1], info.color[2], info.color[3], 1)

        local zoomFrame = CreateFrame("Frame", nil, f, "BackdropTemplate")
        zoomFrame:SetSize(zoomSize, zoomSize)
        zoomFrame:SetPoint("TOPLEFT", cellX, cellY - 18)
        zoomFrame:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8 })
        zoomFrame:SetBackdropBorderColor(info.color[1], info.color[2], info.color[3], 1)
        zoomFrame:EnableMouse(true)

        local zoomTex = zoomFrame:CreateTexture(nil, "ARTWORK")
        zoomTex:SetPoint("TOPLEFT", 4, -4)
        zoomTex:SetPoint("BOTTOMRIGHT", -4, 4)
        zoomTex:SetTexture(BLIP_DEFAULT)

        local fieldNames  = {"L", "R", "T", "B"}
        local fieldValues = {coords[1], coords[2], coords[3], coords[4]}
        local row = { key = info.key, current = fieldValues, edits = {} }

        local function Recompute()
            local vals = {}
            for idx, name in ipairs(fieldNames) do
                vals[idx] = tonumber(row.edits[name]:GetText()) or fieldValues[idx]
            end
            zoomTex:SetTexCoord(vals[1], vals[2], vals[3], vals[4])
            row.current = vals
        end

        -- Met à jour les 4 champs sans déclencher 4 recalculs intermédiaires incohérents
        local function ApplyVals(l, r, t, b)
            for _, name in ipairs(fieldNames) do
                row.edits[name]:SetScript("OnTextChanged", nil)
            end
            row.edits.L:SetText(string.format("%.4f", l))
            row.edits.R:SetText(string.format("%.4f", r))
            row.edits.T:SetText(string.format("%.4f", t))
            row.edits.B:SetText(string.format("%.4f", b))
            for _, name in ipairs(fieldNames) do
                row.edits[name]:SetScript("OnTextChanged", Recompute)
            end
            Recompute()
        end
        row.applyVals = ApplyVals

        local prevWidget
        for idx, name in ipairs(fieldNames) do
            local eb = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
            eb:SetSize(40, 16)
            eb:SetAutoFocus(false)
            if prevWidget then
                eb:SetPoint("LEFT", prevWidget, "RIGHT", 6, 0)
            else
                eb:SetPoint("TOPLEFT", zoomFrame, "BOTTOMLEFT", 0, -16)
            end
            eb:SetText(string.format("%.4f", fieldValues[idx]))
            eb:SetScript("OnEnterPressed", eb.ClearFocus)
            row.edits[name] = eb

            local ebLabel = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            ebLabel:SetPoint("BOTTOM", eb, "TOP", 0, 1)
            ebLabel:SetText(name)

            prevWidget = eb
        end
        for _, name in ipairs(fieldNames) do
            row.edits[name]:SetScript("OnTextChanged", Recompute)
        end
        Recompute()

        -- Glisser-déposer : seule la position bouge, la taille reste fixe.
        -- L'icône suit la souris (comme un outil "main" classique) : on
        -- décale la fenêtre de recadrage dans le sens inverse du glissement.
        local drag = { active = false }
        zoomFrame:SetScript("OnMouseDown", function(self, button)
            if button ~= "LeftButton" then return end
            drag.active = true
            drag.startX, drag.startY = GetCursorPosition()
            drag.startVals = { row.current[1], row.current[2], row.current[3], row.current[4] }
        end)
        zoomFrame:SetScript("OnMouseUp", function(self, button)
            drag.active = false
        end)
        zoomFrame:SetScript("OnUpdate", function(self, elapsed)
            if not drag.active then return end
            if not IsMouseButtonDown("LeftButton") then
                drag.active = false
                return
            end
            local cx, cy = GetCursorPosition()
            local scale  = self:GetEffectiveScale()
            local dx     = (cx - drag.startX) / scale
            local dy     = (cy - drag.startY) / scale
            local sv     = drag.startVals
            local boxW   = sv[2] - sv[1]
            local boxH   = sv[4] - sv[3]
            local dLR    = -dx * (boxW / self:GetWidth())
            local dTB    =  dy * (boxH / self:GetHeight())
            ApplyVals(sv[1] + dLR, sv[2] + dLR, sv[3] + dTB, sv[4] + dTB)
        end)

        rows[info.key] = row
    end

    local function CollectAtlasLines()
        local order     = {"Minage", "Herbo", "Peche", "Bois"}
        local richOrder = {"Minage", "Herbo", "Peche"} -- Bois n'a pas de variante "riche"
        local lines = {}
        for _, key in ipairs(order) do
            local c = rows[key].current
            table.insert(lines, string.format("    %-8s= {%.4f, %.4f, %.4f, %.4f},", key, c[1], c[2], c[3], c[4]))
        end
        for _, key in ipairs(richOrder) do
            local c = rows[key].current
            table.insert(lines, string.format("    %-8s= {%.4f, %.4f, %.4f, %.4f},", key .. "R", c[1], c[2], c[3], c[4]))
        end
        return lines
    end

    local printBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    printBtn:SetSize(170, 22)
    printBtn:SetPoint("BOTTOMLEFT", 16, 14)
    printBtn:SetText(L.ATLAS_PRINT)
    printBtn:SetScript("OnClick", function()
        local lines = CollectAtlasLines()
        print("|cffffd100FarmMap :|r colle ceci dans WORLD_MAP_TEXCOORDS (et BUILTIN_PINS) :")
        for _, line in ipairs(lines) do
            print(line)
        end
        OpenAtlasCopyPopup(table.concat(lines, "\n"))
    end)

    local resetBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    resetBtn:SetSize(170, 22)
    resetBtn:SetPoint("LEFT", printBtn, "RIGHT", 10, 0)
    resetBtn:SetText(L.ATLAS_RESET)
    resetBtn:SetScript("OnClick", function()
        for _, info in ipairs(CALIB_TYPES) do
            local coords = WORLD_MAP_TEXCOORDS[info.key]
            rows[info.key].applyVals(coords[1], coords[2], coords[3], coords[4])
        end
    end)

    return f
end

-- ============================================================
-- COMMANDES SLASH
-- ============================================================

-- Aide : une clé de traduction par commande, plutôt qu'un seul bloc
-- de texte. Une commande ajoutée plus tard s'affiche en anglais dans
-- les langues pas encore mises à jour, au lieu de disparaître de la
-- liste (le repli par clé ne fonctionne pas sur une table entière).
local SLASH_COMMANDS = {
    { cmd = "help",    key = "SLASH_CMD_HELP"    },
    { cmd = "debug",   key = "SLASH_CMD_DEBUG"   },
    { cmd = "export",  key = "SLASH_CMD_EXPORT"  },
    { cmd = "import",  key = "SLASH_CMD_IMPORT"  },
    { cmd = "clear",   key = "SLASH_CMD_CLEAR"   },
    { cmd = "stats",   key = "SLASH_CMD_STATS"   },
    { cmd = "migrate", key = "SLASH_CMD_MIGRATE" },
    { cmd = "atlas",   key = "SLASH_CMD_ATLAS"   },
    { cmd = "default", key = "SLASH_CMD_DEFAULT" },
    { cmd = "version", key = "SLASH_CMD_VERSION" },
}

-- Alias toujours actifs quelle que soit la langue : ce sont les
-- variantes les plus probables sur la commande de secours, celle
-- qu'on tape justement quand plus rien n'est lisible.
local BASE_ALIASES = {
    defaut = "default",
    reset  = "default",
}

-- Alias localisés : alias tapé -> commande canonique anglaise.
-- Reconstruit à ADDON_LOADED, une fois la langue résolue.
local commandAliases = {}

-- Alias inverses (commande -> liste d'alias), pour l'affichage de
-- l'aide uniquement.
local aliasDisplay = {}

local function BuildCommandAliases()
    wipe(commandAliases)
    wipe(aliasDisplay)
    for alias, canonical in pairs(BASE_ALIASES) do
        commandAliases[alias] = canonical
    end

    local loc = ns.locales[gameLocale]
    local defs = loc and loc.slash and loc.slash.commands
    if type(defs) ~= "table" then return end

    for canonical, aliases in pairs(defs) do
        if type(aliases) == "table" then
            for _, alias in ipairs(aliases) do
                if type(alias) == "string" and alias ~= "" then
                    alias = alias:lower()
                    -- Un alias ne peut jamais masquer une commande
                    -- canonique : la doc anglaise reste toujours vraie.
                    local isCanonical = false
                    for _, entry in ipairs(SLASH_COMMANDS) do
                        if entry.cmd == alias then isCanonical = true end
                    end
                    if not isCanonical then
                        commandAliases[alias] = canonical
                        aliasDisplay[canonical] = aliasDisplay[canonical] or {}
                        table.insert(aliasDisplay[canonical], alias)
                    end
                end
            end
        end
    end
end

-- Préfixes localisés (/carte, /granja...). /fm et /farmmap restent
-- toujours actifs : ils occupent les slots 1 et 2.
local function RegisterSlashPrefixes()
    local loc = ns.locales[gameLocale]
    local prefixes = loc and loc.slash and loc.slash.prefix
    if type(prefixes) ~= "table" then return end

    local slot = 2
    for _, prefix in ipairs(prefixes) do
        if type(prefix) == "string" and prefix:sub(1, 1) == "/" and #prefix > 1 then
            slot = slot + 1
            _G["SLASH_FARMMAP" .. slot] = prefix:lower()
        end
    end
end

-- Appelé depuis ADDON_LOADED, après ApplyLanguage.
function ns.SetupSlashLocalization()
    BuildCommandAliases()
    RegisterSlashPrefixes()
end

SLASH_FARMMAP1 = "/fm"
SLASH_FARMMAP2 = "/farmmap"

SlashCmdList["FARMMAP"] = function(msg)
    local cmd = strtrim(msg):lower()
    cmd = commandAliases[cmd] or cmd

    if cmd == "" or cmd == "help" then
        print(L.SLASH_HELP_TITLE)
        -- Pas d'alignement par espaces : la fenêtre de chat utilise une
        -- police proportionnelle, et le hangul est en chasse double.
        -- Compter les caractères n'aligne rien — c'est la couleur qui
        -- sépare la commande de sa description.
        for _, entry in ipairs(SLASH_COMMANDS) do
            local line = string.format("|cffffd100/fm %s|r  |cffaaaaaa%s|r",
                entry.cmd, L[entry.key] or "")
            local alt = aliasDisplay[entry.cmd]
            if alt then
                line = line .. string.format("  |cff888888(/fm %s)|r",
                    table.concat(alt, ", /fm "))
            end
            print(line)
        end

    -- Retour à la langue du client. C'est la commande de secours quand
    -- on s'est trompé de langue : la confirmation sort dans la langue
    -- du client, pas dans la langue forcée.
    elseif cmd == "default" then
        FarmMapDB.language = "auto"
        print("|cffffd100FarmMap :|r " .. ClientString("SLASH_DEFAULT_DONE"))

    elseif cmd == "atlas" then
        if not calibFrame then calibFrame = CreateAtlasCalibrator() end
        if calibFrame:IsShown() then calibFrame:Hide() else calibFrame:Show() end

    elseif cmd == "debug" then
        FarmMapDB.showDebug = not FarmMapDB.showDebug
        if FarmMapDB.showDebug then FarmMapDebug:Show() else FarmMapDebug:Hide() end
        if FarmMapShowDebugCheck then FarmMapShowDebugCheck:SetChecked(FarmMapDB.showDebug) end

    elseif cmd == "export" then
        OpenExportPopup()

    elseif cmd == "import" then
        OpenImportPopup()

    elseif cmd == "clear" then
        local saved = {
            version          = DB_VERSION,
            showDebug        = FarmMapDB.showDebug,
            debugCapture     = FarmMapDB.debugCapture,
            showHerbo        = FarmMapDB.showHerbo,
            showMinage       = FarmMapDB.showMinage,
            showPeche        = FarmMapDB.showPeche,
            showBois         = FarmMapDB.showBois,
            minimapStyle     = FarmMapDB.minimapStyle,
            worldmapStyle    = FarmMapDB.worldmapStyle,
            replaceBlip      = FarmMapDB.replaceBlip,
            showMinimapPins  = FarmMapDB.showMinimapPins,
            language         = FarmMapDB.language,
            showFloatingText = FarmMapDB.showFloatingText,
            -- Position et visibilité du bouton minimap : vider la base
            -- de nœuds ne doit pas replacer le bouton.
            minimapIcon      = FarmMapDB.minimapIcon,
        }
        FarmMapDB = saved
        HBDPins:RemoveAllMinimapIcons(addonName)
        HBDPins:RemoveAllWorldMapIcons(addonName)
        print("|cffffd100FarmMap :|r " .. L.SLASH_CLEAR_CONFIRM)

    elseif cmd == "stats" then
        local counts = FarmMapStatsDB and FarmMapStatsDB.counts or {}
        local total  = 0
        local types  = {
            { k = "Herbo",  label = L.TYPE_Herbo  },
            { k = "Minage", label = L.TYPE_Minage },
            { k = "Peche",  label = L.TYPE_Peche  },
            { k = "Bois",   label = L.TYPE_Bois   },
        }
        print("|cffffd100FarmMap — " .. L.STATS_TITLE .. "|r")
        for _, t in ipairs(types) do
            local n   = counts[t.k] or 0
            total     = total + n
            local c   = TYPE_COLORS[t.k]
            local hex = string.format("%02x%02x%02x", c[1]*255, c[2]*255, c[3]*255)
            print(string.format("  |cff%s%s|r : |cffffffff%d|r", hex, t.label, n))
        end
        print("  |cffffd100" .. L.STATS_TOTAL .. "|r : |cffffffff" .. total .. "|r")

    elseif cmd == "migrate" then
        ManualMigration()

    elseif cmd == "version" then
        print("|cffffd100FarmMap|r — " .. L.SLASH_VERSION .. " : |cffffffff" .. addonVersion .. "|r  (" .. lastUpdate .. ")")

    else
        print("|cffffd100FarmMap :|r " .. L.SLASH_UNKNOWN)
    end
end
