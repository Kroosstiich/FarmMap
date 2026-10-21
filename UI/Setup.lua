-- ============================================================
--  FarmMap — setup assistant
--  One setting per screen: what it does, what happens with it on and
--  with it off, and the player picks. Every player sees it once; after an
--  update, only the screens added since (FarmMapDB.setupSeen holds the ids
--  already answered). "/fm setup" runs every screen again.
--  The settings themselves are the options pages' items (same get/set),
--  so a choice made here has exactly the effect it has in the options.
-- ============================================================

local _, ns = ...
local Theme = ns.Theme
local OptionsWindow = ns.OptionsWindow
local Setup = {}
ns.Setup = Setup

local function L(key) return ns.L[key] or key end

local W, H = 620, 620
local PAD = 18
local WIDTH = W - PAD - 28 - 8   -- the content's width, as in the What's new window

-- The theme is not an item of a page (the Theme page draws cards), so the
-- assistant offers it as a list.
local function ThemeItem()
    return {
        type = "choice", key = "setupTheme", name = L("UI_THEME"),
        choices = function()
            local out = {}
            for _, def in ipairs(Theme.Themes()) do out[#out + 1] = { value = def.key, label = def.label } end
            return out
        end,
        get = Theme.CurrentKey,
        set = function(key)
            Theme.Apply(key)
            OptionsWindow:Refresh()
        end,
    }
end

-- id: saved once answered, never rename one. text: the texts' key part
-- (SETUP_<text>_TITLE / _TEXT, and _ON / _OFF for a switch). page + key:
-- the options item it asks about; extra: items drawn under it; when: the
-- screen only applies while this is true; demo: the little scene that
-- plays the selected answer. A new screen added in a later version is
-- shown on its own to the players who already went through.
local STEPS = {
    -- A thank-you and where to get help; its own buttons (never again,
    -- stop for now, continue). Seen once, then only with /fm setup.
    { id = "welcome", text = "WELCOME", welcome = true },
    -- Then the icons: they are what every other screen's scene shows.
    { id = "styles", text = "STYLES", page = "icons", key = "styleColumns", demo = "style" },
    { id = "minimapPins", text = "MINIMAP_PINS", page = "icons", key = "showMinimapPins", demo = "pins" },
    { id = "hideNearby", text = "HIDE_NEARBY", page = "icons", key = "hideNearbyMinimapPins",
      extra = { "nearbyMinimapPinRadius" }, demo = "nearby",
      when = function() return FarmMapDB.showMinimapPins ~= false end },
    { id = "minimapButton", text = "MINIMAP_BUTTON", page = "icons", key = "minimapButton", demo = "button" },
    { id = "floatingText", text = "FLOAT", page = "display", key = "showFloatingText", demo = "float" },
    { id = "profit", text = "PROFIT", page = "integ", key = "showProfit", extra = { "priceSource" },
      demo = "profit",
      when = function() return ns.HasPriceSource() and FarmMapDB.showFloatingText end },
    { id = "waypoint", text = "WAYPOINT", page = "integ", key = "waypointClick", extra = { "waypointAddon" },
      demo = "waypoint",
      when = function() return ns.IsTomTomLoaded() or ns.IsWaypointUILoaded() end },
    -- 2.2: shown on its own to the players who went through in 2.1.
    { id = "routeGuide", text = "ROUTE_GUIDE", page = "integ", key = "routeGuide",
      when = function() return ns.IsTomTomLoaded() or ns.IsWaypointUILoaded() end },
    { id = "theme", text = "THEME", item = ThemeItem },
}

local window, queue, index, after
local Go   -- defined after Draw, which calls it

local function Item(step)
    if step.item then return step.item() end
    return OptionsWindow.FindItem(step.page, step.key)
end

local function Applies(step)
    if step.welcome then return true end
    local item = Item(step)
    return item ~= nil and item.visible ~= false and (not step.when or step.when())
end

-- The next (dir 1) or previous (dir -1) screen that applies, from `from`.
local function Step(from, dir)
    local i = from + dir
    while queue[i] do
        if Applies(queue[i]) then return i end
        i = i + dir
    end
end

-- ---- the demo scene --------------------------------------------------------
--
-- A small minimap drawn by the assistant (a disc, the player arrow, a few
-- pins in the minimap style) or a floating text, looping what the selected
-- answer does. Positions are pixels from the disc's centre.

-- The disc is laid out at 130 px and drawn bigger: positions stay simple.
local DISC, DISC_SCALE = 130, 1.6
local DEMO_H = DISC * DISC_SCALE + 16
local DISC_TEX = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"   -- a white disc
local ARROW_TEX = "Interface\\Minimap\\MinimapArrow"
local DEMO_PINS = { { -35, 28 }, { 18, 38 }, { 42, -4 }, { -12, -32 }, { 30, -36 },
                    { -46, -10 }, { -20, 6 }, { 14, -8 } }
local YD_TO_PX = 0.25   -- 50 yd = 12 px: the whole disc is about 260 yd across

local function Disc(parent, size, color, alpha, layer)
    local t = parent:CreateTexture(nil, layer or "BACKGROUND")
    t:SetTexture(DISC_TEX)
    t:SetSize(size, size)
    Theme.Track(t, function(self) self:SetVertexColor(Theme.RGBA(color, alpha or 1)) end)
    return t
end

local function BuildDemo(parent)
    local d = CreateFrame("Frame", nil, parent)
    d:SetHeight(DEMO_H)

    d.map = CreateFrame("Frame", nil, d)
    d.map:SetSize(DISC, DISC)
    d.map:SetScale(DISC_SCALE)
    d.map:SetPoint("CENTER")
    Disc(d.map, DISC + 4, "line"):SetPoint("CENTER")
    Disc(d.map, DISC, "panel2", 1, "BORDER"):SetPoint("CENTER")
    d.zone = Disc(d.map, 10, "accent", 0.18, "ARTWORK")

    d.pins = {}
    for i in ipairs(DEMO_PINS) do
        d.pins[i] = d.map:CreateTexture(nil, "OVERLAY")
        d.pins[i]:SetSize(14, 14)
    end
    d.ring = Disc(d.map, 22, "accent", 0.6, "ARTWORK")
    d.line = d.map:CreateLine(nil, "ARTWORK")
    d.line:SetThickness(2)
    Theme.Track(d.line, function(self) self:SetColorTexture(Theme.RGBA("accent", 0.9)) end)
    d.arrow = d.map:CreateTexture(nil, "OVERLAY", nil, 7)
    d.arrow:SetTexture(ARROW_TEX)
    d.arrow:SetSize(18, 18)
    d.button = d.map:CreateTexture(nil, "OVERLAY")
    d.button:SetTexture("Interface\\AddOns\\FarmMap\\Textures\\icon")
    d.button:SetSize(26, 26)
    d.button:SetPoint("CENTER", d.map, "CENTER", 48, 48)

    -- The floating text, as FarmMap writes it after a harvest (one line:
    -- name, quantity, bag total in grey, then the value in coins).
    d.float = d:CreateFontString(nil, "OVERLAY")

    d.t = 0
    d:SetScript("OnUpdate", function(self, elapsed)
        self.t = self.t + elapsed
        self:Play()
    end)

    -- One frame of the loop, for the screen's kind and the selected answer.
    function d:Play()
        local kind, on, t = self.kind, self.get() and true or false, self.t
        local arrowX, arrowY = 0, 0
        local onDisc = kind ~= "float" and kind ~= "profit"
        self.map:SetShown(onDisc)
        self.float:SetShown(not onDisc)
        if not onDisc then
            -- Rises 40 px and fades out, as the real one, every 4 s.
            local p = (t % 4) / 4
            local shown = kind == "profit" or on
            self.float:SetAlpha(shown and (1 - p * p) or 0)
            self.float:ClearAllPoints()
            self.float:SetPoint("CENTER", self, "CENTER", 0, -20 + p * 40)
            self.float:SetText(self.floatLine .. ((kind == "profit" and on) and self.floatCoins or ""))
            return
        end

        if kind == "nearby" then
            -- Back and forth across the disc in 8 s, facing where it goes.
            local p = (t % 8) / 8
            arrowX = (p < 0.5 and (p * 4 - 1) or (3 - p * 4)) * 44
            self.arrow:SetRotation(p < 0.5 and -math.pi / 2 or math.pi / 2)
        else
            self.arrow:SetRotation(0)
        end
        self.arrow:ClearAllPoints()
        self.arrow:SetPoint("CENTER", self.map, "CENTER", arrowX, arrowY)

        local radius = (FarmMapDB.nearbyMinimapPinRadius or 50) * YD_TO_PX
        self.zone:SetShown(kind == "nearby" and on)
        self.zone:SetSize(radius * 2, radius * 2)
        self.zone:ClearAllPoints()
        self.zone:SetPoint("CENTER", self.map, "CENTER", arrowX, arrowY)

        for i, pin in ipairs(self.pins) do
            local x, y = DEMO_PINS[i][1], DEMO_PINS[i][2]
            local alpha = 1
            if kind == "pins" then
                -- One after the other, then all stay until the loop restarts.
                alpha = on and math.min(1, math.max(0, (t % 5) * 3 - i * 0.6)) or 0
            elseif kind == "nearby" and on then
                local dist = math.sqrt((x - arrowX) ^ 2 + (y - arrowY) ^ 2)
                alpha = dist <= radius and 0 or 1
            end
            pin:SetAlpha(alpha)
        end

        self.button:SetShown(kind == "button" and on)

        -- A pin is clicked (its ring pulses); turned on, a line then joins
        -- it to the arrow until the loop restarts.
        local target = self.pins[2]
        local p = t % 4
        local clicked = kind == "waypoint" and p > 0.8
        self.ring:SetShown(clicked and (on or p < 1.4))
        if clicked then
            local s = p < 1.4 and (22 + (p - 0.8) * 30) or 22
            self.ring:SetSize(s, s)
            self.ring:ClearAllPoints()
            self.ring:SetPoint("CENTER", target, "CENTER")
        end
        local guided = kind == "waypoint" and on and p > 1.2
        self.line:SetShown(guided)
        if guided then
            self.line:SetStartPoint("CENTER", self.map, arrowX, arrowY)
            self.line:SetEndPoint("CENTER", self.map, DEMO_PINS[2][1], DEMO_PINS[2][2])
        end
    end

    -- New screen: the pins take the minimap style's icons.
    function d:Start(kind, get)
        self.kind, self.get, self.t = kind, get, 0
        local style = ns.GetStyle and ns.GetStyle("minimapStyle")
        local types = ns.PREVIEW_TYPES or {}
        for i, pin in ipairs(self.pins) do
            local nodeType = types[(i - 1) % math.max(1, #types) + 1]
            pin:ClearAllPoints()
            pin:SetPoint("CENTER", self.map, "CENTER", DEMO_PINS[i][1], DEMO_PINS[i][2])
            if nodeType and ns.PreviewIcon then ns.PreviewIcon(pin, style, nodeType) end
        end
        -- Peacebloom exists on every client; its name only once the game
        -- has it cached, the herbalism label until then.
        local fontSize = math.floor(13 * (FarmMapDB.floatSize or 1))
        self.float:SetFont(ns.LOCALE_FONTS[GetLocale()] or STANDARD_TEXT_FONT, fontSize, "OUTLINE")
        local name = ((C_Item and C_Item.GetItemInfo) or GetItemInfo)(2447) or L("TYPE_Herbo")
        self.floatLine = name .. "  x3  |cffaaaaaa(27)|r"
        local coin = ":" .. fontSize .. ":" .. fontSize .. ":2:0|t  "
        self.floatCoins = "  1|TInterface\\MoneyFrame\\UI-GoldIcon" .. coin
            .. "23|TInterface\\MoneyFrame\\UI-SilverIcon" .. coin
            .. "40|TInterface\\MoneyFrame\\UI-CopperIcon" .. coin
        self:Play()
        self:Show()
    end
    d:Hide()   -- no screen yet: Play needs a kind
    return d
end

-- ---- the window ----------------------------------------------------------

-- One of the two big answers of a switch screen: a title and what follows.
local function AnswerCard(parent)
    local card = CreateFrame("Button", nil, parent)
    Theme.Plate(card, "panel", "line")
    card.title = Theme.Font(card:CreateFontString(nil, "OVERLAY"), 14, "text")
    card.title:SetPoint("TOPLEFT", 14, -12)
    card.title:SetJustifyH("LEFT")
    card.text = Theme.Font(card:CreateFontString(nil, "OVERLAY"), 12.5, "dim")
    card.text:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -8)
    card.text:SetJustifyH("LEFT")
    local function Paint(self)
        Theme.PaintPlate(self, self.selected and "panel2" or nil, self.selected and "accent" or nil)
        self.title:SetTextColor(Theme.RGBA(self.selected and "accent" or "text", 1))
    end
    Theme.Track(card, Paint)
    card:SetScript("OnEnter", function(self)
        if not self.selected then Theme.PaintPlate(self, nil, "accentSoft") end
    end)
    card:SetScript("OnLeave", Paint)
    card.Paint = Paint
    return card
end

local function Draw()
    local step = queue[index]
    local item = Item(step)
    local c = window.content
    local prefix = "SETUP_" .. step.text
    local y = 0

    c.title:SetText(L(prefix .. "_TITLE"))
    c.title:SetPoint("TOPLEFT", 0, 0)
    y = y + math.floor(c.title:GetStringHeight() + 0.5) + 10
    c.body:SetWidth(WIDTH)
    c.body:SetText(L(prefix .. "_TEXT"))
    c.body:SetPoint("TOPLEFT", 0, -y)
    y = y + math.floor(c.body:GetStringHeight() + 0.5) + 18

    local items = {}
    if step.welcome then
        for _, card in ipairs(c.cards) do card:Hide() end
        items[1] = { type = "button", key = "setupDiscord", name = "Discord",
                     label = L("SETUP_WELCOME_DISCORD"),
                     onClick = function() OptionsWindow.ShowLink(OptionsWindow.DISCORD_URL) end }
    elseif item.type == "switch" then
        -- Clients other than Retail may track a single kind of gathering at
        -- a time: a screen can say so in a text of its own.
        local onKey = prefix .. "_ON"
        if not ns.IS_RETAIL and ns.L[onKey .. "_CLASSIC"] then onKey = onKey .. "_CLASSIC" end
        local on = item.get() and true or false
        local cardW = math.floor((WIDTH - 12) / 2)
        local tallest = 0
        for i, card in ipairs(c.cards) do
            local value = i == 1
            card.title:SetText(L(value and "SETUP_ON" or "SETUP_OFF"))
            card.text:SetWidth(cardW - 28)
            card.text:SetText(L(value and onKey or prefix .. "_OFF"))
            tallest = math.max(tallest, 12 + card.title:GetStringHeight() + 8 + card.text:GetStringHeight() + 14)
            card.selected = value == on
            card:Paint()
            card:SetScript("OnClick", function()
                item.set(value)
                Draw()
            end)
            card:ClearAllPoints()
            card:SetPoint("TOPLEFT", (i - 1) * (cardW + 12), -y)
            card:SetWidth(cardW)
            card:Show()
        end
        tallest = math.floor(tallest + 0.5)
        for _, card in ipairs(c.cards) do card:SetHeight(tallest) end
        y = y + tallest + 16
        for _, key in ipairs(step.extra or {}) do
            items[#items + 1] = OptionsWindow.FindItem(step.page, key)
        end
    else
        for _, card in ipairs(c.cards) do card:Hide() end
        items[1] = item
    end

    -- The scene plays the selected answer; a screen without an on/off
    -- answer (the icon styles) shows its setting as it is.
    if step.demo then
        c.demo:ClearAllPoints()
        c.demo:SetPoint("TOPLEFT", 0, -y)
        c.demo:SetWidth(WIDTH)
        c.demo:Start(step.demo, item.type == "switch" and item.get or function() return true end)
        y = y + DEMO_H + 12
    else
        c.demo:Hide()
    end

    c.items:ClearAllPoints()
    c.items:SetPoint("TOPLEFT", 0, -y)
    c.items:SetWidth(WIDTH)
    local h = OptionsWindow.LayoutItems(c.items, items, WIDTH, window.scroll)
    c.items:SetHeight(math.max(1, h))
    c:SetHeight(y + h)

    -- Where this screen stands among the settings that apply right now (an
    -- earlier answer can add or remove one: no value, no value screen).
    local pos, total = 0, 0
    for i, s in ipairs(queue) do
        if Applies(s) and not s.welcome then
            total = total + 1
            if i <= index then pos = pos + 1 end
        end
    end
    window.counter:SetText(step.welcome and "" or L("SETUP_STEP"):format(pos, total))

    -- The welcome page's three answers, in the slots of Skip, Back, Next.
    local skip, prev, nextBtn = window.skip, window.prev, window.next
    if step.welcome then
        skip:SetLabel(L("SETUP_NEVER"))
        skip.tipTitle, skip.tipBody = L("SETUP_NEVER"), L("SETUP_NEVER_TIP")
        skip:SetScript("OnClick", function()
            FarmMapDB.setupDisabled = true
            window:Hide()
        end)
        prev:SetLabel(L("SETUP_STOP"))
        prev.tipTitle, prev.tipBody = L("SETUP_STOP"), L("SETUP_STOP_TIP")
        prev:SetScript("OnClick", function() window:Hide() end)
        prev:Show()
        nextBtn:SetLabel(L("SETUP_CONTINUE"))
    else
        skip:SetLabel(L("SETUP_SKIP"))
        skip.tipTitle, skip.tipBody = nil, nil
        skip:SetScript("OnClick", function() window:Hide() end)
        prev:SetLabel(L("SETUP_PREV"))
        prev.tipTitle, prev.tipBody = nil, nil
        prev:SetScript("OnClick", function() Go(-1) end)
        prev:SetShown(Step(index, -1) ~= nil)
        nextBtn:SetLabel(L(Step(index, 1) and "SETUP_NEXT" or "SETUP_DONE"))
    end
end

function Go(dir)
    local i = Step(index, dir)
    if i then
        index = i
        window.scroll:SetVerticalScroll(0)
        Draw()
    elseif dir > 0 then
        window:Hide()
    end
end

local function CreateWindow()
    if window then return window end
    window = CreateFrame("Frame", "FarmMapSetupWindow", UIParent)
    Theme.ScaledWindow(window)
    window:SetSize(W, H)
    window:SetPoint("CENTER")
    window:SetFrameStrata("HIGH")
    window:SetToplevel(true)
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    window:SetMovable(true)
    tinsert(UISpecialFrames, "FarmMapSetupWindow")
    Theme.Plate(window, "bg", "line")

    local bar = CreateFrame("Frame", nil, window)
    Theme.InsetBand(bar, window, "TOP", 3)
    bar:SetHeight(36)
    bar.bg = Theme.Band(bar, "panel2", "TOP")
    bar:EnableMouse(true)
    bar:RegisterForDrag("LeftButton")
    bar:SetScript("OnDragStart", function() window:StartMoving() end)
    bar:SetScript("OnDragStop", function()
        window:StopMovingOrSizing()
        Theme.SnapToPixels(window)
    end)
    window:HookScript("OnShow", function(self) Theme.SnapToPixels(self) end)
    local title = Theme.Font(bar:CreateFontString(nil, "OVERLAY"), 14, "accent")
    title:SetPoint("LEFT", 12, 0)
    title:SetText("FarmMap · " .. L("SETUP_TITLE"))
    window.counter = Theme.Font(bar:CreateFontString(nil, "OVERLAY"), 12.5, "dim")
    window.counter:SetPoint("LEFT", title, "RIGHT", 12, 0)
    local close = Theme.GlyphButton(bar, "\195\151", 26)
    close:SetPoint("RIGHT", -8, 0)
    close:SetScript("OnClick", function() window:Hide() end)

    local footer = CreateFrame("Frame", nil, window)
    Theme.InsetBand(footer, window, "BOTTOM", 3)
    footer:SetHeight(54)
    footer.bg = Theme.Band(footer, "panel", "BOTTOM")

    window.next = Theme.ActionButton(footer, L("SETUP_NEXT"), true)
    window.next.minWidth = 110
    window.next:SetPoint("RIGHT", -14, 0)
    window.next:SetScript("OnClick", function() Go(1) end)
    window.prev = Theme.ActionButton(footer, L("SETUP_PREV"))
    window.prev.minWidth = 110
    window.prev:SetLabel(L("SETUP_PREV"))
    window.prev:SetPoint("RIGHT", window.next, "LEFT", -10, 0)
    window.prev:SetScript("OnClick", function() Go(-1) end)
    window.skip = Theme.ActionButton(footer, L("SETUP_SKIP"))
    window.skip:SetPoint("LEFT", 14, 0)
    window.skip:SetScript("OnClick", function() window:Hide() end)

    local hint = Theme.Font(window:CreateFontString(nil, "OVERLAY"), 12, "faint")
    hint:SetPoint("BOTTOMLEFT", footer, "TOPLEFT", PAD, 8)
    hint:SetPoint("RIGHT", window, "RIGHT", -PAD, 0)
    hint:SetJustifyH("LEFT")
    hint:SetText(L("SETUP_HINT"))

    window.scroll, window.content = Theme.ScrollFrame(window)
    window.scroll:SetPoint("TOPLEFT", PAD, -56)
    window.scroll:SetPoint("BOTTOMRIGHT", -28, 94)
    local c = window.content
    c:SetWidth(WIDTH)
    c.title = Theme.Font(c:CreateFontString(nil, "OVERLAY"), 17, "accent")
    c.title:SetJustifyH("LEFT")
    c.body = Theme.Font(c:CreateFontString(nil, "OVERLAY"), 13, "text")
    c.body:SetJustifyH("LEFT")
    c.cards = { AnswerCard(c), AnswerCard(c) }
    c.demo = BuildDemo(c)
    c.items = CreateFrame("Frame", nil, c)
    c.items.rows = {}

    -- Hidden before OnHide is set: this first Hide is not a close.
    window:Hide()
    -- Closed by Done, Skip, the cross or Escape: the screens that applied
    -- are answered, whatever was picked (the settings keep their value).
    window:SetScript("OnHide", function()
        FarmMapDB.setupSeen = FarmMapDB.setupSeen or {}
        for _, step in ipairs(queue or {}) do
            if Applies(step) then FarmMapDB.setupSeen[step.id] = true end
        end
        queue = nil
        local fn = after
        after = nil
        if fn then fn() end
    end)
    return window
end

-- A setting changed elsewhere (a style row, a theme, a switch that greys
-- another) refreshes the options window: the assistant follows.
hooksecurefunc(OptionsWindow, "Refresh", function()
    if window and window:IsShown() and queue then Draw() end
end)

-- Opens the assistant on the screens not answered yet (all: every one).
-- Returns false when there is nothing to show.
function Setup.Show(all)
    if window and window:IsShown() then return true end
    -- "Never show again": only /fm setup opens it.
    if not all and FarmMapDB.setupDisabled then return false end
    local seen = FarmMapDB.setupSeen or {}
    queue = {}
    local settings = 0
    for _, step in ipairs(STEPS) do
        if all or not seen[step.id] then
            queue[#queue + 1] = step
            if not step.welcome and Applies(step) then settings = settings + 1 end
        end
    end
    index = Step(0, 1)
    -- A welcome page alone, with no setting after it, is not worth opening.
    if not index or settings == 0 then
        queue = nil
        return false
    end
    Theme.Reload()
    CreateWindow()
    window:Show()
    window.scroll:SetVerticalScroll(0)
    Draw()
    return true
end

-- Runs fn once the assistant is closed, or right away when it has nothing
-- to show: the What's new window waits for it.
function Setup.After(fn)
    if (window and window:IsShown()) or Setup.Show() then
        after = fn
    else
        fn()
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    -- With the What's new window: after the login burst of chat and frames.
    C_Timer.After(4, function() Setup.Show() end)
end)
