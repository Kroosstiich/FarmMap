-- ============================================================
--  FarmMap — changelog: the "What's new" page and window
--
--  Each release is one file per language, changelog\vX.Y.Z\<locale>.lua,
--  written once and never edited after the release. A file fills
--  ns.changelog["X.Y.Z"] = { date = "...", <locale> = { sections } }.
--  A language without its own file falls back to English.
--
--  What is shown (Kroosstii's rule):
--    - the CURRENT SERIES, newest first: every X.Y.* up to the installed
--      version, so at 2.0.1 the player reads 2.0.1 above 2.0.0;
--    - releases of other series the player skipped since their last visit,
--      under "Also since your last visit";
--    - older series only behind "Show older changelogs".
--  The window opens once per new version, at login.
-- ============================================================

local _, ns = ...

local Theme = ns.Theme
local OptionsWindow = ns.OptionsWindow
local Changelog = {}
ns.Changelog = Changelog
ns.changelog = ns.changelog or {}

local function L(key) return ns.L[key] or key end

-- ---- versions -------------------------------------------------------------

local function Parse(v)
    local a, b, c = tostring(v or ""):match("(%d+)%.(%d+)%.(%d+)")
    return tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0
end

local function Newer(x, y)
    local a1, b1, c1 = Parse(x)
    local a2, b2, c2 = Parse(y)
    if a1 ~= a2 then return a1 > a2 end
    if b1 ~= b2 then return b1 > b2 end
    return c1 > c2
end

local function Current()
    local a, b, c = Parse(ns.version)
    return ("%d.%d.%d"):format(a, b, c)
end

-- Every release up to the installed one, newest first.
local function Releases()
    local list = {}
    local current = Current()
    for version in pairs(ns.changelog) do
        if not Newer(version, current) then list[#list + 1] = version end
    end
    table.sort(list, Newer)
    return list
end

-- Splits the releases into the current series, the ones skipped since
-- `lastSeen` (other series only), and the rest.
function Changelog.Groups(lastSeen)
    local ca, cb = Parse(Current())
    local series, skipped, older = {}, {}, {}
    for _, version in ipairs(Releases()) do
        local a, b = Parse(version)
        if a == ca and b == cb then
            series[#series + 1] = version
        elseif lastSeen and Newer(version, lastSeen) then
            skipped[#skipped + 1] = version
        else
            older[#older + 1] = version
        end
    end
    return series, skipped, older
end

-- A release in the player's language, English otherwise. The third value
-- says the English text stands in for a missing translation.
local function Sections(version)
    local rel = ns.changelog[version] or {}
    local lang = ns.ActiveLocale and ns.ActiveLocale()
    if rel[lang] then return rel[lang], rel.date, false end
    return rel.enUS or {}, rel.date, lang ~= "enUS"
end

-- ---- drawing --------------------------------------------------------------

-- Colours say what a change IS: the accent for what is new, amber for what
-- moved, green for what was repaired, red for what was taken away.
local KINDS = {
    new     = { key = "UI_CL_NEW",     color = "accent", heading = 13.5, module = 13.5, text = 12.5, gap = 10, rule = true },
    change  = { key = "UI_CL_CHANGED", color = "warn",   heading = 12.5, module = 13,   text = 12.5, gap = 9 },
    fix     = { key = "UI_CL_FIXED",   color = "good",   heading = 12,   module = 12.5, text = 12,   gap = 7 },
    removed = { key = "UI_CL_REMOVED", color = "bad",    heading = 12,   module = 12.5, text = 12,   gap = 7 },
}

-- Pooled text and rules per container: frames cannot be freed, so a page
-- drawn again reuses what it drew last time.
local function Pool(container)
    container.clPool = container.clPool or { texts = {}, rules = {}, tags = {}, t = 0, r = 0, g = 0 }
    local p = container.clPool
    for i = 1, p.t do p.texts[i]:Hide() end
    for i = 1, p.r do p.rules[i]:Hide() end
    for i = 1, p.g do p.tags[i]:Hide() end
    p.t, p.r, p.g = 0, 0, 0
    return p
end

-- The small rounded labels of the mock-up: a section's kind, "unread",
-- "in English". Drawn with the tag textures made for exactly this.
local function NextTag(container, p, text, colorName)
    p.g = p.g + 1
    local tag = p.tags[p.g]
    if not tag then
        tag = Theme.Tag(container)
        p.tags[p.g] = tag
    end
    tag:SetTag(text, colorName)
    tag:ClearAllPoints()
    tag:Show()
    return tag
end

local function NextText(container, p, size, colorName)
    p.t = p.t + 1
    local fs = p.texts[p.t]
    if not fs then
        fs = container:CreateFontString(nil, "OVERLAY")
        fs:SetJustifyH("LEFT")
        fs:SetWordWrap(true)
        p.texts[p.t] = fs
    end
    Theme.Font(fs, size, colorName)
    fs:ClearAllPoints()
    fs:Show()
    return fs
end

local function NextRule(container, p)
    p.r = p.r + 1
    local rule = p.rules[p.r]
    if not rule then
        rule = container:CreateTexture(nil, "ARTWORK")
        rule:SetTexture("Interface\\Buttons\\WHITE8X8")
        PixelUtil.SetHeight(rule, 1, 1)
        p.rules[p.r] = rule
    end
    rule:ClearAllPoints()
    rule:Show()
    return rule
end

-- Draws releases from y down; returns the y below them. `heading` is an
-- optional label above the group ("Also since your last visit"); a release
-- newer than `lastSeen` carries an "unread" tag.
local function DrawReleases(container, p, versions, width, y, heading, lastSeen)
    if #versions == 0 then return y end
    if heading then
        local h = NextText(container, p, 12.5, "dim")
        h:SetPoint("TOPLEFT", 0, -y)
        h:SetWidth(width)
        h:SetText(heading:upper())
        y = y + math.floor(h:GetStringHeight() + 0.5) + 12
    end
    for _, version in ipairs(versions) do
        local sections, date, inEnglish = Sections(version)
        -- Version, then its tags and date on the same line.
        local title = NextText(container, p, 18, "text")
        title:SetPoint("TOPLEFT", 0, -y)
        title:SetText("v" .. version)
        local anchor, gap = title, 12
        local function Beside(widget)
            widget:SetPoint("LEFT", anchor, "RIGHT", gap, 0)
            anchor, gap = widget, 8
        end
        if lastSeen ~= false and (not lastSeen or Newer(version, lastSeen)) then
            Beside(NextTag(container, p, L("UI_CL_UNREAD"), "accent"))
        end
        if inEnglish then Beside(NextTag(container, p, L("UI_CL_IN_ENGLISH"), "warn")) end
        if date then
            local d = NextText(container, p, 12, "faint")
            -- "9 octobre 2026" rather than "09/10/2026", in the player's language.
            d:SetText(ns.Intl.Date(date))
            Beside(d)
        end
        y = y + math.floor(title:GetStringHeight() + 0.5) + 14

        for _, section in ipairs(sections) do
            local kind = KINDS[section.kind] or KINDS.change
            local tag = NextTag(container, p, L(kind.key), kind.color)
            tag:SetPoint("TOPLEFT", 0, -y)
            y = y + 22 + 6
            if kind.rule then
                local rule = NextRule(container, p)
                rule:SetPoint("TOPLEFT", 0, -y)
                rule:SetWidth(width)
                rule:SetVertexColor(Theme.RGBA(kind.color, 0.3))
                y = y + 9
            else
                y = y + 3
            end
            for _, entry in ipairs(section.entries or {}) do
                local module = NextText(container, p, kind.module, "text")
                module:SetPoint("TOPLEFT", 14, -y)
                module:SetWidth(width - 14)
                module:SetText(entry.module or "")
                y = y + math.floor(module:GetStringHeight() + 0.5) + 2
                local text = NextText(container, p, kind.text, "dim")
                text:SetPoint("TOPLEFT", 14, -y)
                text:SetWidth(width - 14)
                text:SetText(entry.text or "")
                y = y + math.floor(text:GetStringHeight() + 0.5) + kind.gap
            end
            y = y + 8
        end
        y = y + 18
    end
    return y
end

-- Draws what a visit shows: the series, the skipped releases, and the older
-- ones when `showOlder`. Returns the height and whether older ones exist.
-- `markUnread` false: no "unread" tags (the options page, read at will).
function Changelog.Draw(container, width, lastSeen, showOlder, markUnread)
    local p = Pool(container)
    local series, skipped, older = Changelog.Groups(lastSeen)
    -- Not "(markUnread == false) and false or lastSeen": a false in the
    -- middle of and/or falls through to the or, so the page showed
    -- "unread" tags (seen on Era, 2026-10-08).
    local seen = lastSeen
    if markUnread == false then seen = false end
    local y = DrawReleases(container, p, series, width, 0, nil, seen)
    y = DrawReleases(container, p, skipped, width, y, L("UI_CL_SKIPPED"), seen)
    if showOlder then
        y = DrawReleases(container, p, older, width, y, L("UI_CL_OLDER"), false)
    end
    return y, #older > 0
end

-- ---- the "What's new" page ------------------------------------------------

OptionsWindow:AddPage({
    id = "news", group = "top", titleKey = "UI_NEWS", descKey = "UI_NEWS_DESC",
    Build = function(frame)
        frame.body = CreateFrame("Frame", nil, frame)
        frame.older = Theme.ActionButton(frame, L("UI_CL_SHOW_OLDER"))
        frame.older:SetScript("OnClick", function()
            frame.showOlder = not frame.showOlder
            OptionsWindow:Refresh()
        end)
    end,
    Layout = function(frame, width)
        frame.body:ClearAllPoints()
        frame.body:SetPoint("TOPLEFT")
        frame.body:SetWidth(width)
        -- The page always shows everything since the last visit, as the
        -- window did; nothing is marked as read from here.
        local y, hasOlder = Changelog.Draw(frame.body, width - 8, FarmMapDB.changelogPrevious,
            frame.showOlder, false)
        frame.body:SetHeight(math.max(1, y))
        frame.older:SetShown(hasOlder)
        if hasOlder then
            frame.older:SetLabel(L(frame.showOlder and "UI_CL_HIDE_OLDER" or "UI_CL_SHOW_OLDER"))
            frame.older:ClearAllPoints()
            frame.older:SetPoint("TOPLEFT", 1, -(y + 4))
            y = y + 40
        end
        return y
    end,
})

-- ---- the window, once per new version ------------------------------------

local window

local function CreateWindow()
    if window then return window end
    window = CreateFrame("Frame", "FarmMapChangelogWindow", UIParent)
    Theme.ScaledWindow(window)
    window:SetSize(700, 580)
    window:SetPoint("CENTER")
    window:SetFrameStrata("HIGH")
    window:SetToplevel(true)
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    window:SetMovable(true)
    tinsert(UISpecialFrames, "FarmMapChangelogWindow")
    Theme.Plate(window, "bg", "line")

    -- Same bands as the options window: rounded on the window's edge, at a
    -- whole-pixel inset, the window itself snapped to pixels.
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
    title:SetText("FarmMap · " .. L("UI_NEWS"))
    local close = Theme.GlyphButton(bar, "\195\151", 26)
    close:SetPoint("RIGHT", -8, 0)
    close:SetScript("OnClick", function() window:Hide() end)

    local intro = Theme.Font(window:CreateFontString(nil, "OVERLAY"), 13, "dim")
    intro:SetPoint("TOPLEFT", 18, -52)
    intro:SetPoint("RIGHT", -18, 0)
    intro:SetJustifyH("LEFT")
    intro:SetText(L("UI_CL_INTRO"):format(ns.version or ""))

    local footer = CreateFrame("Frame", nil, window)
    Theme.InsetBand(footer, window, "BOTTOM", 3)
    footer:SetHeight(54)
    footer.bg = Theme.Band(footer, "panel", "BOTTOM")

    local closeBtn = Theme.ActionButton(footer, L("CLOSE"), true)
    closeBtn.minWidth = 100
    closeBtn:SetLabel(L("CLOSE"))
    closeBtn:SetPoint("RIGHT", -14, 0)
    closeBtn:SetScript("OnClick", function() window:Hide() end)

    local options = Theme.ActionButton(footer, L("UI_CL_OPEN_OPTIONS"))
    options:SetPoint("LEFT", 14, 0)
    options:SetScript("OnClick", function()
        window:Hide()
        OptionsWindow:Toggle("news")
    end)

    window.scroll, window.content = Theme.ScrollFrame(window)
    window.scroll:SetPoint("TOPLEFT", 18, -80)
    window.scroll:SetPoint("BOTTOMRIGHT", -28, 64)
    window:Hide()
    return window
end

function Changelog.Show(lastSeen)
    Theme.Reload()
    local w = CreateWindow()
    w:Show()
    w.scroll:SetVerticalScroll(0)
    -- The scroll child takes its width from the frame on the next layout;
    -- the frame's own width is known now.
    local width = math.floor(700 - 18 - 28 - 8)
    local height = Changelog.Draw(w.content, width, lastSeen, false)
    w.content:SetHeight(math.max(1, height))
end

-- ---- once per new version ------------------------------------------------

-- A brand new install has nothing to catch up on: no node and no harvest
-- recorded means the version is marked as seen without opening anything.
local function IsNewInstall()
    for key, nodes in pairs(FarmMapDB) do
        if type(key) == "number" and type(nodes) == "table" and #nodes > 0 then return false end
    end
    local counts = FarmMapStatsDB and FarmMapStatsDB.counts
    return not (counts and next(counts))
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    local current = Current()
    local seen = FarmMapDB.changelogSeen
    if seen == current then return end
    -- The page keeps showing what this visit brought until the next version.
    FarmMapDB.changelogPrevious = seen
    FarmMapDB.changelogSeen = current
    if seen == nil and IsNewInstall() then return end
    if not ns.changelog[current] then return end
    -- After the login burst of chat and frames, so it is not lost under them,
    -- and after the setup assistant when it has screens to show: never both.
    C_Timer.After(4, function()
        local function show() Changelog.Show(seen) end
        if ns.Setup then ns.Setup.After(show) else show() end
    end)
end)
