-- ============================================================
--  FarmMap — small session window
--
--  The dashboard's numbers (duration, nodes, and with Auctionator or TSM
--  value and gold per hour) in
--  a small movable window, to keep an eye on a farm without opening the
--  options. Switched on from the dashboard page; remembered with its
--  position in FarmMapDB.sessionWindow. Kroosstii's idea (2026-10-08).
--
--  Same theme as the options window, and the same numbers: both read
--  ns.OptionsWindow.SessionNumbers().
-- ============================================================

local _, ns = ...

local Theme = ns.Theme
local SessionWindow = {}
ns.SessionWindow = SessionWindow

local W, ROW_H = 250, 24
local LINES = {
    { key = "UI_DASH_TIME"  },
    { key = "UI_DASH_NODES" },
    { key = "UI_DASH_VALUE" },
    { key = "UI_DASH_GPH"   },
}

local frame

local function L(key) return ns.L[key] or key end

local function Saved()
    FarmMapDB.sessionWindow = FarmMapDB.sessionWindow or {}
    return FarmMapDB.sessionWindow
end

local function SavePosition()
    local point, _, relPoint, x, y = frame:GetPoint(1)
    Saved().pos = { point, relPoint, math.floor(x + 0.5), math.floor(y + 0.5) }
end

local function Create()
    if frame then return frame end
    frame = CreateFrame("Frame", "FarmMapSessionWindow", UIParent)
    frame:SetSize(W, 38 + #LINES * ROW_H + 8)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
    end)
    Theme.Plate(frame, "bg", "line")

    frame.title = Theme.Font(frame:CreateFontString(nil, "OVERLAY"), 13, "accent")
    frame.title:SetPoint("TOPLEFT", 12, -10)
    frame.title:SetText("FarmMap · " .. L("UI_DASH_SESSION"))

    -- Closing it is the same as unticking it in the dashboard.
    local close = Theme.GlyphButton(frame, "\195\151", 20)
    close:SetPoint("TOPRIGHT", -6, -6)
    close:SetScript("OnClick", function() SessionWindow:SetEnabled(false) end)

    local rule = Theme.Rule(frame, false, "line")
    rule:SetPoint("TOPLEFT", 10, -32)
    rule:SetPoint("TOPRIGHT", -10, -32)

    frame.rows, frame.labels = {}, {}
    for i, line in ipairs(LINES) do
        local label = Theme.Font(frame:CreateFontString(nil, "OVERLAY"), 12.5, "dim")
        label:SetPoint("TOPLEFT", 12, -(38 + (i - 1) * ROW_H))
        label:SetText(L(line.key))
        local value = Theme.Font(frame:CreateFontString(nil, "OVERLAY"), 13.5, i == 4 and "accent" or "text")
        value:SetPoint("TOPRIGHT", -12, -(38 + (i - 1) * ROW_H))
        value:SetJustifyH("RIGHT")
        frame.rows[i], frame.labels[i] = value, label
    end

    -- The route's guidance in one click (2.2), with TomTom or WaypointUI:
    -- on, the route is shown too. Placed under the numbers in Update.
    frame.guide = Theme.ActionButton(frame, "")
    frame.guide:SetHeight(24)
    frame.guide.tipTitle = L("UI_ROUTE_GUIDE")
    frame.guide.tipBody = L("SESSION_GUIDE_TIP")
    frame.guide:SetScript("OnClick", function()
        if ns.Route then ns.Route.Guide(not ns.Route.IsGuiding()) end
    end)
    -- Under it, half and half: the route's direction, and another route.
    frame.dir = Theme.ActionButton(frame, "")
    frame.dir:SetHeight(24)
    frame.dir.tipTitle = L("UI_ROUTE_DIR")
    frame.dir.tipBody = L("SESSION_DIR_TIP")
    frame.dir:SetScript("OnClick", function() if ns.Route then ns.Route.Reverse() end end)
    frame.newRoute = Theme.ActionButton(frame, L("ROUTE_NEW_LABEL"))
    frame.newRoute:SetHeight(24)
    frame.newRoute.tipTitle = L("UI_ROUTE_NEW")
    frame.newRoute.tipBody = L("SESSION_NEW_TIP")
    frame.newRoute:SetScript("OnClick", function() if ns.Route then ns.Route.NewRoute() end end)

    local pos = Saved().pos
    if pos then
        frame:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
    else
        frame:SetPoint("RIGHT", UIParent, "RIGHT", -60, 120)
    end

    -- Duration and rates move with time: re-read every 5 seconds.
    local since = 0
    frame:SetScript("OnUpdate", function(_, elapsed)
        since = since + elapsed
        if since >= 5 then
            since = 0
            SessionWindow:Update()
        end
    end)
    return frame
end

function SessionWindow:Update()
    if not (frame and frame:IsShown() and ns.OptionsWindow) then return end
    local OW = ns.OptionsWindow
    local n = OW.SessionNumbers()
    local nodes = ns.Intl.Number(n.nodes)
    if n.perHour then nodes = nodes .. "  (" .. L("UI_DASH_PER_HOUR"):format(n.perHour) .. ")" end
    frame.rows[1]:SetText(OW.Duration(n.elapsed))
    frame.rows[2]:SetText(nodes)
    -- Value and gold per hour only with Auctionator or TSM: without them
    -- there is nothing to show, and the window keeps its two lines.
    local priced = ns.HasPriceSource()
    for i = 3, 4 do
        frame.rows[i]:SetShown(priced)
        frame.labels[i]:SetShown(priced)
    end
    local height = 38 + (priced and #LINES or 2) * ROW_H + 8
    -- The guidance button, only when there is something to guide with.
    local canGuide = ns.Route and (ns.IsTomTomLoaded() or ns.IsWaypointUILoaded())
    frame.guide:SetShown(canGuide and true or false)
    if canGuide then
        local on = ns.Route.IsGuiding()
        frame.guide:SetLabel(L(on and "SESSION_GUIDE_ON" or "SESSION_GUIDE_OFF"))
        frame.guide:ClearAllPoints()
        frame.guide:SetPoint("TOPLEFT", 10, -(height - 2))
        frame.guide:SetPoint("TOPRIGHT", -10, -(height - 2))
        frame.guide.text:SetTextColor(Theme.RGB(on and "accent" or "dim"))
        height = height + 24 + 8
    end
    -- Direction and another route: the route works without a navigation
    -- addon, so these two are always there.
    local hasRoute = ns.Route ~= nil
    frame.dir:SetShown(hasRoute)
    frame.newRoute:SetShown(hasRoute)
    if hasRoute then
        local half = math.floor((W - 20 - 6) / 2)
        frame.dir:SetLabel(L(FarmMapDB.routeReverse and "ROUTE_CCW" or "ROUTE_CW"))
        frame.dir:ClearAllPoints()
        frame.dir:SetPoint("TOPLEFT", 10, -(height - 2))
        frame.dir:SetWidth(half)
        frame.newRoute:ClearAllPoints()
        frame.newRoute:SetPoint("TOPRIGHT", -10, -(height - 2))
        frame.newRoute:SetWidth(half)
        height = height + 24 + 8
    end
    frame:SetHeight(height)
    -- A plain "-": the em dash is missing from the Korean client's font.
    frame.rows[3]:SetText(n.value and OW.Money(n.value) or "-")
    frame.rows[4]:SetText(n.gph and OW.Money(n.gph) or "-")
end

function SessionWindow:IsEnabled()
    return FarmMapDB and FarmMapDB.sessionWindow and FarmMapDB.sessionWindow.shown == true or false
end

function SessionWindow:SetEnabled(on)
    Saved().shown = on and true or nil
    if on then
        Theme.Reload()
        Create():Show()
        self:Update()
    elseif frame then
        frame:Hide()
    end
    -- The dashboard's switch follows a close from the window itself.
    if ns.OptionsWindow then ns.OptionsWindow:Refresh() end
end

-- After a harvest, alongside the options window's own refresh.
local previous = ns.OnDataChanged
ns.OnDataChanged = function()
    if previous then previous() end
    SessionWindow:Update()
end

-- Shown again at login when it was left open.
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    if SessionWindow:IsEnabled() then
        Theme.Reload()
        Create():Show()
        SessionWindow:Update()
    end
end)
