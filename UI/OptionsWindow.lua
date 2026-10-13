-- ============================================================
--  FarmMap — options window (v2)
--
--  Rail on the left (reading pages on top, settings below, a search to
--  narrow it), a fixed header naming the page, the page itself in the
--  middle (the only part that scrolls), and a footer that belongs to the
--  window: Reload on the left, links and the legacy panel, Close on the
--  right. Layout of Kroos_AchievementOverhaul's options window.
--
--  The Blizzard panel built in FarmMap.lua stays: it is the "legacy"
--  panel, one click away in the footer. Both read and write the same
--  FarmMapDB keys, so they never disagree.
--
--  A custom frame is not protected, unlike Settings.OpenToCategory: this
--  window opens in combat too.
-- ============================================================

local _, ns = ...

local Theme = ns.Theme
local OptionsWindow = {}
ns.OptionsWindow = OptionsWindow

-- MIN_H is a floor: the real minimum is measured from the rail (FitRailHeight).
local DEFAULT_W, DEFAULT_H = 1020, 720
local MIN_W, MIN_H         = 800, 640
local INSET    = 3        -- title bar and footer sit this far inside the window's edge (Theme.Band)
local TITLE_H  = 36
local FOOTER_H = 62
local RAIL_W   = 226
local PAD      = 12
local CONTENT_LEFT = PAD + RAIL_W + 22

local MEDIA = "Interface\\AddOns\\FarmMap\\Media\\"
local TEX_ICON = "Interface\\AddOns\\FarmMap\\Textures\\icon"

-- WoW cannot open a browser: a link opens a box with the address selected.
local LINKS = {
    { id = "discord", label = "Discord", icon = MEDIA .. "discord.png",
      url = "https://discord.gg/4BEGpmktK7" },
    -- Kroosstii's PayPal button (the one KAO uses); item_name tags the
    -- donation as coming from FarmMap in game.
    { id = "paypal",  label = "PayPal",  icon = MEDIA .. "paypal.png",
      url = "https://www.paypal.com/donate/?hosted_button_id=EFJYDJ8YHNWQA"
         .. "&item_name=FarmMap%20%28from%20WoW%20In%20game%29" },
}

local window, header, scroll, content, searchBox, railList
local activeID
local railButtons = {}
local pages, pageOrder = {}, {}

-- ============================================================
-- PAGES
-- ============================================================

-- def = { id, group = "top" | "settings", titleKey, descKey,
--         Build(frame), Layout(frame, width) -> height }
-- Build runs once, the first time the page is shown; Layout on every show
-- and resize. Frames cannot be destroyed, so a page keeps its frames.
function OptionsWindow:AddPage(def)
    if not pages[def.id] then pageOrder[#pageOrder + 1] = def.id end
    pages[def.id] = def
end

local function L(key) return ns.L[key] or key end

-- A card: rounded panel with an optional title and paragraph. Pages lay
-- out their own content below `card.top`.
function OptionsWindow.Card(parent)
    local card = CreateFrame("Frame", nil, parent)
    Theme.Plate(card, "panel", "line")
    card.title = Theme.Font(card:CreateFontString(nil, "OVERLAY"), 15, "text")
    card.title:SetPoint("TOPLEFT", 14, -12)
    card.title:SetJustifyH("LEFT")
    card.body = Theme.Font(card:CreateFontString(nil, "OVERLAY"), 13, "dim")
    card.body:SetJustifyH("LEFT")
    card.body:SetWordWrap(true)

    -- Sets the texts at a width; returns the y where free space starts.
    function card:SetTexts(title, body, width)
        local y = 12
        if title and title ~= "" then
            self.title:SetWidth(width - 28)
            self.title:SetText(title)
            self.title:Show()
            y = y + math.floor(self.title:GetStringHeight() + 0.5) + 6
        else
            self.title:Hide()
        end
        if body and body ~= "" then
            self.body:ClearAllPoints()
            self.body:SetPoint("TOPLEFT", 14, -y)
            self.body:SetWidth(width - 28)
            self.body:SetText(body)
            self.body:Show()
            y = y + math.floor(self.body:GetStringHeight() + 0.5) + 6
        else
            self.body:Hide()
        end
        self.top = y
        return y
    end
    return card
end

-- Placeholder for the pages of the coming builds.
local function SoonPage(id, group, titleKey, descKey)
    OptionsWindow:AddPage({
        id = id, group = group, titleKey = titleKey, descKey = descKey,
        Build = function(frame) frame.card = OptionsWindow.Card(frame) end,
        Layout = function(frame, width)
            local card = frame.card
            card:ClearAllPoints()
            card:SetPoint("TOPLEFT", 1, -1)
            card:SetWidth(width - 2)
            card:SetHeight(card:SetTexts(nil, L("UI_SOON"), width - 2) + 8)
            return card:GetHeight() + 2
        end,
    })
end

-- ============================================================
-- RAIL
-- ============================================================

local function PaintRailButton(b)
    local on = b.pageID == activeID
    b.marker:SetShown(on)
    b.marker:SetVertexColor(Theme.RGB("accent"))
    b.bg:SetVertexColor(1, 1, 1, on and 0.06 or 0)
    b.label:SetTextColor(Theme.RGB(on and "text" or "dim"))
end

local function RailButton(id)
    local b = CreateFrame("Button", nil, railList)
    b:SetHeight(30)
    b.pageID = id
    b.bg = b:CreateTexture(nil, "BACKGROUND")
    b.bg:SetAllPoints()
    b.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
    b.marker = b:CreateTexture(nil, "ARTWORK")
    b.marker:SetTexture("Interface\\Buttons\\WHITE8X8")
    b.marker:SetPoint("TOPLEFT")
    b.marker:SetPoint("BOTTOMLEFT")
    b.marker:SetWidth(2)
    b.label = Theme.Font(b:CreateFontString(nil, "OVERLAY"), 14)
    b.label:SetPoint("LEFT", 12, 0)
    b.label:SetPoint("RIGHT", -6, 0)
    b.label:SetJustifyH("LEFT")
    b.label:SetWordWrap(false)
    Theme.Track(b, PaintRailButton)
    b:SetScript("OnClick", function(self) OptionsWindow:Select(self.pageID) end)
    b:SetScript("OnEnter", function(self)
        if self.pageID ~= activeID then
            self.bg:SetVertexColor(1, 1, 1, 0.04)
            self.label:SetTextColor(Theme.RGB("text"))
        end
    end)
    b:SetScript("OnLeave", PaintRailButton)
    railButtons[#railButtons + 1] = b
    return b
end

-- Lays out the rail, keeping only the pages that match the search: their
-- title and description, and what the page holds when it says
-- (def.SearchText: setting names, addon names...). Searching "TomTom" used
-- to find nothing, the word being only inside the Integrations page.
local function LayoutRail(filter)
    filter = filter and filter:lower() or ""
    local function Matches(def)
        if filter == "" then return true end
        local hay = L(def.titleKey) .. " " .. L(def.descKey)
        if def.SearchText then
            -- A page's own text must never break the rail.
            local ok, more = pcall(def.SearchText)
            if ok and more then hay = hay .. " " .. more end
        end
        return hay:lower():find(filter, 1, true) ~= nil
    end

    local y, shown = 0, 0
    for _, group in ipairs({ "top", "settings" }) do
        local matching = {}
        for _, b in ipairs(railButtons) do
            local def = pages[b.pageID]
            if def.group == group then
                b.label:SetText(L(def.titleKey))
                if Matches(def) then matching[#matching + 1] = b else b:Hide() end
            end
        end
        -- The settings heading is a real title, not a whisper: accent, a
        -- rule running to the edge, and the pages indented beneath it
        -- (reported in game: the small dim label did not read as a title).
        -- Hidden when no settings page matches: it sat over the "no page
        -- matches" line.
        local indent = 0
        if group == "settings" then
            local any = #matching > 0
            railList.heading:SetShown(any)
            railList.headingRule:SetShown(any)
            if any then
                railList.heading:ClearAllPoints()
                railList.heading:SetPoint("TOPLEFT", 4, -(y + 18))
                railList.heading:SetText(L("UI_SETTINGS"):upper())
                y = y + 18 + math.floor(railList.heading:GetStringHeight() + 0.5) + 8
            end
            indent = 10
        end
        for _, b in ipairs(matching) do
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", indent, -y)
            b:SetPoint("RIGHT", railList, "RIGHT")
            b:Show()
            y = y + 32
            shown = shown + 1
        end
    end
    railList.empty:SetShown(shown == 0)
    -- The full list's height, for the window's minimum (FitRailHeight).
    if filter == "" then railList.fullHeight = y end
end

-- The window never gets shorter than the full rail: at the old fixed
-- minimum (640) "Language" and "Debug" ran under the footer (seen on Era
-- and Retail, 2026-10-08, once the text had grown). Measured, so it holds
-- for every language and size. Needs the window laid out: called on show.
local function FitRailHeight()
    if not (window and railList and railList.fullHeight) then return end
    local winTop, listTop = window:GetTop(), railList:GetTop()
    if not (winTop and listTop) then return end
    local needed = math.ceil((winTop - listTop) + railList.fullHeight + INSET + FOOTER_H + 16)
    local minH = math.max(MIN_H, needed)
    window:SetResizeBounds(MIN_W, minH)
    if window:GetHeight() < minH then window:SetHeight(minH) end
end

-- ============================================================
-- LINKS
-- ============================================================

local linkBox

-- Also shows an exported theme to copy: `hint` replaces the link's line.
local function ShowLink(url, hint)
    if not linkBox then
        linkBox = CreateFrame("Frame", nil, UIParent)
        linkBox:SetSize(380, 80)
        linkBox:SetPoint("CENTER")
        linkBox:SetFrameStrata("FULLSCREEN_DIALOG")
        linkBox:EnableMouse(true)
        Theme.Plate(linkBox, "panel2", "accentSoft")

        linkBox.hint = Theme.Font(linkBox:CreateFontString(nil, "OVERLAY"), 12.5, "dim")
        linkBox.hint:SetPoint("TOP", 0, -12)

        local box = CreateFrame("EditBox", nil, linkBox)
        box:SetHeight(26)
        box:SetPoint("LEFT", 14, -8)
        box:SetPoint("RIGHT", -14, -8)
        box:SetAutoFocus(true)
        box:SetTextInsets(8, 8, 0, 0)
        Theme.Font(box, 13, "text")
        Theme.Plate(box, "bg", "line", true)
        -- Read-only in practice: any edit is undone.
        box:SetScript("OnTextChanged", function(self, userInput)
            if userInput then
                self:SetText(self.url or "")
                self:HighlightText()
            end
        end)
        box:SetScript("OnEscapePressed", function() linkBox:Hide() end)
        box:SetScript("OnEnterPressed", function() linkBox:Hide() end)
        linkBox.box = box
    end
    linkBox.hint:SetText(hint or L("UI_LINK_HINT"))
    linkBox.box.url = url
    linkBox.box:SetText(url)
    linkBox:Show()
    linkBox.box:SetFocus()
    linkBox.box:HighlightText()
end

local function LinkButton(parent, link)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(46, 46)
    Theme.Plate(b, "panel2", "line", true)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetSize(32, 32)
    b.icon:SetPoint("CENTER")
    b.icon:SetTexture(link.icon)
    Theme.Track(b.icon, function(self) self:SetVertexColor(Theme.RGB("dim")) end)
    b:SetScript("OnEnter", function(self)
        Theme.PaintPlate(self, nil, "accent")
        self.icon:SetVertexColor(1, 1, 1)
        Theme.ShowTip(link.label, link.url)
    end)
    b:SetScript("OnLeave", function(self)
        Theme.PaintPlate(self)
        self.icon:SetVertexColor(Theme.RGB("dim"))
        Theme.HideTip()
    end)
    b:SetScript("OnClick", function() ShowLink(link.url) end)
    return b
end

-- ============================================================
-- WINDOW
-- ============================================================

-- Height of the visible page area, for a page that fills it (Credits).
function OptionsWindow.ViewportHeight()
    return scroll and math.floor((scroll:GetHeight() or 0) + 0.5) or 0
end

local function ContentWidth()
    local w = content and content:GetWidth() or 0
    if w < 100 then w = (window:GetWidth() or DEFAULT_W) - CONTENT_LEFT - 30 end
    return math.floor(w)
end

local function ShowPage(id)
    local def = pages[id]
    if not def then return end
    -- Never the page being re-laid: hiding it would drop the keyboard focus
    -- of a field the player is typing in.
    for _, other in pairs(pages) do
        if other.frame and other ~= def then other.frame:Hide() end
    end
    if not def.frame then
        def.frame = CreateFrame("Frame", nil, content)
        def.Build(def.frame)
    end
    header.title:SetText(L(def.titleKey))
    header.desc:SetText(L(def.descKey))
    local width = ContentWidth()
    def.frame:ClearAllPoints()
    def.frame:SetPoint("TOPLEFT")
    def.frame:SetWidth(width)
    local height = math.max(1, math.floor(def.Layout(def.frame, width) + 0.5))
    def.frame:SetHeight(height)
    def.frame:Show()
    content:SetHeight(height)
end

function OptionsWindow:Select(id)
    if not pages[id] then return end
    activeID = id
    for _, b in ipairs(railButtons) do PaintRailButton(b) end
    scroll:SetVerticalScroll(0)
    ShowPage(id)
end

-- Re-lays the page in place (theme switch, resize, data changed).
function OptionsWindow:Refresh()
    if window and window:IsShown() and activeID then ShowPage(activeID) end
end

-- Called by FarmMap.lua after each harvest: the pages that show data
-- follow it while they are open.
local LIVE_PAGES = { dash = true, nodes = true }
function ns.OnDataChanged()
    if window and window:IsShown() and LIVE_PAGES[activeID] then OptionsWindow:Refresh() end
end

local function Create()
    if window then return window end

    window = CreateFrame("Frame", "FarmMapOptionsWindow", UIParent)
    -- The player's window size, before anything is laid at whole pixels.
    Theme.ScaledWindow(window)
    local saved = FarmMapDB and FarmMapDB.uiWindow or {}
    window:SetSize(math.max(MIN_W, saved.w or DEFAULT_W), math.max(MIN_H, saved.h or DEFAULT_H))
    window:SetPoint("CENTER")
    window:SetFrameStrata("HIGH")
    window:SetToplevel(true)
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    window:SetMovable(true)
    window:SetResizable(true)
    window:SetResizeBounds(MIN_W, MIN_H)
    -- Escape closes it, the supported way (an OnKeyDown handler would need
    -- the protected SetPropagateKeyboardInput).
    tinsert(UISpecialFrames, "FarmMapOptionsWindow")
    Theme.Plate(window, "bg", "line")

    -- ---- title bar: also the drag handle
    local bar = CreateFrame("Frame", nil, window)
    Theme.InsetBand(bar, window, "TOP", INSET)
    bar:SetHeight(TITLE_H)
    bar.bg = Theme.Band(bar, "panel2", "TOP")
    local barRule = Theme.Rule(bar, false, "line")
    barRule:SetPoint("BOTTOMLEFT")
    barRule:SetPoint("BOTTOMRIGHT")
    bar.title = Theme.Font(bar:CreateFontString(nil, "OVERLAY"), 14, "accent")
    bar.title:SetPoint("LEFT", 12, 0)
    bar.title:SetText("FarmMap · " .. L("UI_TITLE"))
    local close = Theme.GlyphButton(bar, "\195\151", 26)
    close:SetPoint("RIGHT", -8, 0)
    close:SetScript("OnClick", function() window:Hide() end)
    bar:EnableMouse(true)
    bar:RegisterForDrag("LeftButton")
    bar:SetScript("OnDragStart", function() window:StartMoving() end)
    bar:SetScript("OnDragStop", function()
        window:StopMovingOrSizing()
        Theme.SnapToPixels(window)
    end)

    -- ---- footer, full width
    local footer = CreateFrame("Frame", nil, window)
    Theme.InsetBand(footer, window, "BOTTOM", INSET)
    footer:SetHeight(FOOTER_H)
    footer.bg = Theme.Band(footer, "panel", "BOTTOM")
    local footRule = Theme.Rule(footer, false, "line")
    footRule:SetPoint("TOPLEFT")
    footRule:SetPoint("TOPRIGHT")

    local reload = Theme.ActionButton(footer, L("UI_RELOAD"))
    reload:SetPoint("LEFT", PAD, 0)
    reload:SetScript("OnClick", function() ReloadUI() end)

    local closeBtn = Theme.ActionButton(footer, L("CLOSE"))
    closeBtn.minWidth = 90
    closeBtn:SetLabel(L("CLOSE"))
    closeBtn:SetPoint("RIGHT", -PAD - 14, 0)   -- room for the resize grip
    closeBtn:SetScript("OnClick", function() window:Hide() end)

    -- No legacy button here: the legacy panel is a choice made once, with
    -- the "New options window" box of the Display page (Kroosstii).
    local previous = closeBtn
    for i = #LINKS, 1, -1 do
        local b = LinkButton(footer, LINKS[i])
        b:SetPoint("RIGHT", previous, "LEFT", previous == closeBtn and -18 or -10, 0)
        previous = b
    end

    -- ---- rail
    local rail = CreateFrame("Frame", nil, window)
    rail:SetPoint("TOPLEFT", PAD, -(INSET + TITLE_H + 12))
    rail:SetPoint("BOTTOMLEFT", PAD, INSET + FOOTER_H + 10)
    rail:SetWidth(RAIL_W)

    -- Kroosstii's KROO logo, in the theme's accent colour (his wish,
    -- 2026-10-09; it used to keep its own cyan). Media\logo-white.png is
    -- Media\logo.png (KAO's file, kept as is) in white with the very same
    -- alpha: the logo is one colour with transparent arrows, so the tint
    -- gives exactly the accent. The PNG keeps wide transparent margins;
    -- the crop below keeps only the wordmark.
    local logo = rail:CreateTexture(nil, "ARTWORK")
    logo:SetPoint("TOPLEFT", 4, -2)
    logo:SetSize(160, 46)
    logo:SetTexture(MEDIA .. "logo-white.png")
    logo:SetTexCoord(0.151, 0.849, 0.399, 0.601)
    Theme.Track(logo, function(self) self:SetVertexColor(Theme.RGB("accent")) end)

    local brand = Theme.Font(rail:CreateFontString(nil, "OVERLAY"), 22, "accent")
    brand:SetPoint("TOPLEFT", logo, "BOTTOMLEFT", 2, -8)
    brand:SetText("FarmMap")
    -- The addon's icon (drawn by the artist of the Sakura pack, v2.0) to
    -- the right of the name, where Kroosstii wanted players to see it.
    -- Its own colours, like the logo above.
    local addonIcon = rail:CreateTexture(nil, "ARTWORK")
    addonIcon:SetSize(60, 60)
    addonIcon:SetPoint("TOP", brand, "TOP", 0, 2)
    addonIcon:SetPoint("RIGHT", rail, "RIGHT", -10, 0)
    addonIcon:SetTexture(TEX_ICON)
    local client = Theme.Font(rail:CreateFontString(nil, "OVERLAY"), 12.5, "dim")
    client:SetPoint("TOPLEFT", brand, "BOTTOMLEFT", 0, -4)
    client:SetPoint("RIGHT", addonIcon, "LEFT", -6, 0)
    client:SetJustifyH("LEFT")
    client:SetText((ns.ClientLabel and ns.ClientLabel() or "") .. " " .. (GetBuildInfo()))
    local version = Theme.Font(rail:CreateFontString(nil, "OVERLAY"), 12, "faint")
    version:SetPoint("TOPLEFT", client, "BOTTOMLEFT", 0, -2)
    version:SetText(ns.version or "")
    local brandRule = Theme.Rule(rail, false, "line")
    brandRule:SetPoint("TOPLEFT", version, "BOTTOMLEFT", -6, -10)
    brandRule:SetPoint("RIGHT", rail, "RIGHT")

    searchBox = Theme.SearchBox(rail, L("UI_SEARCH"))
    searchBox:SetPoint("TOPLEFT", brandRule, "BOTTOMLEFT", 1, -12)
    searchBox:SetPoint("RIGHT", rail, "RIGHT", -1, 0)
    searchBox.onChange = function(text) LayoutRail(text) end

    railList = CreateFrame("Frame", nil, rail)
    railList:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", -1, -10)
    railList:SetPoint("BOTTOMRIGHT", rail, "BOTTOMRIGHT")
    railList.heading = Theme.Font(railList:CreateFontString(nil, "OVERLAY"), 13.5, "accent")
    railList.headingRule = Theme.Rule(railList, false, "line")
    railList.headingRule:SetPoint("LEFT", railList.heading, "RIGHT", 8, 0)
    railList.headingRule:SetPoint("RIGHT", railList, "RIGHT", -4, 0)
    railList.empty = Theme.Font(railList:CreateFontString(nil, "OVERLAY"), 12.5, "faint")
    railList.empty:SetPoint("TOPLEFT", 12, -8)
    railList.empty:SetText(L("UI_NO_MATCH"))
    railList.empty:Hide()
    for _, id in ipairs(pageOrder) do RailButton(id) end
    LayoutRail("")

    local divider = Theme.Rule(window, true, "line")
    divider:SetPoint("TOPLEFT", window, "TOPLEFT", PAD + RAIL_W + 10, -(INSET + TITLE_H))
    divider:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT", PAD + RAIL_W + 10, INSET + FOOTER_H)

    -- ---- header and page
    header = CreateFrame("Frame", nil, window)
    header:SetPoint("TOPLEFT", CONTENT_LEFT, -(INSET + TITLE_H + 12))
    header:SetPoint("RIGHT", window, "RIGHT", -24, 0)
    header:SetHeight(64)
    header.title = Theme.Font(header:CreateFontString(nil, "OVERLAY"), 20, "accent")
    header.title:SetPoint("TOPLEFT", 0, -2)
    header.title:SetPoint("RIGHT")
    header.title:SetJustifyH("LEFT")
    header.desc = Theme.Font(header:CreateFontString(nil, "OVERLAY"), 13, "dim")
    header.desc:SetPoint("TOPLEFT", header.title, "BOTTOMLEFT", 0, -5)
    header.desc:SetPoint("RIGHT")
    header.desc:SetJustifyH("LEFT")
    header.desc:SetWordWrap(false)
    local headRule = Theme.Rule(header, false, "line")
    headRule:SetPoint("BOTTOMLEFT")
    headRule:SetPoint("BOTTOMRIGHT")

    scroll, content = Theme.ScrollFrame(window)
    scroll:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -12)
    scroll:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -26, INSET + FOOTER_H + 10)

    -- ---- resize, remembered
    local grip = Theme.ResizeGrip(window)
    grip:SetScript("OnMouseDown", function() window:StartSizing("BOTTOMRIGHT") end)
    grip:SetScript("OnMouseUp", function()
        window:StopMovingOrSizing()
        Theme.SnapToPixels(window)
        if FarmMapDB then
            FarmMapDB.uiWindow = { w = math.floor(window:GetWidth() + 0.5),
                                   h = math.floor(window:GetHeight() + 0.5) }
        end
        OptionsWindow:Refresh()
    end)
    -- Text wraps against a width: a resize re-lays the page, coalesced.
    local pending
    window:SetScript("OnSizeChanged", function()
        if pending then return end
        pending = true
        C_Timer.After(0.1, function() pending = false OptionsWindow:Refresh() end)
    end)
    window:SetScript("OnShow", function(self)
        self:Raise()
        FitRailHeight()
        Theme.SnapToPixels(self)
    end)
    -- The dashboard's duration and rates move with time, not only with
    -- harvests: re-read every 15 seconds while it is the page on screen.
    local sinceTick = 0
    window:SetScript("OnUpdate", function(_, elapsed)
        sinceTick = sinceTick + elapsed
        if sinceTick < 15 then return end
        sinceTick = 0
        if activeID == "dash" then OptionsWindow:Refresh() end
    end)
    window:Hide()
    return window
end

function OptionsWindow:Toggle(pageID)
    if not window then
        -- The saved theme is only readable once the SavedVariables exist.
        Theme.Reload()
        Create()
    end
    if window:IsShown() and not pageID then
        window:Hide()
        return
    end
    window:Show()
    self:Select(pageID or activeID or "theme")
end

-- ============================================================
-- PAGE: THEME
-- ============================================================

local TOKENS = {
    { "bg", "UI_TOKEN_BG" }, { "panel", "UI_TOKEN_PANEL" }, { "panel2", "UI_TOKEN_PANEL2" },
    { "line", "UI_TOKEN_LINE" }, { "accent", "UI_TOKEN_ACCENT" },
    { "accentSoft", "UI_TOKEN_ACCENTSOFT" }, { "text", "UI_TOKEN_TEXT" },
    { "dim", "UI_TOKEN_DIM" }, { "faint", "UI_TOKEN_FAINT" },
    { "good", "UI_TOKEN_GOOD" }, { "warn", "UI_TOKEN_WARN" }, { "bad", "UI_TOKEN_BAD" },
}
-- The four colours a theme card previews.
local SWATCHES = { "bg", "panel2", "accent", "text" }
local CARD_W, CARD_H, GAP = 240, 94, 12
local TOKEN_W, TOKEN_H = 236, 30

local function ThemeCard(frame)
    local card = CreateFrame("Button", nil, frame)
    card:SetSize(CARD_W, CARD_H)
    Theme.Plate(card, "panel", "line")
    card.name = Theme.Font(card:CreateFontString(nil, "OVERLAY"), 14, "text")
    card.name:SetPoint("TOPLEFT", 12, -10)
    card.swatches = {}
    for i = 1, #SWATCHES do
        local s = CreateFrame("Frame", nil, card)
        s:SetSize(30, 22)
        s:SetPoint("TOPLEFT", 12 + (i - 1) * 36, -38)
        s.fill = s:CreateTexture(nil, "ARTWORK")
        s.fill:SetAllPoints()
        s.fill:SetTexture("Interface\\AddOns\\FarmMap\\Textures\\ui\\tag-fill")
        s.fill:SetTextureSliceMargins(4, 4, 4, 4)
        card.swatches[i] = s
    end
    card.author = Theme.Font(card:CreateFontString(nil, "OVERLAY"), 12, "faint")
    card.author:SetPoint("BOTTOMLEFT", 12, 8)
    -- A theme that gives its author's site: the "by" line opens it to copy
    -- (WoW cannot open a browser). Over the text, sized to it in Layout.
    card.link = CreateFrame("Button", nil, card)
    card.link:SetPoint("BOTTOMLEFT", 8, 4)
    card.link:SetScript("OnClick", function() if card.url then ShowLink(card.url) end end)
    card.link:SetScript("OnEnter", function()
        card.author:SetTextColor(Theme.RGB("accent"))
        Theme.ShowTip(card.url, L("UI_THEME_SITE_TIP"))
    end)
    card.link:SetScript("OnLeave", function()
        card.author:SetTextColor(Theme.RGB("faint"))
        Theme.HideTip()
    end)
    -- The player's own themes only: delete, on a second click within a few
    -- seconds (the card says so in its bottom line meanwhile).
    card.delete = Theme.GlyphButton(card, "\195\151", 16)   -- multiplication sign
    card.delete:SetPoint("TOPRIGHT", -8, -8)
    card.delete:HookScript("OnEnter", function() Theme.ShowTip(L("UI_THEME_DELETE")) end)
    card.delete:HookScript("OnLeave", Theme.HideTip)
    card.delete:SetScript("OnClick", function(self)
        local key = card.themeKey
        if card.armed == key then
            card.armed = nil
            Theme.HideTip()
            Theme.DeleteUserTheme(key)
            OptionsWindow:Refresh()
            return
        end
        card.armed = key
        card.author:SetText(L("UI_THEME_DELETE_CONFIRM"))
        card.author:SetTextColor(Theme.RGB("bad"))
        C_Timer.After(4, function()
            if card.armed == key then
                card.armed = nil
                OptionsWindow:Refresh()
            end
        end)
    end)
    card:SetScript("OnClick", function(self)
        Theme.Apply(self.themeKey)
        OptionsWindow:Refresh()
    end)
    card:SetScript("OnEnter", function(self)
        if self.themeKey ~= Theme.CurrentKey() then Theme.PaintPlate(self, nil, "accentSoft") end
    end)
    card:SetScript("OnLeave", function(self)
        Theme.PaintPlate(self, nil, self.themeKey == Theme.CurrentKey() and "accent" or nil)
    end)
    return card
end

local function Hex(c)
    return ("%02x%02x%02x"):format(math.floor(c[1] * 255 + 0.5),
        math.floor(c[2] * 255 + 0.5), math.floor(c[3] * 255 + 0.5))
end

-- The colour picker moves many times a second: one page refresh per burst,
-- for the theme cards' swatches (the rest of the window repaints itself).
local refreshQueued
local function QueueRefresh()
    if refreshQueued then return end
    refreshQueued = true
    C_Timer.After(0.15, function() refreshQueued = false OptionsWindow:Refresh() end)
end

-- Blizzard's colour picker, the same on every client (checked in the
-- Retail, Forever, MoP and Era sources). Changes show live; Cancel puts
-- the colour back.
local function PickColor(themeKey, name)
    local c = Theme.c[name]
    local before = { c[1], c[2], c[3] }
    local function Set(r, g, b)
        Theme.SetUserColor(themeKey, name, r, g, b)
        QueueRefresh()
    end
    ColorPickerFrame:SetupColorPickerAndShow({
        r = before[1], g = before[2], b = before[3], hasOpacity = false,
        swatchFunc = function() Set(ColorPickerFrame:GetColorRGB()) end,
        cancelFunc = function() Set(before[1], before[2], before[3]) end,
    })
end

local function ExportTheme(key)
    local text = Theme.ExportTheme(key)
    if text then ShowLink(text, L("UI_THEME_EXPORT_HINT")) end
end

-- A name for a new copy that no theme carries yet.
local function NewThemeName()
    local taken = {}
    for _, def in ipairs(Theme.Themes()) do taken[def.label] = true end
    local n = 1
    while taken[L("UI_THEME_NEW_NAME"):format(n)] do n = n + 1 end
    return L("UI_THEME_NEW_NAME"):format(n)
end

local function TokenRow(parent)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(TOKEN_W - 16, 26)
    row.hi = row:CreateTexture(nil, "BACKGROUND")
    row.hi:SetAllPoints()
    row.hi:SetTexture("Interface\\Buttons\\WHITE8X8")
    row.hi:SetVertexColor(1, 1, 1, 0.06)
    row.hi:Hide()
    row.swatch = row:CreateTexture(nil, "ARTWORK")
    row.swatch:SetSize(20, 20)
    row.swatch:SetPoint("LEFT", 3, 0)
    row.swatch:SetTexture("Interface\\AddOns\\FarmMap\\Textures\\ui\\tag-fill")
    row.swatch:SetTextureSliceMargins(4, 4, 4, 4)
    row.label = Theme.Font(row:CreateFontString(nil, "OVERLAY"), 12.5, "text")
    row.label:SetPoint("LEFT", row.swatch, "RIGHT", 8, 0)
    row.label:SetPoint("RIGHT", -4, 0)
    row.label:SetJustifyH("LEFT")
    row.label:SetWordWrap(false)
    row:SetScript("OnEnter", function(self) if self.editable then self.hi:Show() end end)
    row:SetScript("OnLeave", function(self) self.hi:Hide() end)
    row:SetScript("OnClick", function(self)
        if self.editable then PickColor(Theme.CurrentKey(), self.key) end
    end)
    return row
end

OptionsWindow:AddPage({
    id = "theme", group = "settings", titleKey = "UI_THEME", descKey = "UI_THEME_DESC",
    SearchText = function()
        local parts = { L("UI_THEME_EDIT"), L("UI_THEME_LOCKED"), L("UI_THEME_OWN") }
        for _, def in ipairs(Theme.Themes()) do parts[#parts + 1] = def.label end
        return table.concat(parts, " ")
    end,
    Build = function(frame)
        frame.cards = {}

        -- The editor: the active theme's colours, editable when it is one
        -- of the player's own.
        local ed = OptionsWindow.Card(frame)
        ed.nameLabel = Theme.Font(ed:CreateFontString(nil, "OVERLAY"), 13, "dim")
        ed.nameBox = CreateFrame("EditBox", nil, ed)
        ed.nameBox:SetSize(280, 30)
        ed.nameBox:SetAutoFocus(false)
        ed.nameBox:SetMaxLetters(40)
        ed.nameBox:SetTextInsets(8, 8, 0, 0)
        Theme.Font(ed.nameBox, 13, "text")
        Theme.Plate(ed.nameBox, "bg", "line", true)
        local function SaveName(self)
            Theme.RenameUserTheme(Theme.CurrentKey(), self:GetText())
            self:ClearFocus()
            OptionsWindow:Refresh()
        end
        ed.nameBox:SetScript("OnEnterPressed", SaveName)
        -- Leaving the box saves too, and the card and title follow (they
        -- kept the old name until Enter, seen in game).
        ed.nameBox:SetScript("OnEditFocusLost", function(self)
            Theme.RenameUserTheme(Theme.CurrentKey(), self:GetText())
            QueueRefresh()
        end)
        ed.nameBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        ed.tokens = {}
        for i, token in ipairs(TOKENS) do
            local row = TokenRow(ed)
            row.key = token[1]
            Theme.Track(row.swatch, function(self) self:SetVertexColor(Theme.RGB(token[1])) end)
            ed.tokens[i] = row
        end
        ed.copy = Theme.ActionButton(ed, L("UI_THEME_COPY"), true)
        ed.copy:SetScript("OnClick", function()
            local key = Theme.CreateUserTheme(Theme.CurrentKey(), NewThemeName())
            if key then Theme.Apply(key) end
            OptionsWindow:Refresh()
        end)
        ed.export = Theme.ActionButton(ed, L("UI_THEME_EXPORT"))
        ed.export:SetScript("OnClick", function() ExportTheme(Theme.CurrentKey()) end)
        frame.editor = ed

        -- For addon authors: a theme can also ship as an addon.
        frame.own = OptionsWindow.Card(frame)
    end,
    Layout = function(frame, width)
        -- Theme cards, in a grid; themes registered by other addons and the
        -- player's own appear here as soon as they exist.
        local list = Theme.Themes()
        local columns = math.max(1, math.floor((width + GAP) / (CARD_W + GAP)))
        local current = Theme.CurrentKey()
        for _, card in ipairs(frame.cards) do card:Hide() end
        for i, def in ipairs(list) do
            local card = frame.cards[i] or ThemeCard(frame)
            frame.cards[i] = card
            if card.themeKey ~= def.key then card.armed = nil end
            card.themeKey = def.key
            card.name:SetText(def.label)
            -- A width makes a FontString centre its text: left, like the
            -- cards without one (seen on the first user theme, "TEST").
            card.name:SetWidth(CARD_W - 24 - (def.user and 20 or 0))
            card.name:SetJustifyH("LEFT")
            card.name:SetWordWrap(false)
            card.delete:SetShown(def.user and true or false)
            if card.armed == def.key then
                card.author:SetText(L("UI_THEME_DELETE_CONFIRM"))
                card.author:SetTextColor(Theme.RGB("bad"))
            else
                card.author:SetText(def.user and L("UI_THEME_MINE")
                    or (def.author and L("UI_THEME_BY"):format(def.author)) or "")
                card.author:SetTextColor(Theme.RGB("faint"))
            end
            card.url = (not def.user) and def.url or nil
            if card.url and card.armed ~= def.key then
                card.link:SetSize(math.floor(card.author:GetStringWidth() + 0.5) + 8, 20)
                card.link:Show()
            else
                card.link:Hide()
            end
            for s, name in ipairs(SWATCHES) do
                local c = def.colors[name] or Theme.c[name]
                card.swatches[s].fill:SetVertexColor(c[1], c[2], c[3])
            end
            local col, line = (i - 1) % columns, math.floor((i - 1) / columns)
            card:ClearAllPoints()
            card:SetPoint("TOPLEFT", 1 + col * (CARD_W + GAP), -(1 + line * (CARD_H + GAP)))
            Theme.PaintPlate(card, nil, def.key == current and "accent" or nil)
            card:Show()
        end
        local y = 1 + math.ceil(#list / columns) * (CARD_H + GAP) + 6

        -- The editor.
        local ed = frame.editor
        local editable = Theme.IsUser(current)
        local currentDef
        for _, def in ipairs(list) do if def.key == current then currentDef = def end end
        ed:ClearAllPoints()
        ed:SetPoint("TOPLEFT", 1, -y)
        ed:SetWidth(width - 2)
        local top
        if editable then
            top = ed:SetTexts(L("UI_THEME_EDIT_TITLE"):format(currentDef and currentDef.label or ""),
                L("UI_THEME_EDIT"), width - 2) + 4
            ed.nameLabel:SetText(L("UI_THEME_NAME"))
            ed.nameLabel:ClearAllPoints()
            ed.nameLabel:SetPoint("TOPLEFT", 14, -(top + 8))
            ed.nameLabel:Show()
            ed.nameBox:ClearAllPoints()
            ed.nameBox:SetPoint("TOPLEFT", 14 + math.floor(ed.nameLabel:GetStringWidth() + 0.5) + 10, -top)
            if not ed.nameBox:HasFocus() then ed.nameBox:SetText(currentDef and currentDef.label or "") end
            ed.nameBox:Show()
            top = top + 30 + 10
        else
            top = ed:SetTexts(L("UI_THEME_CUSTOM_TITLE"), L("UI_THEME_LOCKED"), width - 2) + 4
            ed.nameLabel:Hide()
            ed.nameBox:Hide()
        end
        -- Columns share the card's whole width: at a fixed 236 px, "Panels,
        -- second level #1e2530" lost its last digits (seen in game).
        local tokenCols = math.max(1, math.floor((width - 28) / TOKEN_W))
        local colW = math.floor((width - 28) / tokenCols)
        for i, row in ipairs(ed.tokens) do
            local col, line = (i - 1) % tokenCols, math.floor((i - 1) / tokenCols)
            row.editable = editable
            row.label:SetText(L(TOKENS[i][2]) .. "  |cff808080#" .. Hex(Theme.c[row.key]) .. "|r")
            row:SetWidth(colW - 8)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 11 + col * colW, -(top + line * TOKEN_H))
        end
        local by = top + math.ceil(#ed.tokens / tokenCols) * TOKEN_H + 8
        ed.copy:ClearAllPoints()
        ed.copy:SetPoint("TOPLEFT", 14, -by)
        ed.export:ClearAllPoints()
        ed.export:SetPoint("LEFT", ed.copy, "RIGHT", 10, 0)
        local edHeight = by + 30 + 14
        ed:SetHeight(edHeight)
        y = y + edHeight + 12

        -- Themes as addons, for their authors.
        local own = frame.own
        own:ClearAllPoints()
        own:SetPoint("TOPLEFT", 1, -y)
        own:SetWidth(width - 2)
        local ownHeight = own:SetTexts(L("UI_THEME_OWN_TITLE"), L("UI_THEME_OWN"), width - 2) + 10
        own:SetHeight(ownHeight)
        return y + ownHeight + 2
    end,
})

-- ============================================================
-- PAGE: CREDITS
-- ============================================================

-- KAO's credits layout: fixed-height panels in two columns, each with an
-- accent bar, an uppercase title, and a list that scrolls inside it. A
-- panel sized to its contents made the grid ragged; these lists only grow.
local PANEL_H = 176

-- Contributors who sign their translations with another name: one person,
-- one line, the way the README credits them.
local SAME_PERSON = {
    bluse     = "buseQ (bluse)",
    ZamestoTV = "Hubbotu (ZamestoTV)",
}

-- group = { id, title, sections = { { label, entries = { entry } } } }
-- entry = "text" or { text = , font = } (a line written in another script
-- carries the font that can draw it: a French client's has no Korean).
local function CreditGroups()
    local team = {
        id = "team", title = L("UI_CREDIT_TEAM"),
        sections = {
            { label = L("UI_ROLE_AUTHOR"),
              entries = { ns.IS_RETAIL and "Kroosstii (Dkroosstii-Dalaran)" or "Kroosstii" } },
        },
    }

    local info = {
        id = "info", title = L("UI_CREDIT_INFO"),
        sections = {
            { label = L("CREDITS_DISCORD"), entries = { "discord.gg/4BEGpmktK7" } },
            { label = L("CREDITS_GAME"),
              entries = { (ns.ClientLabel and ns.ClientLabel() or "") .. " " .. (GetBuildInfo()) } },
            { label = L("CREDITS_VERSION"),
              entries = { (ns.version or "?") .. "  (" .. (ns.lastUpdate or "?") .. ")" } },
        },
    }

    -- Translators from the language files themselves, so a new language
    -- credits its translator with no change here. One line per person,
    -- languages named in their own script.
    local byPerson, order = {}, {}
    for _, entry in ipairs(ns.GetAvailableLocales and ns.GetAvailableLocales() or {}) do
        local who = entry.data.translator or "-"
        who = SAME_PERSON[who] or who
        if not byPerson[who] then
            byPerson[who] = { names = {}, codes = {} }
            order[#order + 1] = who
        end
        table.insert(byPerson[who].names, entry.data.name or entry.code)
        table.insert(byPerson[who].codes, entry.code)
    end
    local translations = {}
    for _, who in ipairs(order) do
        local p = byPerson[who]
        -- A single language keeps its own font; a latin list keeps ours.
        translations[#translations + 1] = {
            text = who .. " — " .. table.concat(p.names, ", "),
            font = #p.codes == 1 and Theme.FontPath(p.codes[1]) or nil,
        }
    end

    -- Wide: the full width of both columns, on a row of its own. It holds
    -- the longest list, and the one that grows with every contribution.
    local contributors = {
        id = "contrib", title = L("UI_CONTRIBUTORS"), wide = true,
        sections = {
            { label = L("UI_TRANSLATORS"), entries = translations },
            { label = L("UI_CREDIT_CODE"), entries = {
                SAME_PERSON.bluse .. " — " .. L("UI_CONTRIB_BUSEQ"),
                "Crazyyoungs — " .. L("UI_CONTRIB_CRAZY"),
                "r0s0j — " .. L("UI_CONTRIB_R0S0J"),
                "fiote — " .. L("UI_CONTRIB_FIOTE"),
            } },
            -- The artist of FarmMap's icon (v2.0) and of the Sakura pack.
            { label = L("UI_CREDIT_ART"), entries = {
                "SorelDesign — " .. L("UI_CONTRIB_SOREL"),
            } },
            -- People who tested FarmMap in game with Kroosstii, from v1 on.
            { label = L("UI_CREDIT_TESTERS"), entries = {
                "Komî",
            } },
        },
    }
    return { team, info, contributors }
end

local function CreditPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetHeight(PANEL_H)
    Theme.Plate(panel, "panel", "line")

    -- Inset from the sides: the 8 px corners would cut a full-width bar.
    panel.bar = panel:CreateTexture(nil, "ARTWORK")
    panel.bar:SetPoint("TOPLEFT", 8, -1)
    panel.bar:SetPoint("TOPRIGHT", -8, -1)
    panel.bar:SetHeight(2)
    panel.bar:SetTexture("Interface\\Buttons\\WHITE8X8")
    Theme.Track(panel.bar, function(self) self:SetVertexColor(Theme.RGBA("accent", 0.85)) end)

    panel.title = Theme.Font(panel:CreateFontString(nil, "OVERLAY"), 11.5, "accent")
    panel.title:SetPoint("TOPLEFT", 14, -12)
    panel.title:SetJustifyH("LEFT")

    -- Right inset leaves room for the scroll rail, drawn outside its frame.
    panel.scroll, panel.body = Theme.ScrollFrame(panel)
    panel.scroll:SetPoint("TOPLEFT", 0, -36)
    panel.scroll:SetPoint("BOTTOMRIGHT", -14, 10)
    panel.lines = {}
    return panel
end

local function FillPanel(panel, group, width)
    panel:SetWidth(width)
    panel.title:SetText(group.title:upper())
    local textWidth = math.max(60, width - 14 - 26)
    local y, shown = 0, 0

    local function Write(entry, size, colorName, gap)
        local text, font = entry, nil
        if type(entry) == "table" then text, font = entry.text, entry.font end
        shown = shown + 1
        local fs = panel.lines[shown]
        if not fs then
            fs = panel.body:CreateFontString(nil, "OVERLAY")
            fs:SetJustifyH("LEFT")
            fs:SetWordWrap(true)
            panel.lines[shown] = fs
        end
        Theme.Font(fs, size, colorName, font)
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", 14, -y)
        fs:SetWidth(textWidth)
        fs:SetText(text or "")
        fs:Show()
        y = math.floor(y + fs:GetStringHeight() + gap + 0.5)
    end

    for index, section in ipairs(group.sections) do
        if index > 1 then y = y + 6 end
        -- Uppercase and dim: it reads as a label, not as a smaller name.
        Write(section.label:upper(), 11, "dim", 4)
        if #section.entries == 0 then
            Write("-", 13, "faint", 6)
        else
            for _, entry in ipairs(section.entries) do Write(entry, 13, "text", 5) end
        end
    end
    for i = shown + 1, #panel.lines do panel.lines[i]:Hide() end

    panel.body:SetHeight(math.max(y + 4, 1))
    panel.scroll:SetVerticalScroll(0)
    -- What the panel needs to show everything without scrolling: header
    -- (36) + list + bottom margin. The layout sizes panels from this, so
    -- the inner scroll only ever appears if a list outgrows its panel.
    return 36 + y + 14
end

OptionsWindow:AddPage({
    id = "credits", group = "top", titleKey = "UI_CREDITS", descKey = "UI_CREDITS_DESC",
    Build = function(frame)
        frame.panels = {}
        -- Kroosstii's own words above the panels, in English on every
        -- client: a heading, not a translated label.
        frame.thanks = Theme.Font(frame:CreateFontString(nil, "OVERLAY"), 24, "accent")
        frame.thanks:SetJustifyH("CENTER")
        frame.thanks:SetText("THANK YOU")
    end,
    Layout = function(frame, width)
        -- Two columns while there is room. 1 px inset: an outline flush
        -- with the scrolling page's edge loses that side.
        local GAP, INSET_X = 12, 1
        local columns = (width >= 480) and 2 or 1
        local columnW = math.floor((width - INSET_X * 2 - GAP * (columns - 1)) / columns)

        frame.thanks:ClearAllPoints()
        frame.thanks:SetPoint("TOPLEFT", 0, -4)
        frame.thanks:SetWidth(width)
        local groups = CreditGroups()
        local rowTop = 4 + math.floor(frame.thanks:GetStringHeight() + 0.5) + 14
        -- Panels of one row share the height of the tallest, so the grid
        -- stays aligned; none is shorter than PANEL_H.
        local row, column = {}, 0
        local function CloseRow()
            local h = PANEL_H
            for _, entry in ipairs(row) do h = math.max(h, entry.need) end
            for _, entry in ipairs(row) do entry.panel:SetHeight(h) end
            if #row > 0 then rowTop = rowTop + h + GAP end
            row, column = {}, 0
        end

        for _, group in ipairs(groups) do
            local panel = frame.panels[group.id] or CreditPanel(frame)
            frame.panels[group.id] = panel
            panel:ClearAllPoints()
            if group.wide and columns > 1 then
                CloseRow()
                -- Spans every column and runs down to the bottom of the
                -- visible page, following the window as it is resized. A
                -- smaller window shrinks the panel, and its list scrolls
                -- inside it (Kroosstii's call) rather than the whole page.
                panel:SetPoint("TOPLEFT", INSET_X, -rowTop)
                FillPanel(panel, group, width - INSET_X * 2)
                local fill = OptionsWindow.ViewportHeight() - rowTop - 2
                local h = math.max(PANEL_H, fill)
                panel:SetHeight(h)
                rowTop = rowTop + h + GAP
            else
                panel:SetPoint("TOPLEFT", INSET_X + column * (columnW + GAP), -rowTop)
                row[#row + 1] = { panel = panel, need = FillPanel(panel, group, columnW) }
                column = column + 1
                if column == columns then CloseRow() end
            end
            panel:Show()
        end
        CloseRow()
        return rowTop - GAP
    end,
})

-- ============================================================
-- RELOAD NOTICE
-- ============================================================

-- A card asking for a reload, with the button, for settings applied at the
-- next login. Place() shows it at y when needed and returns the next y.
local function ReloadNotice(parent)
    local notice = OptionsWindow.Card(parent)
    notice.button = Theme.ActionButton(notice, L("UI_RELOAD"), true)
    notice.button:SetScript("OnClick", function() ReloadUI() end)
    function notice:Place(y, width, show, text)
        if not show then self:Hide() return y end
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", 1, -y)
        self:SetWidth(width - 2)
        local top = self:SetTexts(nil, text, width - 2)
        self.button:ClearAllPoints()
        self.button:SetPoint("TOPLEFT", 14, -top - 2)
        self:SetHeight(top + 30 + 14)
        self:Show()
        return y + self:GetHeight() + 12
    end
    return notice
end

-- Which options window the minimap button opens is decided at login
-- (ns.legacyOptionsAtLogin, set in FarmMap.lua): a change asks for a
-- reload, and the page says so until it happens.
local function LegacyChanged()
    return (FarmMapDB.legacyOptions == true) ~= (ns.legacyOptionsAtLogin == true)
end

-- ============================================================
-- PAGES FROM A LIST OF SETTINGS
--
-- A settings page is a list of items, drawn top to bottom. Each item is a
-- table: type (section, switch, slider, choice, button, hint, notice or
-- custom), a unique key, its texts, get/set, and optional `visible` (false
-- hides it: a Retail-only setting elsewhere) and `disabled` (a function:
-- greyed while the setting it depends on is off). The list is re-read on
-- every layout, so a set() that calls OptionsWindow:Refresh() updates the
-- whole page - a switch greying out the rows that depend on it.
-- One row object per key, built once and reused (frames cannot be freed).
-- ============================================================

local ROW_MAKERS = {
    section = Theme.SectionHeader, switch = Theme.SwitchRow, slider = Theme.SliderRow,
    choice  = Theme.ChoiceRow,     button = Theme.ButtonRow, hint   = Theme.HintRow,
}

-- The words the rail's search looks for in a page of items: every visible
-- item's name, description and text, plus `search` (custom items: an addon
-- name, a card's text). noSearch: pages whose list is costly to build
-- (the nodes page reads the whole database), searched by title only.
local function ItemsSearchText(def)
    local parts = {}
    for _, item in ipairs(def.items()) do
        if item.visible ~= false then
            for _, field in ipairs({ "name", "desc", "text", "search" }) do
                if type(item[field]) == "string" then parts[#parts + 1] = item[field] end
            end
        end
    end
    return table.concat(parts, " ")
end

-- Lays a list of items out in `frame` (which holds frame.rows) and returns
-- the height used. Shared by the settings pages and the setup assistant;
-- `wheel` is the scroll frame the rows hand their mouse wheel to.
function OptionsWindow.LayoutItems(frame, items, width, wheel)
    -- Rows still in use are never hidden: hiding a search box drops
    -- its keyboard focus, and the nodes page re-lays itself on every
    -- letter typed. Only the rows left unused are hidden, at the end.
    local used = {}
    local y = 0
    for _, item in ipairs(items) do
        if item.visible ~= false then
            used[item.key] = true
            local row = frame.rows[item.key]
            if not row then
                if item.type == "notice" then
                    row = ReloadNotice(frame)
                elseif item.type == "custom" then
                    row = item.build(frame)
                else
                    row = ROW_MAKERS[item.type](frame)
                end
                frame.rows[item.key] = row
                -- Rows are drawn over the page: hand them its wheel (and
                -- to a custom row, for the rows it builds itself).
                row.wheel = wheel or scroll
                Theme.CatchWheel(row, row.wheel)
            end

            if item.type == "notice" then
                y = row:Place(y, width, item.show(), item.text)
            else
                -- inset: a bordered card flush with the page's
                -- clipping edge would lose that side of its outline.
                local x = item.inset and 1 or 0
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", x, -y)
                row:SetWidth(width - x * 2)
                if item.type == "section" then
                    row:SetContent(item.text)
                elseif item.type == "hint" then
                    row:SetContent(item.text, width)
                elseif item.type == "button" then
                    row:SetContent(item.name, item.desc, width, item.label)
                    row.button:SetScript("OnClick", function() item.onClick(row) end)
                    -- enabled = false: nothing to do (a pack already
                    -- installed), so the button says so and rests.
                    local enabled = item.enabled ~= false
                    row.button:SetEnabled(enabled)
                    row.button:SetAlpha(enabled and 1 or 0.5)
                elseif item.type == "custom" then
                    row:SetHeight(math.max(1, item.layout(row, width)))
                else
                    if item.type == "slider" then
                        row:SetRange(item.min, item.max, item.step)
                        row.format = item.format
                    end
                    row.isDisabled = item.disabled
                    row:SetContent(item.name, item.desc, width)
                    if item.type == "choice" then
                        row:Bind(item.get, item.set, item.choices())
                    else
                        row:Bind(item.get, item.set)
                    end
                end
                row:Show()
                y = y + row:GetHeight() + (item.gap or 0)
            end
        end
    end
    for key, row in pairs(frame.rows) do
        if not used[key] then row:Hide() end
    end
    return y + 4
end

local function ItemsPage(def)
    OptionsWindow:AddPage({
        id = def.id, group = "settings", titleKey = def.titleKey, descKey = def.descKey,
        items = def.items,
        SearchText = not def.noSearch and function() return ItemsSearchText(def) end or nil,
        Build = function(frame) frame.rows = {} end,
        Layout = function(frame, width) return OptionsWindow.LayoutItems(frame, def.items(), width) end,
    })
end

-- One setting of a page, by key, as that page defines it: the setup
-- assistant shows it with the same get/set, so both have the same effect.
function OptionsWindow.FindItem(pageID, key)
    local def = pages[pageID]
    for _, item in ipairs(def and def.items and def.items() or {}) do
        if item.key == key then return item end
    end
end

-- Keeps a legacy panel checkbox in step with a change made here. The legacy
-- panels re-read most settings when shown; these few only at creation.
local function SyncLegacyCheck(globalName, value)
    local check = _G[globalName]
    if check and check.SetChecked then check:SetChecked(value and true or false) end
end

-- The window size slider: waits until the mouse button is up, then resizes
-- the windows once and lays the page out again at the new size.
local scalePending
local function ApplyScaleWhenReleased()
    if scalePending then return end
    scalePending = true
    local function Try()
        if IsMouseButtonDown("LeftButton") then C_Timer.After(0.1, Try) return end
        scalePending = false
        Theme.RescaleWindows()
        OptionsWindow:Refresh()
    end
    C_Timer.After(0.1, Try)
end

-- Every setting writes FarmMapDB, then calls what the legacy panel calls,
-- so both windows have the same effect.
local function DB(key) return function() return FarmMapDB[key] end end

-- ============================================================
-- PAGE: DISPLAY
-- ============================================================

ItemsPage({
    id = "display", titleKey = "UI_DISPLAY", descKey = "UI_DISPLAY_DESC",
    items = function()
        local floatOff = function() return not FarmMapDB.showFloatingText end
        return {
            { type = "section", key = "general", text = L("UI_SEC_GENERAL") },
            { type = "switch", key = "newWindow",
              name = L("DISPLAY_NEW_WINDOW"), desc = L("DISPLAY_NEW_WINDOW_DESC"),
              get = function() return FarmMapDB.legacyOptions ~= true end,
              set = function(on)
                  FarmMapDB.legacyOptions = (not on) or nil
                  SyncLegacyCheck("FarmMapNewWindowCheck", on)
                  OptionsWindow:Refresh()
              end },
            { type = "notice", key = "newWindowReload",
              show = LegacyChanged, text = L("DISPLAY_NEW_WINDOW_RELOAD") },
            { type = "switch", key = "versionNotice",
              name = L("UI_VERSION_NOTICE"), desc = L("UI_VERSION_NOTICE_DESC"),
              get = function() return FarmMapDB.versionNotice ~= false end,
              set = function(on)
                  FarmMapDB.versionNotice = on and true or false
                  SyncLegacyCheck("FarmMapVersionNoticeCheck", on)
              end },
            -- Applied once the mouse is released: resizing the window under
            -- the slider being dragged would move the slider itself.
            { type = "slider", key = "uiScale",
              name = L("UI_WINDOW_SCALE"), desc = L("UI_WINDOW_SCALE_DESC"),
              -- Down to 40 %: at 60 % Era (UI scale 1.38x Retail's on
              -- Kroosstii's screen) still drew the window bigger than Retail.
              min = 40, max = 120, step = 5,
              format = function(v) return ("%d %%"):format(v) end,
              get = function() return math.floor(Theme.WindowScale() * 100 + 0.5) end,
              set = function(v)
                  FarmMapDB.uiScale = v / 100
                  ApplyScaleWhenReleased()
              end },

            { type = "section", key = "float", text = L("UI_SEC_FLOAT") },
            { type = "switch", key = "showFloatingText",
              name = L("UI_FLOAT"), desc = L("UI_FLOAT_DESC"),
              get = DB("showFloatingText"),
              set = function(on)
                  FarmMapDB.showFloatingText = on and true or false
                  OptionsWindow:Refresh()
              end },
            -- Reagent quality ranks only exist on Retail.
            { type = "switch", key = "showFloatTier", visible = ns.IS_RETAIL,
              name = L("UI_FLOAT_TIER"), desc = L("UI_FLOAT_TIER_DESC"), disabled = floatOff,
              get = function() return FarmMapDB.showFloatTier ~= false end,
              set = function(on) FarmMapDB.showFloatTier = on and true or false end },
            { type = "slider", key = "floatSize", disabled = floatOff,
              name = L("UI_FLOAT_SIZE"), min = 0.5, max = 2.0, step = 0.1,
              format = function(v) return ("%.1f"):format(v) end,
              get = DB("floatSize"), set = function(v) FarmMapDB.floatSize = v end },
            { type = "slider", key = "floatDuration", disabled = floatOff,
              name = L("UI_FLOAT_DURATION"), min = 1, max = 15, step = 1,
              format = function(v) return ("%d s"):format(v) end,
              get = DB("floatDuration"), set = function(v) FarmMapDB.floatDuration = v end },

            { type = "section", key = "filterbar", text = L("UI_SEC_FILTERBAR") },
            { type = "hint", key = "filterbarHint", text = L("UI_FILTERBAR_HINT") },
            { type = "slider", key = "filterBarScale",
              name = L("UI_FILTERBAR_SIZE"), min = 0.5, max = 2.0, step = 0.1,
              format = function(v) return ("%.1f"):format(v) end,
              get = DB("filterBarScale"),
              set = function(v)
                  FarmMapDB.filterBarScale = v
                  if FarmMap_ApplyFilterBarScale then FarmMap_ApplyFilterBarScale() end
              end },
            { type = "slider", key = "filterBarAlpha",
              name = L("UI_FILTERBAR_ALPHA"), min = 0, max = 100, step = 5,
              format = function(v) return ("%d %%"):format(v) end,
              get = DB("filterBarAlpha"), set = function(v) FarmMapDB.filterBarAlpha = v end },
            { type = "switch", key = "filterBarStyleIcons",
              name = L("UI_FILTERBAR_ICONS"), desc = L("UI_FILTERBAR_ICONS_DESC"),
              -- On by default (nil = on).
              get = function() return FarmMapDB.filterBarStyleIcons ~= false end,
              set = function(on)
                  FarmMapDB.filterBarStyleIcons = on and true or false
                  if FarmMap_ApplyFilterBarIcons then FarmMap_ApplyFilterBarIcons() end
              end },
            { type = "button", key = "filterBarReset",
              name = L("UI_FILTERBAR_RESET"), desc = L("UI_FILTERBAR_RESET_DESC"),
              label = L("FILTERBAR_RESET"),
              onClick = function()
                  if FarmMap_ResetFilterBar then FarmMap_ResetFilterBar() end
              end },

            { type = "section", key = "worldpins", text = L("UI_SEC_WORLDPINS") },
            { type = "slider", key = "worldPinScale",
              name = L("UI_WORLDPIN_SIZE"), min = 0.5, max = 2.0, step = 0.1,
              format = function(v) return ("%.1f"):format(v) end,
              get = DB("worldPinScale"),
              set = function(v)
                  FarmMapDB.worldPinScale = v
                  if FarmMap_ApplyWorldPinScale then FarmMap_ApplyWorldPinScale() end
              end },
            { type = "switch", key = "showNodeItemStats",
              name = L("UI_NODE_ITEMS"), desc = L("DISPLAY_NODE_ITEMS_HINT"),
              get = DB("showNodeItemStats"),
              set = function(on) FarmMapDB.showNodeItemStats = on and true or false end },
            -- On by default (nil = on): the pin's own icon in its tooltip.
            { type = "switch", key = "tooltipIcon",
              name = L("UI_TOOLTIP_ICON"), desc = L("UI_TOOLTIP_ICON_DESC"),
              get = function() return FarmMapDB.tooltipIcon ~= false end,
              set = function(on) FarmMapDB.tooltipIcon = on and true or false end },
        }
    end,
})

-- ============================================================
-- PAGE: MAP AND ICONS
-- ============================================================

local STYLE_ROW_H, STYLE_ICON = 38, 22

-- Hovering a preview icon shows it big, with its node type: a pack's
-- drawings are hard to judge at 22 px (asked with the Sakura pack).
local iconTip
local function ShowIconTip(owner, styleKey, nodeType)
    if not iconTip then
        iconTip = CreateFrame("Frame", nil, UIParent)
        iconTip:SetFrameStrata("TOOLTIP")
        iconTip:SetSize(124, 116)
        Theme.Plate(iconTip, "panel2", "accentSoft")
        iconTip.tex = iconTip:CreateTexture(nil, "ARTWORK")
        iconTip.tex:SetSize(72, 72)
        iconTip.tex:SetPoint("TOP", 0, -10)
        iconTip.label = Theme.Font(iconTip:CreateFontString(nil, "OVERLAY"), 12.5, "text")
        iconTip.label:SetPoint("BOTTOM", 0, 10)
    end
    ns.PreviewIcon(iconTip.tex, styleKey, nodeType)
    iconTip.label:SetText(L("TYPE_" .. nodeType))
    iconTip:SetScale(Theme.WindowScale())
    iconTip:ClearAllPoints()
    iconTip:SetPoint("BOTTOM", owner, "TOP", 0, 6)
    iconTip:Show()
end

local function StyleRow(parent)
    local b = CreateFrame("Button", nil, parent)
    b:SetHeight(STYLE_ROW_H)
    Theme.Plate(b, "panel", "line", true)
    b.label = Theme.Font(b:CreateFontString(nil, "OVERLAY"), 13.5, "text")
    b.label:SetPoint("LEFT", 12, 0)
    b.label:SetJustifyH("LEFT")
    b.label:SetWordWrap(false)
    local function Paint(self)
        Theme.PaintPlate(self, self.selected and "panel2" or nil, self.selected and "accent" or nil)
    end
    local function Hover(self)
        if not self.selected then Theme.PaintPlate(self, nil, "accentSoft") end
    end
    -- Each icon sits on a small button of its own, for the hover preview;
    -- a click on it still picks the row's style.
    b.icons, b.hits = {}, {}
    for i = 1, 4 do
        local hit = CreateFrame("Button", nil, b)
        hit:SetSize(STYLE_ICON, STYLE_ICON)
        local t = hit:CreateTexture(nil, "ARTWORK")
        t:SetAllPoints()
        hit:SetScript("OnClick", function() b:Click() end)
        hit:SetScript("OnEnter", function(self)
            Hover(b)
            ShowIconTip(self, b.styleKey, self.nodeType)
        end)
        hit:SetScript("OnLeave", function()
            Paint(b)
            if iconTip then iconTip:Hide() end
        end)
        b.icons[i], b.hits[i] = t, hit
    end
    Theme.Track(b, Paint)
    b:SetScript("OnClick", function(self)
        ns.SetStyle(self.dbKey, self.styleKey)
        OptionsWindow:Refresh()
    end)
    b:SetScript("OnEnter", Hover)
    b:SetScript("OnLeave", Paint)
    b.Paint = Paint
    return b
end

local function FillStyleRow(b, style, dbKey, width)
    b.dbKey, b.styleKey = dbKey, style.key
    b:SetWidth(width)
    local types = ns.PREVIEW_TYPES or {}
    local step = STYLE_ICON + 6
    b.label:SetWidth(math.max(40, width - #types * step - 26))
    b.label:SetText(style.label .. (style.pack and ("  |cff808080" .. L("UI_STYLE_PACK") .. "|r") or ""))
    for i, tex in ipairs(b.icons) do
        local nodeType, hit = types[i], b.hits[i]
        if nodeType then
            local dy = ns.PreviewIcon(tex, style.key, nodeType)
            hit.nodeType = nodeType
            hit:ClearAllPoints()
            hit:SetPoint("RIGHT", b, "RIGHT", -(12 + (#types - i) * step), dy)
            hit:Show()
        else
            hit:Hide()
        end
    end
    b.selected = ns.GetStyle(dbKey) == style.key
    b:Paint()
    b:Show()
end

-- Two lists side by side, minimap and world map, as in the legacy Colors
-- panel; stacked when the window is narrow. Icon packs join the lists.
local function BuildStyleColumns(parent)
    local f = CreateFrame("Frame", nil, parent)
    f.columns = {}
    for i, dbKey in ipairs({ "minimapStyle", "worldmapStyle" }) do
        local col = { dbKey = dbKey, rows = {} }
        col.title = Theme.Font(f:CreateFontString(nil, "OVERLAY"), 13.5, "text")
        col.title:SetJustifyH("LEFT")
        f.columns[i] = col
    end
    return f
end

local function LayoutStyleColumns(f, width)
    local GAP = 18
    local twoCols = width >= 560
    local colW = twoCols and math.floor((width - 2 - GAP) / 2) or (width - 2)
    local titles = { L("UI_STYLE_MINIMAP"), L("UI_STYLE_WORLDMAP") }
    local bottom, top = 0, 0
    for i, col in ipairs(f.columns) do
        local x = (twoCols and i == 2) and (colW + GAP + 1) or 1
        local y = (twoCols or i == 1) and top or bottom + 14
        col.title:ClearAllPoints()
        col.title:SetPoint("TOPLEFT", x, -y)
        col.title:SetText(titles[i])
        y = y + math.floor(col.title:GetStringHeight() + 0.5) + 8
        for _, row in ipairs(col.rows) do row:Hide() end
        for r, style in ipairs(ns.StyleList(col.dbKey)) do
            local row = col.rows[r] or StyleRow(f)
            col.rows[r] = row
            Theme.CatchWheel(row, f.wheel or scroll)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", x, -y)
            FillStyleRow(row, style, col.dbKey, colW)
            y = y + STYLE_ROW_H + 6
        end
        bottom = math.max(bottom, y)
    end
    return bottom + 6
end

-- Icon packs on CurseForge, as in the legacy Packs panel, with the folder
-- each installs: once it is loaded, its button says so instead of linking.
local PACK_LINKS = {
    { name = "Old Colors",              addon = "FarmMap_OldColors",
      url = "https://www.curseforge.com/wow/addons/farmmap-old-colors" },
    { name = "The Artisan's Anthology", addon = "FarmMap_TAA",
      url = "https://www.curseforge.com/wow/addons/farmmap-the-artisans-anthology" },
}

local function PackItem(key, pack)
    local installed = ns.IsAddOnLoaded and ns.IsAddOnLoaded(pack.addon)
    return { type = "button", key = key, name = pack.name,
             label = installed and L("UI_PACK_INSTALLED") or "CurseForge",
             enabled = not installed,
             onClick = function() ShowLink(pack.url) end }
end

ItemsPage({
    id = "icons", titleKey = "UI_ICONS", descKey = "UI_ICONS_DESC",
    items = function()
        return {
            { type = "section", key = "styles", text = L("UI_SEC_STYLES") },
            { type = "custom", key = "styleColumns",
              build = BuildStyleColumns, layout = LayoutStyleColumns },

            { type = "section", key = "minimap", text = L("UI_SEC_MINIMAP") },
            { type = "switch", key = "showMinimapPins",
              name = L("UI_MINIMAP_PINS"), desc = L("UI_MINIMAP_PINS_DESC"),
              get = function() return FarmMapDB.showMinimapPins ~= false end,
              set = function(on)
                  FarmMapDB.showMinimapPins = on and true or false
                  SyncLegacyCheck("FarmMapShowMinimapPinsCheck", on)
                  if ns.RefreshAllPins then ns.RefreshAllPins() end
              end },
            { type = "switch", key = "hideNearbyMinimapPins",
              name = L("UI_MINIMAP_HIDE_NEARBY"), desc = L("UI_MINIMAP_HIDE_NEARBY_DESC"),
              get = function() return FarmMapDB.hideNearbyMinimapPins ~= false end,
              set = function(on)
                  FarmMapDB.hideNearbyMinimapPins = on and true or false
                  SyncLegacyCheck("FarmMapHideNearbyMinimapPinsCheck", on)
                  if ns.UpdateMinimapPinProximity then ns.UpdateMinimapPinProximity() end
              end },
            { type = "slider", key = "nearbyMinimapPinRadius",
              name = L("UI_MINIMAP_HIDE_NEARBY_RADIUS"), min = 50, max = 300, step = 25,
              disabled = function() return FarmMapDB.hideNearbyMinimapPins == false end,
              format = function(v) return L("UNIT_YARDS"):format(v) end,
              get = DB("nearbyMinimapPinRadius"),
              set = function(v)
                  FarmMapDB.nearbyMinimapPinRadius = v
                  if ns.UpdateMinimapPinProximity then ns.UpdateMinimapPinProximity() end
              end },
            { type = "switch", key = "minimapButton",
              visible = ns.HasMinimapButton and ns.HasMinimapButton() or false,
              name = L("UI_MINIMAP_BUTTON"), desc = L("UI_MINIMAP_BUTTON_DESC"),
              get = function() return not (FarmMapDB.minimapIcon and FarmMapDB.minimapIcon.hide) end,
              set = function(on)
                  ns.SetMinimapButtonShown(on)
                  SyncLegacyCheck("FarmMapShowMinimapButtonCheck", on)
              end },

            { type = "section", key = "packs", text = L("UI_SEC_PACKS") },
            { type = "hint", key = "packsHint", text = L("UI_PACKS_DESC") },
            PackItem("packOld", PACK_LINKS[1]),
            PackItem("packArtisan", PACK_LINKS[2]),
        }
    end,
})

-- ============================================================
-- PAGE: INTEGRATIONS
-- ============================================================

-- One card per addon FarmMap works with: name, whether it is installed
-- (and which version), what it adds. Addon names are brands: not translated.
local function AddonCard(addonLabel, isLoaded, versionOf, descKey)
    return {
        search = addonLabel .. " " .. L(descKey),
        build = function(parent)
            local card = OptionsWindow.Card(parent)
            card.tag = Theme.Tag(card)
            return card
        end,
        layout = function(card, width)
            local loaded = isLoaded()
            local top = card:SetTexts(addonLabel, L(descKey), width - 2)
            local version = loaded and versionOf and versionOf()
            local status = loaded and L("INTEG_DETECTED") or L("INTEG_MISSING")
            if version and version ~= "" then
                status = status .. " · " .. L("CREDITS_VERSION") .. " " .. version
            end
            card.tag:SetTag(status, loaded and "good" or "faint")
            card.tag:ClearAllPoints()
            card.tag:SetPoint("LEFT", card.title, "LEFT",
                math.floor(card.title:GetStringWidth() + 0.5) + 12, 0)
            card:SetWidth(width - 2)
            card:SetHeight(top + 6)
            return top + 8
        end,
    }
end

-- The closing card: FarmMap can learn to work with other addons, and the
-- players are the ones who know which.
local function AskCard()
    return {
        build = function(parent)
            local card = OptionsWindow.Card(parent)
            card.discord = Theme.ActionButton(card, "Discord")
            card.discord:SetScript("OnClick", function() ShowLink(LINKS[1].url) end)
            return card
        end,
        layout = function(card, width)
            local top = card:SetTexts(L("UI_INTEG_ASK_TITLE"), L("UI_INTEG_ASK"), width - 2)
            card.discord:ClearAllPoints()
            card.discord:SetPoint("TOPLEFT", 14, -top - 2)
            card:SetWidth(width - 2)
            card:SetHeight(top + 30 + 14)
            return card:GetHeight() + 2
        end,
    }
end

local function GetVersion(name) return function() return ns.GetAddOnVersion(name) end end

ItemsPage({
    id = "integ", titleKey = "UI_INTEG", descKey = "UI_INTEG_DESC",
    items = function()
        local auc = AddonCard("Auctionator", ns.IsAuctionatorLoaded, GetVersion("Auctionator"),
            "INTEG_AUCTIONATOR_DESC")
        local tsm = AddonCard("TradeSkillMaster", ns.IsTSMLoaded, GetVersion("TradeSkillMaster"),
            "INTEG_TSM_DESC")
        local tomtom = AddonCard("TomTom", ns.IsTomTomLoaded, GetVersion("TomTom"),
            "INTEG_TOMTOM_DESC")
        local wui = AddonCard("WaypointUI", ns.IsWaypointUILoaded, GetVersion("WaypointUI"),
            "INTEG_WAYPOINTUI_DESC")
        local hasNav = function() return ns.IsTomTomLoaded() or ns.IsWaypointUILoaded() end
        local ask = AskCard()
        local hasAuc, hasTSM = ns.IsAuctionatorLoaded(), ns.IsTSMLoaded()
        -- The value rides on the floating text: say why the switch is grey.
        local profitDesc = L("UI_PROFIT_DESC")
        if not ns.HasPriceSource() then
            profitDesc = profitDesc .. " " .. L("UI_PROFIT_NEEDS_AUC")
        elseif not FarmMapDB.showFloatingText then
            profitDesc = profitDesc .. " " .. L("UI_PROFIT_NEEDS_FLOAT")
        end
        local tsmChoices = {}
        for _, key in ipairs(ns.TSM_PRICE_KEYS) do
            tsmChoices[#tsmChoices + 1] = { value = key, label = L("UI_TSM_" .. key) }
        end
        return {
            { type = "section", key = "secPrice", text = L("UI_SEC_PRICES") },
            { type = "custom", key = "auctionator", build = auc.build, layout = auc.layout,
              search = auc.search, inset = true, gap = 4 },
            -- No card for an addon that has no build for this client (TSM on
            -- Forever, WaypointUI on Classic: checked 2026-10-08), unless a
            -- player has it running anyway.
            { type = "custom", key = "tsm", build = tsm.build, layout = tsm.layout,
              visible = ns.IsTSMLoaded() or not ns.IS_FOREVER,
              search = tsm.search, inset = true, gap = 4 },
            -- A choice only when there is one to make.
            { type = "choice", key = "priceSource", visible = hasAuc and hasTSM,
              name = L("UI_PRICE_SOURCE"), desc = L("UI_PRICE_SOURCE_DESC"),
              choices = function()
                  return { { value = "auctionator", label = "Auctionator" },
                           { value = "tsm", label = "TradeSkillMaster" } }
              end,
              get = function() return ns.PriceSource() end,
              set = function(value)
                  FarmMapDB.priceSource = value
                  OptionsWindow:Refresh()
              end },
            { type = "choice", key = "tsmPrice", visible = ns.PriceSource() == "tsm",
              name = L("UI_TSM_PRICE"), desc = L("UI_TSM_PRICE_DESC"),
              choices = function() return tsmChoices end,
              get = function() return FarmMapDB.tsmPrice or ns.TSM_PRICE_KEYS[1] end,
              set = function(value) FarmMapDB.tsmPrice = value end },
            { type = "switch", key = "showProfit",
              name = L("UI_PROFIT"), desc = profitDesc,
              disabled = function() return not (ns.HasPriceSource() and FarmMapDB.showFloatingText) end,
              get = function() return FarmMapDB.showProfit ~= false end,
              set = function(on) FarmMapDB.showProfit = on and true or false end },

            { type = "section", key = "secMap", text = L("UI_SEC_WAYPOINTS") },
            { type = "custom", key = "tomtom", build = tomtom.build, layout = tomtom.layout,
              search = tomtom.search, inset = true, gap = 4 },
            { type = "custom", key = "waypointui", build = wui.build, layout = wui.layout,
              visible = ns.IsWaypointUILoaded() or ns.IS_RETAIL or ns.IS_FOREVER,
              search = wui.search, inset = true, gap = 4 },
            -- Which one, when both are there.
            { type = "choice", key = "waypointAddon",
              visible = ns.IsTomTomLoaded() and ns.IsWaypointUILoaded(),
              name = L("UI_WAYPOINT_ADDON"), desc = L("UI_WAYPOINT_ADDON_DESC"),
              choices = function()
                  return { { value = "TomTom", label = "TomTom" },
                           { value = "WaypointUI", label = "WaypointUI" } }
              end,
              get = function() return FarmMapDB.waypointAddon == "WaypointUI" and "WaypointUI" or "TomTom" end,
              set = function(value) FarmMapDB.waypointAddon = value end },
            -- gap: the card below sat right on this row's bottom rule.
            { type = "switch", key = "waypointClick", gap = 12,
              name = L("UI_WAYPOINT_CLICK"), desc = L("UI_WAYPOINT_CLICK_DESC"),
              disabled = function() return not hasNav() end,
              get = function() return FarmMapDB.waypointClick ~= false end,
              set = function(on) FarmMapDB.waypointClick = on and true or false end },

            { type = "custom", key = "ask", build = ask.build, layout = ask.layout,
              search = L("UI_INTEG_ASK_TITLE") .. " " .. L("UI_INTEG_ASK"), inset = true },
        }
    end,
})

-- ============================================================
-- SHARED BITS FOR THE DATA PAGES
-- ============================================================

local WHITE = "Interface\\Buttons\\WHITE8X8"

local function TypeName(t) return L("TYPE_" .. (t or "")) end

local function TypeColor(t)
    local c = ns.TYPE_COLORS and ns.TYPE_COLORS[t]
    return c and c[1] or 1, c and c[2] or 1, c and c[3] or 1
end

-- A small round-cornered square in the colour of a node type.
local function TypeDot(parent, size)
    local dot = parent:CreateTexture(nil, "ARTWORK")
    dot:SetSize(size or 10, size or 10)
    dot:SetTexture("Interface\\AddOns\\FarmMap\\Textures\\ui\\tag-fill")
    dot:SetTextureSliceMargins(4, 4, 4, 4)
    return dot
end

-- Copper as gold, silver and copper with the game's coin icons. From one
-- gold up the copper is dropped: it means nothing at that scale, and it
-- pushed "gold per hour" past the edge of its tile (seen in game).
local COIN = "|TInterface\\MoneyFrame\\UI-%sIcon:0:0:2:0|t"
local function Money(copper)
    copper = math.floor(copper or 0)
    local g, s, c = math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100
    local parts = {}
    if g > 0 then parts[#parts + 1] = g .. COIN:format("Gold") end
    if s > 0 or g > 0 then parts[#parts + 1] = s .. COIN:format("Silver") end
    if g == 0 then parts[#parts + 1] = c .. COIN:format("Copper") end
    return table.concat(parts, " ")
end

local function Ago(at)
    local s = time() - (at or 0)
    if s < 60 then return L("UI_AGO_NOW") end
    if s < 3600 then return L("UI_AGO_MIN"):format(math.floor(s / 60)) end
    return L("UI_AGO_H"):format(math.floor(s / 3600))
end

local function Duration(seconds)
    local m = math.floor(seconds / 60)
    if m < 60 then return L("UI_DUR_MIN"):format(m) end
    return L("UI_DUR_H"):format(math.floor(m / 60), m % 60)
end

-- Item name in the client's language when the game has it cached.
local function ItemName(id, fallback)
    local name = id and id > 0 and C_Item and C_Item.GetItemInfo and C_Item.GetItemInfo(id)
    return name or fallback or "?"
end

-- A plain text line on a card or a page, pooled by the caller.
local function Text(parent, size, colorName)
    local fs = Theme.Font(parent:CreateFontString(nil, "OVERLAY"), size, colorName)
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(false)
    return fs
end

-- ============================================================
-- PAGE: DASHBOARD
-- ============================================================

local TILE_H = 92

local function BuildTiles(parent)
    local f = CreateFrame("Frame", nil, parent)
    f.tiles = {}
    for i = 1, 4 do
        local tile = CreateFrame("Frame", nil, f)
        tile:SetHeight(TILE_H)
        Theme.Plate(tile, "panel", "line")
        tile.k = Text(tile, 12, "dim")
        tile.k:SetPoint("TOPLEFT", 14, -12)
        tile.v = Text(tile, 21, "text")
        tile.v:SetPoint("TOPLEFT", tile.k, "BOTTOMLEFT", 0, -8)
        tile.s = Text(tile, 11.5, "faint")
        tile.s:SetPoint("TOPLEFT", tile.v, "BOTTOMLEFT", 0, -6)
        f.tiles[i] = tile
    end
    return f
end

-- The session's numbers, computed once for the dashboard and the small
-- session window (UI\SessionWindow.lua), so both always agree. Rates only
-- once the session has run a minute: before that one harvest would read as
-- hundreds per hour. Value fields are nil without Auctionator or TSM.
function OptionsWindow.SessionNumbers()
    local s = ns.GetSession()
    local elapsed = math.max(0, time() - (s.start or time()))
    local hours = elapsed / 3600
    local hasAuc = ns.HasPriceSource()
    local rated = elapsed >= 60
    return {
        elapsed = elapsed,
        nodes   = s.nodes,
        perHour = rated and math.floor(s.nodes / hours + 0.5) or nil,
        value   = hasAuc and s.value or nil,
        gph     = (hasAuc and rated) and (s.value / hours) or nil,
    }
end
OptionsWindow.Money, OptionsWindow.Duration = Money, Duration

local function LayoutTiles(f, width)
    local n = OptionsWindow.SessionNumbers()
    local data = {
        { L("UI_DASH_TIME"), Duration(n.elapsed), L("UI_DASH_TIME_SUB") },
        { L("UI_DASH_NODES"), tostring(n.nodes),
          n.perHour and L("UI_DASH_PER_HOUR"):format(n.perHour) or "—" },
        { L("UI_DASH_VALUE"), n.value and Money(n.value) or "—",
          n.value and L("UI_DASH_VALUE_SUB"):format(
              ns.PriceSource() == "tsm" and "TSM" or "Auctionator") or L("UI_PROFIT_NEEDS_AUC") },
        { L("UI_DASH_GPH"), n.gph and Money(n.gph) or "—", L("UI_DASH_GPH_SUB") },
    }
    local GAP = 12
    local cols = width >= 700 and 4 or 2
    local w = math.floor((width - 2 - GAP * (cols - 1)) / cols)
    for i, tile in ipairs(f.tiles) do
        local col, line = (i - 1) % cols, math.floor((i - 1) / cols)
        tile:ClearAllPoints()
        tile:SetPoint("TOPLEFT", 1 + col * (w + GAP), -(line * (TILE_H + GAP)))
        tile:SetWidth(w)
        tile.k:SetText(data[i][1])
        tile.v:SetText(data[i][2])
        tile.s:SetText(data[i][3])
        tile.k:SetWidth(w - 28)
        tile.v:SetWidth(w - 28)
        tile.s:SetWidth(w - 28)
        if i == 4 then tile.v:SetTextColor(Theme.RGB("accent")) end
    end
    return math.ceil(4 / cols) * (TILE_H + GAP)
end

-- Harvests per resource type, as bars scaled to the largest.
local function BuildByType(parent)
    local card = OptionsWindow.Card(parent)
    card.rows = {}
    for i, t in ipairs(ns.PREVIEW_TYPES or {}) do
        local r = {}
        r.dot = TypeDot(card)
        r.label = Text(card, 13, "text")
        r.track = card:CreateTexture(nil, "ARTWORK")
        r.track:SetTexture(WHITE)
        r.track:SetHeight(10)
        Theme.Track(r.track, function(self) self:SetVertexColor(Theme.RGB("panel2")) end)
        r.fill = card:CreateTexture(nil, "OVERLAY")
        r.fill:SetTexture(WHITE)
        r.fill:SetHeight(10)
        r.count = Text(card, 13, "text")
        r.count:SetJustifyH("RIGHT")
        r.type = t
        card.rows[i] = r
    end
    card.total = Text(card, 13, "text")
    return card
end

-- card.counts() gives { [type] = count }; card.withTotal adds a total line.
local function LayoutByType(card, width)
    local counts = card.counts()
    local top = card:SetTexts(L(card.titleKey), nil, width - 2) + 4
    local max = 1
    for _, r in ipairs(card.rows) do max = math.max(max, counts[r.type] or 0) end
    local LABEL_W, COUNT_W = 150, 50
    local trackW = math.max(40, width - 2 - 28 - LABEL_W - COUNT_W - 16)
    for i, r in ipairs(card.rows) do
        local y = top + (i - 1) * 28
        local n = counts[r.type] or 0
        r.dot:SetPoint("TOPLEFT", 14, -(y + 4))
        r.dot:SetVertexColor(TypeColor(r.type))
        r.label:SetPoint("TOPLEFT", 30, -y)
        r.label:SetWidth(LABEL_W - 20)
        r.label:SetText(TypeName(r.type))
        r.track:ClearAllPoints()
        r.track:SetPoint("TOPLEFT", 14 + LABEL_W, -(y + 4))
        r.track:SetWidth(trackW)
        r.fill:ClearAllPoints()
        r.fill:SetPoint("TOPLEFT", r.track, "TOPLEFT")
        r.fill:SetWidth(math.max(1, math.floor(trackW * n / max)))
        r.fill:SetVertexColor(TypeColor(r.type))
        r.fill:SetShown(n > 0)
        r.count:ClearAllPoints()
        r.count:SetPoint("TOPRIGHT", -14, -y)
        r.count:SetWidth(COUNT_W)
        r.count:SetText(tostring(n))
    end
    local h = top + #card.rows * 28 + 8
    if card.withTotal then
        local total = 0
        for _, r in ipairs(card.rows) do total = total + (counts[r.type] or 0) end
        card.total:ClearAllPoints()
        card.total:SetPoint("TOPLEFT", 14, -(h - 2))
        card.total:SetWidth(width - 30)
        card.total:SetText(L("STATS_TOTAL") .. " : " .. total)
        card.total:Show()
        h = h + 26
    else
        card.total:Hide()
    end
    card:SetHeight(h)
    return h
end

local function ByTypeItem(key, titleKey, counts, withTotal, gap)
    return {
        type = "custom", key = key, inset = true, gap = gap or 12,
        build = function(parent)
            local card = BuildByType(parent)
            card.titleKey, card.counts, card.withTotal = titleKey, counts, withTotal
            return card
        end,
        layout = LayoutByType,
    }
end

-- The last harvests of the session: item, zone, how long ago.
local function BuildRecent(parent)
    local card = OptionsWindow.Card(parent)
    card.lines = {}
    card.empty = Text(card, 13, "faint")
    return card
end

local function LayoutRecent(card, width)
    local s = ns.GetSession()
    local top = card:SetTexts(L("UI_DASH_RECENT"), nil, width - 2) + 4
    for _, line in ipairs(card.lines) do line.dot:Hide() line.name:Hide() line.zone:Hide() line.ago:Hide() end
    card.empty:SetShown(#s.recent == 0)
    if #s.recent == 0 then
        card.empty:ClearAllPoints()
        card.empty:SetPoint("TOPLEFT", 14, -top)
        card.empty:SetText(L("UI_DASH_RECENT_EMPTY"))
        card:SetHeight(top + 30)
        return top + 30
    end
    local nameW = math.floor((width - 2 - 28 - 110) * 0.55)
    for i, h in ipairs(s.recent) do
        local line = card.lines[i]
        if not line then
            line = { dot = TypeDot(card), name = Text(card, 13, "text"),
                     zone = Text(card, 13, "dim"), ago = Text(card, 12.5, "faint") }
            line.ago:SetJustifyH("RIGHT")
            card.lines[i] = line
        end
        local y = top + (i - 1) * 26
        line.dot:ClearAllPoints()
        line.dot:SetPoint("TOPLEFT", 14, -(y + 4))
        line.dot:SetVertexColor(TypeColor(h.type))
        line.name:ClearAllPoints()
        line.name:SetPoint("TOPLEFT", 30, -y)
        line.name:SetWidth(nameW)
        line.name:SetText(ItemName(h.id, h.name))
        local info = h.mapID and C_Map.GetMapInfo(h.mapID)
        line.zone:ClearAllPoints()
        line.zone:SetPoint("TOPLEFT", 30 + nameW + 10, -y)
        line.zone:SetWidth(width - 2 - 28 - 110 - nameW - 26)
        line.zone:SetText(info and info.name or "")
        line.ago:ClearAllPoints()
        line.ago:SetPoint("TOPRIGHT", -14, -y)
        line.ago:SetWidth(100)
        line.ago:SetText(Ago(h.at))
        for _, part in pairs(line) do part:Show() end
    end
    local hgt = top + #s.recent * 26 + 8
    card:SetHeight(hgt)
    return hgt
end

-- Destructive actions take a second click within a few seconds.
local function ArmOrRun(row, label, run)
    if row.armed then
        row.armed = nil
        row.button:SetLabel(label)
        run()
        return
    end
    row.armed = true
    row.button:SetLabel(L("UI_DB_CLEAR_CONFIRM"))
    C_Timer.After(4, function()
        if row.armed then
            row.armed = nil
            row.button:SetLabel(label)
        end
    end)
end

ItemsPage({
    id = "dash", titleKey = "UI_DASH", descKey = "UI_DASH_DESC",
    items = function()
        return {
            { type = "custom", key = "tiles", build = BuildTiles, layout = LayoutTiles },
            -- The same numbers in a small window of their own, to keep an
            -- eye on a farm without opening the options (Kroosstii's idea).
            { type = "switch", key = "sessionWindow", gap = 12,
              name = L("UI_DASH_MINI"), desc = L("UI_DASH_MINI_DESC"),
              get = function() return ns.SessionWindow and ns.SessionWindow:IsEnabled() end,
              set = function(on) if ns.SessionWindow then ns.SessionWindow:SetEnabled(on) end end },
            ByTypeItem("byType", "UI_DASH_BYTYPE", function() return ns.GetSession().byType end),
            { type = "custom", key = "recent", build = BuildRecent, layout = LayoutRecent,
              inset = true, gap = 4 },
            { type = "button", key = "resetSession",
              name = L("UI_DASH_RESET"), desc = L("UI_DASH_RESET_DESC"), label = L("UI_DASH_RESET"),
              onClick = function(row)
                  ArmOrRun(row, L("UI_DASH_RESET"), function() ns.ResetSession() end)
              end },

            -- Lifetime totals: what the legacy Stats panel shows.
            { type = "section", key = "lifetime", text = L("UI_SEC_LIFETIME") },
            ByTypeItem("lifetimeByType", "UI_DASH_LIFETIME", function()
                return FarmMapStatsDB and FarmMapStatsDB.counts or {}
            end, true, 4),
            { type = "button", key = "resetStats",
              name = L("STATS_RESET"), desc = L("UI_STATS_RESET_DESC"), label = L("STATS_RESET"),
              onClick = function(row)
                  ArmOrRun(row, L("STATS_RESET"), function()
                      ns.ResetStats()
                      print("|cffffd100FarmMap :|r " .. L("STATS_RESET_DONE"))
                  end)
              end },
        }
    end,
})

-- ============================================================
-- PAGE: NODES
-- ============================================================

-- Filters and selection live on the page, across visits and refreshes.
local nodeFilter = { q = "", mapID = 0, off = {} }
local nodeSelected = {}
local MAX_NODE_ROWS = 250
local NODE_ROW_H = 30

local function NodeMatches(g)
    if nodeFilter.off[g.baseType] then return false end
    if nodeFilter.mapID ~= 0 and g.mapID ~= nodeFilter.mapID then return false end
    if nodeFilter.q ~= "" then
        local hay = (g.name .. " " .. g.zone):lower()
        if not hay:find(nodeFilter.q, 1, true) then return false end
    end
    return true
end

-- A toggle chip per resource type.
local function TypeChip(parent, nodeType)
    local chip = CreateFrame("Button", nil, parent)
    chip:SetHeight(28)
    Theme.Plate(chip, "panel2", "line", true)
    chip.dot = TypeDot(chip)
    chip.dot:SetPoint("LEFT", 10, 0)
    chip.dot:SetVertexColor(TypeColor(nodeType))
    chip.text = Text(chip, 12.5, "text")
    chip.text:SetPoint("LEFT", chip.dot, "RIGHT", 6, 0)
    chip.nodeType = nodeType
    local function Paint(self)
        local on = not nodeFilter.off[self.nodeType]
        Theme.PaintPlate(self, nil, on and "accentSoft" or "line")
        self:SetAlpha(on and 1 or 0.45)
    end
    Theme.Track(chip, Paint)
    chip.Paint = Paint
    chip:SetScript("OnClick", function(self)
        nodeFilter.off[self.nodeType] = not nodeFilter.off[self.nodeType] or nil
        OptionsWindow:Refresh()
    end)
    return chip
end

-- A tick box for the table.
local function TickBox(parent)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(18, 18)
    Theme.Plate(b, "bg", "line", true)
    b.tick = b:CreateTexture(nil, "OVERLAY")
    b.tick:SetPoint("TOPLEFT", 4, -4)
    b.tick:SetPoint("BOTTOMRIGHT", -4, 4)
    b.tick:SetTexture("Interface\\AddOns\\FarmMap\\Textures\\ui\\tag-fill")
    b.tick:SetTextureSliceMargins(4, 4, 4, 4)
    function b:SetOn(on)
        self.on = on
        self.tick:SetShown(on)
        self.tick:SetVertexColor(Theme.RGB("accent"))
        Theme.PaintPlate(self, nil, on and "accent" or "line")
    end
    return b
end

local function BuildNodeFilters(parent)
    local f = CreateFrame("Frame", nil, parent)
    f.search = Theme.SearchBox(f, L("UI_NODES_SEARCH"))
    f.search.onChange = function(text)
        nodeFilter.q = (text or ""):lower()
        OptionsWindow:Refresh()
    end
    f.zone = Theme.Dropdown(f)
    f.zone.minWidth = 220
    f.chips = {}
    for i, t in ipairs(ns.PREVIEW_TYPES or {}) do f.chips[i] = TypeChip(f, t) end
    return f
end

local function LayoutNodeFilters(f, width, groups)
    f.search:ClearAllPoints()
    f.search:SetPoint("TOPLEFT", 1, -1)
    f.search:SetWidth(math.min(320, width - 2))

    -- Zones that hold nodes, by name.
    local zones, seen = {}, {}
    for _, g in ipairs(groups) do
        if not seen[g.mapID] then
            seen[g.mapID] = true
            zones[#zones + 1] = { value = g.mapID, label = g.zone }
        end
    end
    table.sort(zones, function(a, b) return a.label < b.label end)
    table.insert(zones, 1, { value = 0, label = L("UI_NODES_ALL_ZONES") })
    if not seen[nodeFilter.mapID] then nodeFilter.mapID = 0 end
    f.zone:Bind(function() return nodeFilter.mapID end,
        function(v) nodeFilter.mapID = v OptionsWindow:Refresh() end, zones)
    f.zone:ClearAllPoints()
    local sameLine = width >= 600
    if sameLine then
        f.zone:SetPoint("LEFT", f.search, "RIGHT", 10, 0)
    else
        f.zone:SetPoint("TOPLEFT", f.search, "BOTTOMLEFT", 0, -8)
    end

    local y = (sameLine and 30 or 70) + 10
    local x = 1
    for _, chip in ipairs(f.chips) do
        chip.text:SetText(TypeName(chip.nodeType))
        local w = math.floor(chip.text:GetStringWidth() + 0.5) + 36
        if w % 2 == 1 then w = w + 1 end
        chip:SetWidth(w)
        if x + w > width then x, y = 1, y + 36 end
        chip:ClearAllPoints()
        chip:SetPoint("TOPLEFT", x, -y)
        chip:Paint()
        x = x + w + 8
    end
    return y + 36
end

-- "Where to find X": the zones of the matching lines, most harvested first.
local function BuildWhere(parent)
    local card = OptionsWindow.Card(parent)
    card.lines = {}
    return card
end

local function LayoutWhere(card, width, shown)
    local byZone, order = {}, {}
    for _, g in ipairs(shown) do
        local z = byZone[g.mapID]
        if not z then
            z = { zone = g.zone, harvests = 0, nodes = 0 }
            byZone[g.mapID] = z
            order[#order + 1] = z
        end
        z.harvests = z.harvests + g.harvests
        z.nodes = z.nodes + g.nodes
    end
    table.sort(order, function(a, b)
        if a.harvests ~= b.harvests then return a.harvests > b.harvests end
        return a.nodes > b.nodes
    end)
    local top = card:SetTexts(L("UI_NODES_WHERE"):format(nodeFilter.q), nil, width - 2) + 2
    for _, fs in ipairs(card.lines) do fs:Hide() end
    for i = 1, math.min(6, #order) do
        local fs = card.lines[i] or Text(card, 13, "text")
        card.lines[i] = fs
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", 14, -(top + (i - 1) * 24))
        fs:SetWidth(width - 30)
        local z = order[i]
        fs:SetText(L("UI_NODES_WHERE_LINE"):format(z.zone, z.harvests, z.nodes))
        fs:SetTextColor(Theme.RGB(i == 1 and "accent" or "text"))
        fs:Show()
    end
    local h = top + math.min(6, #order) * 24 + 10
    card:SetHeight(h)
    return h
end

-- The table: tick, item (with its type colour), zone, nodes, harvests.
local function BuildNodeTable(parent)
    local f = CreateFrame("Frame", nil, parent)
    f.all = TickBox(f)
    f.all:SetScript("OnClick", function(self)
        local on = not self.on
        for _, g in ipairs(f.shown or {}) do nodeSelected[g.key] = on or nil end
        OptionsWindow:Refresh()
    end)
    f.headers = {}
    for i = 1, 4 do
        f.headers[i] = Text(f, 12, "dim")
    end
    f.headers[3]:SetJustifyH("RIGHT")
    f.headers[4]:SetJustifyH("RIGHT")
    f.headRule = Theme.Rule(f, false, "line")
    f.rows = {}
    f.more = Text(f, 12.5, "faint")
    return f
end

local function NodeRow(parent)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(NODE_ROW_H)
    row.hi = row:CreateTexture(nil, "BACKGROUND")
    row.hi:SetAllPoints()
    row.hi:SetTexture(WHITE)
    row.hi:SetVertexColor(1, 1, 1, 0)
    row.tick = TickBox(row)
    row.tick:SetPoint("LEFT", 0, 0)
    row.tick:EnableMouse(false)          -- the whole row toggles
    row.dot = TypeDot(row)
    row.name = Text(row, 13, "text")
    row.zone = Text(row, 13, "dim")
    row.nodes = Text(row, 13, "text")
    row.nodes:SetJustifyH("RIGHT")
    row.harvests = Text(row, 13, "text")
    row.harvests:SetJustifyH("RIGHT")
    row.rule = Theme.Rule(row, false, "line")
    row.rule:SetPoint("BOTTOMLEFT")
    row.rule:SetPoint("BOTTOMRIGHT")
    row:SetScript("OnClick", function(self)
        nodeSelected[self.key] = not nodeSelected[self.key] or nil
        self.tick:SetOn(nodeSelected[self.key] == true)
        if parent.onSelect then parent.onSelect() end
    end)
    row:SetScript("OnEnter", function(self) self.hi:SetVertexColor(1, 1, 1, 0.04) end)
    row:SetScript("OnLeave", function(self) self.hi:SetVertexColor(1, 1, 1, 0) end)
    return row
end

local function LayoutNodeTable(f, width, shown)
    f.shown = shown
    local NUM_W = 90
    local nameW = math.floor((width - 30 - NUM_W * 2) * 0.55)
    local zoneW = width - 30 - NUM_W * 2 - nameW - 10
    local cols = { 30, 30 + nameW + 10, width - NUM_W * 2 - 4, width - NUM_W - 4 }
    local labels = { L("UI_NODES_COL_ITEM"), L("UI_NODES_COL_ZONE"),
                     L("UI_NODES_COL_NODES"), L("UI_NODES_COL_HARVESTS") }
    local widths = { nameW, zoneW, NUM_W, NUM_W }

    local allOn = #shown > 0
    for _, g in ipairs(shown) do if not nodeSelected[g.key] then allOn = false break end end
    f.all:ClearAllPoints()
    f.all:SetPoint("TOPLEFT", 1, -2)
    f.all:SetOn(allOn)
    for i, fs in ipairs(f.headers) do
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", cols[i], -4)
        fs:SetWidth(widths[i])
        fs:SetText(labels[i])
    end
    f.headRule:ClearAllPoints()
    f.headRule:SetPoint("TOPLEFT", 0, -26)
    f.headRule:SetPoint("TOPRIGHT", 0, -26)

    for _, row in ipairs(f.rows) do row:Hide() end
    local count = math.min(#shown, MAX_NODE_ROWS)
    for i = 1, count do
        local g = shown[i]
        local row = f.rows[i] or NodeRow(f)
        f.rows[i] = row
        Theme.CatchWheel(row, scroll)
        row.key = g.key
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 1, -(28 + (i - 1) * NODE_ROW_H))
        row:SetWidth(width - 2)
        row.tick:SetOn(nodeSelected[g.key] == true)
        row.dot:ClearAllPoints()
        row.dot:SetPoint("LEFT", cols[1] - 1, 0)
        row.dot:SetVertexColor(TypeColor(g.type))
        row.name:ClearAllPoints()
        row.name:SetPoint("LEFT", cols[1] + 15, 0)
        row.name:SetWidth(nameW - 16)
        row.name:SetText(g.name)
        row.zone:ClearAllPoints()
        row.zone:SetPoint("LEFT", cols[2] - 1, 0)
        row.zone:SetWidth(zoneW)
        row.zone:SetText(g.zone)
        row.nodes:ClearAllPoints()
        row.nodes:SetPoint("LEFT", cols[3] - 1, 0)
        row.nodes:SetWidth(NUM_W)
        row.nodes:SetText(tostring(g.nodes))
        row.harvests:ClearAllPoints()
        row.harvests:SetPoint("LEFT", cols[4] - 1, 0)
        row.harvests:SetWidth(NUM_W)
        row.harvests:SetText(tostring(g.harvests))
        row:Show()
    end
    local y = 28 + count * NODE_ROW_H
    f.more:ClearAllPoints()
    if #shown > count then
        f.more:SetPoint("TOPLEFT", 1, -(y + 8))
        f.more:SetText(L("UI_NODES_MORE"):format(#shown - count))
        f.more:Show()
        y = y + 30
    elseif #shown == 0 then
        f.more:SetPoint("TOPLEFT", 1, -(y + 8))
        f.more:SetText(L("UI_NODES_NONE"))
        f.more:Show()
        y = y + 30
    else
        f.more:Hide()
    end
    return y + 6
end

-- Collected once per layout and shared by the items below it.
local nodeGroups, nodeShown = {}, {}

ItemsPage({
    id = "nodes", titleKey = "UI_NODES", descKey = "UI_NODES_DESC", noSearch = true,
    items = function()
        nodeGroups = ns.CollectNodeGroups()
        table.sort(nodeGroups, function(a, b)
            if a.zone ~= b.zone then return a.zone < b.zone end
            return a.name < b.name
        end)
        nodeShown = {}
        local selected = {}
        for _, g in ipairs(nodeGroups) do
            if NodeMatches(g) then nodeShown[#nodeShown + 1] = g end
            if nodeSelected[g.key] then selected[#selected + 1] = g end
        end
        local deleteLabel = L("UI_NODES_DELETE"):format(#selected)
        return {
            { type = "custom", key = "filters", build = BuildNodeFilters,
              layout = function(f, width) return LayoutNodeFilters(f, width, nodeGroups) end },
            { type = "custom", key = "where", inset = true, gap = 12,
              visible = nodeFilter.q ~= "" and #nodeShown > 0,
              build = BuildWhere, layout = function(c, width) return LayoutWhere(c, width, nodeShown) end },
            { type = "custom", key = "table",
              build = function(parent)
                  local t = BuildNodeTable(parent)
                  -- A row toggles itself; the delete button's count follows.
                  t.onSelect = function() OptionsWindow:Refresh() end
                  return t
              end,
              layout = function(t, width) return LayoutNodeTable(t, width, nodeShown) end },
            { type = "button", key = "delete", visible = #selected > 0,
              name = L("UI_NODES_DELETE_NAME"), desc = L("UI_NODES_DELETE_DESC"), label = deleteLabel,
              onClick = function(row)
                  ArmOrRun(row, deleteLabel, function()
                      local removed = ns.DeleteNodeGroups(selected)
                      wipe(nodeSelected)
                      print("|cffffd100FarmMap :|r " .. L("UI_NODES_DELETED"):format(removed))
                      OptionsWindow:Refresh()
                  end)
              end },
        }
    end,
})

-- ============================================================
-- PAGE: IMPORT / EXPORT
-- ============================================================

-- importPlan: nodes waiting for confirmation; themePlan: a theme (the same
-- box takes both, told apart by the theme text's own tag).
local importPlan, importStatus, themePlan

local function BuildImportBox(parent)
    local card = OptionsWindow.Card(parent)
    -- The well first, the scrolling text above it: the other way round its
    -- plate would draw over what is pasted.
    card.well = CreateFrame("Frame", nil, card)
    Theme.Plate(card.well, "bg", "line", true)
    card.scroll, card.content = Theme.ScrollFrame(card)
    card.scroll:SetFrameLevel(card.well:GetFrameLevel() + 2)
    local eb = CreateFrame("EditBox", nil, card.content)
    eb:SetMultiLine(true)
    eb:SetMaxLetters(0)
    eb:SetAutoFocus(false)
    eb:SetTextInsets(4, 4, 4, 4)
    eb:SetPoint("TOPLEFT")
    eb:SetPoint("TOPRIGHT")
    Theme.Font(eb, 12, "text")
    eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    eb:SetScript("OnTextChanged", function(self)
        card.content:SetHeight(math.max(self:GetHeight(), 1))
    end)
    card.content:SetScript("OnMouseDown", function() eb:SetFocus() end)
    -- The wheel over the text scrolls the text, not the page.
    Theme.CatchWheel(eb, card.scroll)
    card.edit = eb
    card.analyse = Theme.ActionButton(card, L("UI_IMPORT_ANALYSE"), true)
    card.analyse:SetScript("OnClick", function()
        local text = eb:GetText()
        if Theme.LooksLikeTheme(text) then
            importPlan = nil
            themePlan = Theme.ParseThemeString(text)
            importStatus = (not themePlan) and ("|cffe05a4a" .. L("UI_THEME_IMPORT_BAD") .. "|r") or nil
        else
            themePlan = nil
            local plan, err = ns.ParseImport(text)
            importPlan = plan
            importStatus = (not plan) and ("|cffe05a4a" .. L("IMPORT_ERROR") .. " : " .. (err or "?") .. "|r") or nil
        end
        OptionsWindow:Refresh()
    end)
    card.clear = Theme.ActionButton(card, L("UI_IMPORT_CLEAR"))
    card.clear:SetScript("OnClick", function()
        eb:SetText("")
        importPlan, importStatus, themePlan = nil, nil, nil
        OptionsWindow:Refresh()
    end)
    return card
end

local function LayoutImportBox(card, width)
    local top = card:SetTexts(L("DB_IMPORT"), L("UI_IMPORT_PASTE"), width - 2)
    local BOX_H = 140
    card.well:ClearAllPoints()
    card.well:SetPoint("TOPLEFT", 14, -top)
    card.well:SetPoint("TOPRIGHT", -14, -top)
    card.well:SetHeight(BOX_H)
    card.scroll:ClearAllPoints()
    card.scroll:SetPoint("TOPLEFT", card.well, "TOPLEFT", 4, -4)
    card.scroll:SetPoint("BOTTOMRIGHT", card.well, "BOTTOMRIGHT", -14, 4)
    card.analyse:ClearAllPoints()
    card.analyse:SetPoint("TOPLEFT", card.well, "BOTTOMLEFT", 0, -10)
    card.clear:ClearAllPoints()
    card.clear:SetPoint("LEFT", card.analyse, "RIGHT", 10, 0)
    local h = top + BOX_H + 10 + 30 + 14
    card:SetHeight(h)
    return h
end

-- What the import will do, zone by zone, before anything is written.
local function BuildPreview(parent)
    local card = OptionsWindow.Card(parent)
    card.lines = {}
    card.go = Theme.ActionButton(card, "", true)
    card.go:SetScript("OnClick", function()
        if not importPlan then return end
        local added = ns.ApplyImport(importPlan)
        importStatus = "|cff4fd36a" .. L("UI_IMPORT_DONE"):format(added) .. "|r"
        importPlan = nil
        print("|cffffd100FarmMap :|r " .. L("IMPORT_DONE") .. added .. L("IMPORT_DONE2"))
        OptionsWindow:Refresh()
    end)
    card.cancel = Theme.ActionButton(card, L("UI_IMPORT_CANCEL"))
    card.cancel:SetScript("OnClick", function()
        importPlan, importStatus = nil, nil
        OptionsWindow:Refresh()
    end)
    return card
end

local function LayoutPreview(card, width)
    local p = importPlan
    local summary = L("UI_IMPORT_SUMMARY"):format(p.added, p.known)
    if p.invalid > 0 then summary = summary .. " " .. L("UI_IMPORT_INVALID"):format(p.invalid) end
    -- Another client's maps are not this one's: say so before anything is
    -- written (older exports do not name their client, so they cannot warn).
    if p.otherClient then
        local w = Theme.c.warn
        summary = summary .. ("\n\n|cff%02x%02x%02x%s|r"):format(math.floor(w[1] * 255 + 0.5),
            math.floor(w[2] * 255 + 0.5), math.floor(w[3] * 255 + 0.5),
            L("UI_IMPORT_OTHER_CLIENT"):format(p.sourceLabel or p.sourceKey or "?",
                ns.ClientLabel and ns.ClientLabel() or ""))
    end
    local top = card:SetTexts(L("UI_IMPORT_PREVIEW"), summary, width - 2) + 4
    for _, l in ipairs(card.lines) do l.zone:Hide() l.added:Hide() l.known:Hide() end
    local COL = 110
    local rows = math.min(#p.zones, 12)
    -- Header, then one line per zone.
    for i = 0, rows do
        local l = card.lines[i + 1]
        if not l then
            l = { zone = Text(card, 13, "text"), added = Text(card, 13, "text"), known = Text(card, 13, "dim") }
            l.added:SetJustifyH("RIGHT")
            l.known:SetJustifyH("RIGHT")
            card.lines[i + 1] = l
        end
        local y = top + i * 24
        l.zone:ClearAllPoints()
        l.zone:SetPoint("TOPLEFT", 14, -y)
        l.zone:SetWidth(width - 2 - 28 - COL * 2)
        l.added:ClearAllPoints()
        l.added:SetPoint("TOPRIGHT", -(14 + COL), -y)
        l.added:SetWidth(COL)
        l.known:ClearAllPoints()
        l.known:SetPoint("TOPRIGHT", -14, -y)
        l.known:SetWidth(COL)
        if i == 0 then
            l.zone:SetText(L("UI_NODES_COL_ZONE"))
            l.added:SetText(L("UI_IMPORT_COL_NEW"))
            l.known:SetText(L("UI_IMPORT_COL_KNOWN"))
            for _, fs in pairs(l) do fs:SetTextColor(Theme.RGB("dim")) end
        else
            local z = p.zones[i]
            l.zone:SetText(z.name)
            l.added:SetText(tostring(z.added))
            l.known:SetText(tostring(z.known))
            l.zone:SetTextColor(Theme.RGB("text"))
            l.added:SetTextColor(Theme.RGB(z.added > 0 and "accent" or "dim"))
            l.known:SetTextColor(Theme.RGB("dim"))
        end
        for _, fs in pairs(l) do fs:Show() end
    end
    local y = top + (rows + 1) * 24
    if #p.zones > rows then y = y + 4 end
    card.go:SetLabel(L("UI_IMPORT_GO"):format(p.added))
    card.go:SetEnabled(p.added > 0)
    card.go:SetAlpha(p.added > 0 and 1 or 0.45)
    card.go:ClearAllPoints()
    card.go:SetPoint("TOPLEFT", 14, -(y + 6))
    card.cancel:ClearAllPoints()
    card.cancel:SetPoint("LEFT", card.go, "RIGHT", 10, 0)
    local h = y + 6 + 30 + 14
    card:SetHeight(h)
    return h
end

-- A pasted theme, before it is added: its name, its colours, what it is.
local function HexToRGB(hex)
    return tonumber(hex:sub(2, 3), 16) / 255, tonumber(hex:sub(4, 5), 16) / 255,
           tonumber(hex:sub(6, 7), 16) / 255
end

local function BuildThemePreview(parent)
    local card = OptionsWindow.Card(parent)
    card.swatches = {}
    for i = 1, #Theme.COLOR_KEYS do
        local s = card:CreateTexture(nil, "ARTWORK")
        s:SetSize(26, 26)
        s:SetTexture("Interface\\AddOns\\FarmMap\\Textures\\ui\\tag-fill")
        s:SetTextureSliceMargins(4, 4, 4, 4)
        card.swatches[i] = s
    end
    card.go = Theme.ActionButton(card, L("UI_THEME_IMPORT_GO"), true)
    card.go:SetScript("OnClick", function()
        if not themePlan then return end
        local key = Theme.ImportTheme(themePlan)
        if key then
            Theme.Apply(key)
            importStatus = "|cff4fd36a" .. L("UI_THEME_IMPORT_DONE"):format(themePlan.label) .. "|r"
        end
        themePlan = nil
        OptionsWindow:Refresh()
    end)
    card.cancel = Theme.ActionButton(card, L("UI_IMPORT_CANCEL"))
    card.cancel:SetScript("OnClick", function()
        themePlan, importStatus = nil, nil
        OptionsWindow:Refresh()
    end)
    return card
end

local function LayoutThemePreview(card, width)
    local top = card:SetTexts(L("UI_THEME_IMPORT_TITLE"):format(themePlan.label),
        L("UI_THEME_IMPORT_DESC"), width - 2) + 4
    -- A colour the text leaves out is drawn with this client's default.
    for i, name in ipairs(Theme.COLOR_KEYS) do
        local s = card.swatches[i]
        local hex = themePlan.colors[name]
        if hex then s:SetVertexColor(HexToRGB(hex)) else s:SetVertexColor(Theme.RGB(name)) end
        s:ClearAllPoints()
        s:SetPoint("TOPLEFT", 14 + (i - 1) * 32, -top)
    end
    card.go:ClearAllPoints()
    card.go:SetPoint("TOPLEFT", 14, -(top + 26 + 14))
    card.cancel:ClearAllPoints()
    card.cancel:SetPoint("LEFT", card.go, "RIGHT", 10, 0)
    local h = top + 26 + 14 + 30 + 14
    card:SetHeight(h)
    return h
end

ItemsPage({
    id = "io", titleKey = "UI_IO", descKey = "UI_IO_DESC",
    items = function()
        return {
            { type = "button", key = "export", name = L("DB_EXPORT"), desc = L("UI_EXPORT_DESC"),
              label = L("DB_EXPORT"), onClick = function() ns.OpenExportPopup() end, gap = 4 },
            -- Themes travel through the same box: export the active one here,
            -- paste one below.
            { type = "button", key = "exportTheme", name = L("UI_THEME_EXPORT_ROW"),
              desc = L("UI_THEME_EXPORT_DESC"), label = L("UI_THEME_EXPORT"),
              onClick = function() ExportTheme(Theme.CurrentKey()) end, gap = 12 },
            { type = "custom", key = "importBox", inset = true, gap = 12,
              build = BuildImportBox, layout = LayoutImportBox },
            { type = "hint", key = "importStatus", visible = importStatus ~= nil, text = importStatus },
            { type = "custom", key = "preview", inset = true, visible = importPlan ~= nil,
              build = BuildPreview, layout = LayoutPreview },
            { type = "custom", key = "themePreview", inset = true, visible = themePlan ~= nil,
              build = BuildThemePreview, layout = LayoutThemePreview },
        }
    end,
})

-- ============================================================
-- PAGE: DEBUG
-- ============================================================

-- Clearing goes through ArmOrRun (see the dashboard): a second click within
-- a few seconds. The legacy button clears on one click.
ItemsPage({
    id = "debug", titleKey = "UI_DEBUG", descKey = "UI_DEBUG_DESC",
    items = function()
        return {
            { type = "switch", key = "showDebug",
              name = L("UI_DEBUG_WINDOW"), desc = L("UI_DEBUG_WINDOW_DESC"),
              get = DB("showDebug"), set = function(on) ns.SetDebugShown(on) end },
            { type = "switch", key = "debugCapture",
              name = L("UI_DEBUG_CAPTURE"), desc = L("UI_DEBUG_CAPTURE_DESC"),
              get = DB("debugCapture"), set = function(on) ns.SetDebugCapture(on) end },

            { type = "section", key = "db", text = L("DB_SECTION") },
            { type = "button", key = "migrate", name = L("UI_DB_MIGRATE"), desc = L("UI_DB_MIGRATE_DESC"),
              label = L("UI_DB_MIGRATE"), onClick = function() ns.ManualMigration() end },
            { type = "button", key = "clear", name = L("DB_CLEAR"), desc = L("UI_DB_CLEAR_DESC"),
              label = L("DB_CLEAR"),
              onClick = function(row)
                  ArmOrRun(row, L("DB_CLEAR"), function()
                      ns.ClearNodeDatabase()
                      print("|cffffd100FarmMap :|r " .. L("DB_CLEARED"))
                  end)
              end },
        }
    end,
})

-- ============================================================
-- PAGE: LANGUAGE
-- ============================================================

-- Built from lang\*.lua: dropping a language file in is enough. Each
-- language is written in its own script, with the font that can draw it.
local function LanguageChoices()
    local out = { { value = "auto", label = L("LANG_AUTO") } }
    for _, entry in ipairs(ns.GetAvailableLocales and ns.GetAvailableLocales() or {}) do
        out[#out + 1] = {
            value = entry.code,
            label = ns.GetLocaleLabel and ns.GetLocaleLabel(entry.data) or entry.code,
            font  = Theme.FontPath(entry.code),
        }
    end
    return out
end

-- Same key as the legacy panel (FarmMapDB.language, "auto" or a locale
-- code). The language is applied at login, hence the reload notice while
-- the choice differs from the one this session runs in.
local function LanguageChanged()
    return (FarmMapDB.language or "auto") ~= (ns.languageAtLogin or "auto")
end

-- Translations come as files, on the Discord or on GitHub: the CurseForge
-- localization page is no longer used (Kroosstii, 2026-10-09).
local GITHUB_URL = "https://github.com/Kroosstiich/FarmMap"

OptionsWindow:AddPage({
    id = "lang", group = "settings", titleKey = "UI_LANG", descKey = "UI_LANG_DESC",
    -- The rail's search: the setting, and each language by its own name.
    SearchText = function()
        local parts = { L("UI_LANG_CHOICE"), L("UI_LANG_CHOICE_DESC"), L("UI_LANG_HELP_TITLE") }
        for _, choice in ipairs(LanguageChoices()) do parts[#parts + 1] = choice.label end
        return table.concat(parts, " ")
    end,
    Build = function(frame)
        frame.choice = Theme.ChoiceRow(frame)
        frame.choice.dropdown.minWidth = 300
        frame.notice = ReloadNotice(frame)
        frame.help = OptionsWindow.Card(frame)
        frame.helpCurse = Theme.ActionButton(frame.help, "GitHub")
        frame.helpCurse:SetScript("OnClick", function() ShowLink(GITHUB_URL) end)
        frame.helpDiscord = Theme.ActionButton(frame.help, "Discord")
        frame.helpDiscord:SetScript("OnClick", function() ShowLink(LINKS[1].url) end)
    end,
    Layout = function(frame, width)
        local row = frame.choice
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, 0)
        row:SetWidth(width)
        row:SetContent(L("UI_LANG_CHOICE"), L("UI_LANG_CHOICE_DESC"), width)
        row:Bind(
            function() return FarmMapDB.language or "auto" end,
            function(value)
                FarmMapDB.language = value
                OptionsWindow:Refresh()
            end,
            LanguageChoices())
        local y = row:GetHeight() + 12
        y = frame.notice:Place(y, width, LanguageChanged(), L("LANG_RELOAD_PLAIN"))

        local help = frame.help
        help:ClearAllPoints()
        help:SetPoint("TOPLEFT", 1, -y)
        help:SetWidth(width - 2)
        local top = help:SetTexts(L("UI_LANG_HELP_TITLE"), L("UI_LANG_HELP"), width - 2)
        frame.helpCurse:ClearAllPoints()
        frame.helpCurse:SetPoint("TOPLEFT", 14, -top - 2)
        frame.helpDiscord:ClearAllPoints()
        frame.helpDiscord:SetPoint("LEFT", frame.helpCurse, "RIGHT", 10, 0)
        help:SetHeight(top + 30 + 14)
        return y + help:GetHeight() + 2
    end,
})

-- ============================================================
-- PAGES STILL TO COME (placeholders, in rail order)
-- ============================================================

-- Reading pages first, then the settings in the order of the mock-up.
-- AddPage keeps the order of the calls, so "credits" and "theme" above are
-- moved into place here.
local ORDER = {
    { "news",    "top",      "UI_NEWS",    "UI_NEWS_DESC"    },
    { "credits" },
    { "dash",    "settings", "UI_DASH",    "UI_DASH_DESC"    },
    { "nodes",   "settings", "UI_NODES",   "UI_NODES_DESC"   },
    { "icons",   "settings", "UI_ICONS",   "UI_ICONS_DESC"   },
    { "theme" },
    { "display", "settings", "UI_DISPLAY", "UI_DISPLAY_DESC" },
    { "integ",   "settings", "UI_INTEG",   "UI_INTEG_DESC"   },
    { "io",      "settings", "UI_IO",      "UI_IO_DESC"      },
    { "lang",    "settings", "UI_LANG",    "UI_LANG_DESC"    },
    { "debug",   "settings", "UI_DEBUG",   "UI_DEBUG_DESC"   },
}
wipe(pageOrder)
for _, entry in ipairs(ORDER) do
    if not pages[entry[1]] then SoonPage(entry[1], entry[2], entry[3], entry[4]) end
    if not tContains(pageOrder, entry[1]) then pageOrder[#pageOrder + 1] = entry[1] end
end
