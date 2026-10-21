-- ============================================================
--  FarmMap — interface theme
--
--  The look of FarmMap's own options window, drawn by the addon itself:
--  no Blizzard frame template, so the window looks the same on Retail,
--  WoW: Forever and every Classic client. Adapted from the theme of
--  Kroos_AchievementOverhaul (same author), whose window it follows.
--
--  THEMES CHANGE COLOURS AND NOTHING ELSE. Sizes, spacing, fonts and
--  layout are fixed here and no theme can reach them - a theme that could
--  move things could also break the window. Icons belong to icon packs.
--
--  Every control registers how to repaint itself (Track), so switching
--  theme recolours the open window in place: frames cannot be destroyed
--  in WoW, rebuilding them would leave a generation behind each time.
-- ============================================================

local _, ns = ...

local Theme = {}
ns.Theme = Theme

local WHITE   = "Interface\\Buttons\\WHITE8X8"
local UI_PATH = "Interface\\AddOns\\FarmMap\\Textures\\ui\\"

-- ============================================================
-- PALETTES
-- ============================================================

-- The colours a theme may set, and only these. Anything else in a theme
-- definition is ignored.
local COLOR_KEYS = {
    "bg",          -- window ground
    "panel",       -- cards, rail, footer
    "panel2",      -- second level: title bar, inputs, hovered rows
    "line",        -- borders and dividers
    "accent",      -- titles, selection, the one colour that says FarmMap
    "accentSoft",  -- accent at rest: scroll thumb, quiet borders
    "text",
    "dim",         -- secondary text
    "faint",       -- tertiary text, placeholders
    "good", "warn", "bad",
}

-- Surfaces that may blend into a second colour, top to bottom (2.2). The
-- second colour sits next to the theme's own under "<name>To" (bgTo...);
-- without it the surface stays flat. Small plates (buttons, inputs, tags)
-- stay flat whatever the theme: only the big surfaces blend.
local GRADIENT_KEYS = { "bg", "panel", "panel2" }

-- Semantic colours shared by the built-in themes: they say what a thing IS
-- (detected, changed, missing), not that it is FarmMap.
local SEMANTIC = { good = "#4fd36a", warn = "#e0a040", bad = "#e05a4a" }

local BUILTIN = {
    {
        key = "retail", label = "Retail",
        colors = { bg = "#0e1116", panel = "#161b22", panel2 = "#1e2530", line = "#2e3846",
                   accent = "#6cb6ff", accentSoft = "#2f5f8f",
                   text = "#e3e9f0", dim = "#8b98a8", faint = "#5c6878" },
    },
    {
        key = "forever", label = "Forever",
        colors = { bg = "#12100d", panel = "#1d1a15", panel2 = "#262119", line = "#3d3426",
                   accent = "#ffd100", accentSoft = "#8a6d2a",
                   text = "#e8e2d4", dim = "#9a917f", faint = "#6d6555" },
    },
    {
        key = "emerald", label = "Emerald",
        colors = { bg = "#0d1310", panel = "#141c17", panel2 = "#1b261f", line = "#2c3d31",
                   accent = "#7ee2a0", accentSoft = "#2f6b45",
                   text = "#e2eee6", dim = "#8fa597", faint = "#5e7266" },
    },
    -- Goes with the Sakura icons drawn by SorelDesign (credited, with her
    -- site). Night under the cherry trees: plum-black grounds that keep the
    -- text readable, sakura pink accent, and its own state colours from the
    -- same scene (young leaf, lantern, torii) instead of the shared ones.
    {
        key = "sakura", label = "Sakura", author = "SorelDesign", url = "https://soreldesign.fr",
        colors = { bg = "#1b1418", panel = "#241a20", panel2 = "#2f2229", line = "#4a3541",
                   accent = "#f2a7c3", accentSoft = "#9c5b77",
                   text = "#f6eaf0", dim = "#bfa3b1", faint = "#84697a",
                   good = "#9ad4a0", warn = "#eab676", bad = "#e2574c" },
    },
}

-- Each client opens on its own theme until the player picks one: Retail
-- blue, Forever and Era brown-gold, MoP emerald (chosen by Kroosstii).
local function ClientDefault()
    if ns.IS_RETAIL then return "retail" end
    if ns.IS_CLASSIC and not ns.IS_CLASSIC_ERA
       and LE_EXPANSION_LEVEL_CURRENT and LE_EXPANSION_LEVEL_CURRENT >= 4 then
        return "emerald"
    end
    return "forever"
end

local function ParseColor(value)
    if type(value) == "table" then
        local r, g, b = tonumber(value[1]), tonumber(value[2]), tonumber(value[3])
        if r and g and b then return { r, g, b } end
        return nil
    end
    if type(value) ~= "string" then return nil end
    local hex = value:match("^#?(%x%x%x%x%x%x)$")
    if not hex then return nil end
    return { tonumber(hex:sub(1, 2), 16) / 255,
             tonumber(hex:sub(3, 4), 16) / 255,
             tonumber(hex:sub(5, 6), 16) / 255 }
end

local themes, themeOrder = {}, {}

-- Registers a theme. Used for the built-in ones and exposed to other addons
-- as FarmMapThemes.Register. Only the keys of COLOR_KEYS are read; a colour
-- left out or unreadable falls back to the client's default theme, so a
-- partial theme still draws a complete window. Returns true on success.
local function Register(key, def)
    if type(key) ~= "string" or key == "" or type(def) ~= "table"
       or type(def.colors) ~= "table" then
        return false
    end
    local colors = {}
    for _, name in ipairs(COLOR_KEYS) do
        colors[name] = ParseColor(def.colors[name])
    end
    for _, name in ipairs(GRADIENT_KEYS) do
        colors[name .. "To"] = ParseColor(def.colors[name .. "To"])
    end
    if not themes[key] then themeOrder[#themeOrder + 1] = key end
    themes[key] = {
        key    = key,
        label  = type(def.label) == "string" and def.label or key,
        author = type(def.author) == "string" and def.author or nil,
        -- Optional: the author's site, offered to copy from the theme card
        -- (FarmMap_Sakura credits its artist this way).
        url    = type(def.url) == "string" and def.url or nil,
        colors = colors,
    }
    return true
end

for _, def in ipairs(BUILTIN) do
    local colors = {}
    for k, v in pairs(def.colors) do colors[k] = v end
    -- Shared state colours, unless the theme brings its own (Sakura).
    for k, v in pairs(SEMANTIC) do colors[k] = colors[k] or v end
    Register(def.key, { label = def.label, author = def.author or "FarmMap",
                        url = def.url, colors = colors })
end

-- Public API for theme addons: colours only, by design.
FarmMapThemes = {
    Register = Register,
    -- Keys of every registered theme, built-in ones first.
    List = function()
        local out = {}
        for i, key in ipairs(themeOrder) do out[i] = key end
        return out
    end,
}

-- The active colours, as { r, g, b } tables. Read through Theme.c at paint
-- time, never captured: a theme switch replaces them. Theme.g holds the
-- bottom colour of the surfaces the active theme blends (nil: flat).
Theme.c = {}
Theme.g = {}
Theme.GRADIENT_KEYS = GRADIENT_KEYS

function Theme.Themes()
    local out = {}
    for _, key in ipairs(themeOrder) do out[#out + 1] = themes[key] end
    return out
end

function Theme.CurrentKey()
    local saved = FarmMapDB and FarmMapDB.uiTheme
    if saved and themes[saved] then return saved end
    return ClientDefault()
end

-- ============================================================
-- REPAINT REGISTRY
-- ============================================================

-- Weak keys: an entry never keeps a widget alive on its own.
local painters = setmetatable({}, { __mode = "k" })

-- Registers how an object repaints itself, and paints it once right away.
function Theme.Track(obj, fn)
    painters[obj] = fn
    fn(obj)
    return obj
end

local function ResolveColors()
    local active   = themes[Theme.CurrentKey()]
    local fallback = themes[ClientDefault()]
    for _, name in ipairs(COLOR_KEYS) do
        Theme.c[name] = (active and active.colors[name]) or fallback.colors[name]
    end
    -- A gradient is the theme's own: never borrowed from the fallback.
    for _, name in ipairs(GRADIENT_KEYS) do
        Theme.g[name] = active and active.colors[name .. "To"] or nil
    end
end

-- Re-reads the saved choice and repaints, without saving anything. This
-- file runs before the SavedVariables are loaded, so the window calls it
-- when it opens.
function Theme.Reload()
    ResolveColors()
    for obj, fn in pairs(painters) do fn(obj) end
end

-- The player picked a theme: saved, then painted everywhere at once.
function Theme.Apply(key)
    if FarmMapDB then FarmMapDB.uiTheme = key end
    Theme.Reload()
end

-- ============================================================
-- THE PLAYER'S OWN THEMES
--
-- Made in the Theme page (a copy of any theme, then its colours changed
-- one by one) or imported from a text another player shared. Saved in
-- FarmMapDB.userThemes with the other settings - no file is written:
--   { { id = 3, label = "My theme 1", colors = { bg = "#0e1116", ... } } }
-- Registered like any theme under the key "user:<id>", and colours only,
-- like every theme.
-- ============================================================

Theme.COLOR_KEYS = COLOR_KEYS

local USER_PREFIX = "user:"

function Theme.IsUser(key)
    return type(key) == "string" and key:sub(1, #USER_PREFIX) == USER_PREFIX
end

local function ToHex(c)
    return ("#%02x%02x%02x"):format(math.floor(c[1] * 255 + 0.5),
        math.floor(c[2] * 255 + 0.5), math.floor(c[3] * 255 + 0.5))
end

local function UserEntry(key)
    if not (FarmMapDB and FarmMapDB.userThemes and Theme.IsUser(key)) then return nil end
    local id = tonumber(key:sub(#USER_PREFIX + 1))
    for i, entry in ipairs(FarmMapDB.userThemes) do
        if entry.id == id then return entry, i end
    end
end

local function RegisterUser(entry)
    Register(USER_PREFIX .. entry.id, { label = entry.label, colors = entry.colors })
    themes[USER_PREFIX .. entry.id].user = true
end

-- Labels are shown and exported: one line, no separator of the export
-- format, a sane length.
local function CleanLabel(label)
    label = tostring(label or ""):gsub("[%c;]", " "):gsub("^%s+", ""):gsub("%s+$", "")
    -- 40 bytes, without cutting an accented letter in half (UTF-8).
    if #label > 40 then label = label:sub(1, 40):gsub("[\192-\255][\128-\191]*$", "") end
    return label
end

-- Every colour a theme ends up drawing with: its own, or the client
-- default's where it leaves one out.
local function FullColors(key)
    local def, fallback = themes[key], themes[ClientDefault()]
    local out = {}
    for _, name in ipairs(COLOR_KEYS) do
        out[name] = ToHex((def and def.colors[name]) or fallback.colors[name])
    end
    for _, name in ipairs(GRADIENT_KEYS) do
        local to = def and def.colors[name .. "To"]
        if to then out[name .. "To"] = ToHex(to) end
    end
    return out
end

local function NewUser(label, colors)
    FarmMapDB.userThemes = FarmMapDB.userThemes or {}
    local id = (FarmMapDB.userThemeNext or 1)
    FarmMapDB.userThemeNext = id + 1
    local entry = { id = id, label = CleanLabel(label), colors = colors }
    if entry.label == "" then entry.label = "#" .. id end
    table.insert(FarmMapDB.userThemes, entry)
    RegisterUser(entry)
    return USER_PREFIX .. id
end

-- A copy of any theme, to be edited. Returns its key.
function Theme.CreateUserTheme(fromKey, label)
    if not FarmMapDB then return nil end
    return NewUser(label, FullColors(fromKey or Theme.CurrentKey()))
end

-- One colour of one of the player's themes. Repaints at once when it is
-- the theme on screen, so the window previews the change live.
function Theme.SetUserColor(key, name, r, g, b)
    local entry = UserEntry(key)
    if not entry then return end
    entry.colors[name] = ToHex({ r, g, b })
    themes[key].colors[name] = { r, g, b }
    if key == Theme.CurrentKey() then Theme.Reload() end
end

-- Turns a surface's gradient on or off in one of the player's themes. On,
-- the bottom colour starts as a darker shade of the surface's own, for the
-- player to change; off, the surface is flat again.
function Theme.SetUserGradient(key, name, on)
    local entry = UserEntry(key)
    if not entry then return end
    local to = name .. "To"
    local value
    if on then
        local c = themes[key].colors[name] or Theme.c[name]
        value = { c[1] * 0.6, c[2] * 0.6, c[3] * 0.6 }
    end
    entry.colors[to] = value and ToHex(value) or nil
    themes[key].colors[to] = value
    if key == Theme.CurrentKey() then Theme.Reload() end
end

function Theme.RenameUserTheme(key, label)
    local entry = UserEntry(key)
    label = CleanLabel(label)
    if not entry or label == "" then return end
    entry.label = label
    themes[key].label = label
end

-- Removes one of the player's themes; the window falls back to the
-- client's default when it was the active one.
function Theme.DeleteUserTheme(key)
    local entry, index = UserEntry(key)
    if not entry then return end
    table.remove(FarmMapDB.userThemes, index)
    themes[key] = nil
    for i, k in ipairs(themeOrder) do
        if k == key then table.remove(themeOrder, i) break end
    end
    if FarmMapDB.uiTheme == key then FarmMapDB.uiTheme = nil end
    Theme.Reload()
end

-- ---- Sharing as text ----
-- One line: FMTHEME1;<name>;bg:0e1116;panel:161b22;...
-- Read with string patterns only, never run as code: a shared text can
-- carry a name and colours, nothing else. Gradients ride along as bgTo:...
-- fields: FarmMap before 2.2 skips fields it does not know, so it still
-- reads such a text (flat), and the tag stays FMTHEME1.
local EXPORT_TAG = "FMTHEME1"

function Theme.ExportTheme(key)
    local def = themes[key]
    if not def then return nil end
    local parts = { EXPORT_TAG, CleanLabel(def.label) }
    local colors = FullColors(key)
    for _, name in ipairs(COLOR_KEYS) do
        parts[#parts + 1] = name .. ":" .. colors[name]:sub(2)
    end
    for _, name in ipairs(GRADIENT_KEYS) do
        local to = colors[name .. "To"]
        if to then parts[#parts + 1] = name .. "To:" .. to:sub(2) end
    end
    return table.concat(parts, ";")
end

-- Whether a pasted text is a theme at all (the import box takes nodes too).
function Theme.LooksLikeTheme(text)
    return type(text) == "string" and text:match("^%s*" .. EXPORT_TAG .. ";") ~= nil
end

-- Returns { label = , colors = { name = "#hex" } }, or nil when the text
-- is not a readable theme. Unknown or broken colours are dropped; a theme
-- with none left is refused.
function Theme.ParseThemeString(text)
    if not Theme.LooksLikeTheme(text) then return nil end
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    local fields = {}
    for field in (text .. ";"):gmatch("([^;]*);") do fields[#fields + 1] = field end
    local allowed = {}
    for _, name in ipairs(COLOR_KEYS) do allowed[name] = true end
    for _, name in ipairs(GRADIENT_KEYS) do allowed[name .. "To"] = true end
    local colors, count = {}, 0
    for i = 3, #fields do
        local name, hex = fields[i]:match("^%s*(%w+):(%x%x%x%x%x%x)%s*$")
        if name and allowed[name] and not colors[name] then
            colors[name] = "#" .. hex:lower()
            count = count + 1
        end
    end
    if count == 0 then return nil end
    return { label = CleanLabel(fields[2]), colors = colors }
end

-- Adds a parsed theme to the player's themes. Returns its key.
function Theme.ImportTheme(parsed)
    if not (FarmMapDB and parsed) then return nil end
    return NewUser(parsed.label, parsed.colors)
end

-- The saved themes exist only once the SavedVariables are loaded: register
-- them at login, then repaint in case one of them is the chosen theme.
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    for _, entry in ipairs(FarmMapDB and FarmMapDB.userThemes or {}) do
        if type(entry) == "table" and entry.id and type(entry.colors) == "table" then
            RegisterUser(entry)
        end
    end
    Theme.Reload()
end)

ResolveColors()

-- Colour helpers. `a` is optional alpha.
local function RGB(name) local c = Theme.c[name] return c[1], c[2], c[3] end
function Theme.RGB(name) return RGB(name) end
function Theme.RGBA(name, a) local r, g, b = RGB(name) return r, g, b, a or 1 end

local function Mix(a, b, t)
    return { a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t }
end

-- Colours a texture from `top` to `bottom` (flat when bottom is nil).
-- "VERTICAL": the first colour is the bottom edge, the second the top
-- (same call on every client, checked in the Retail, MoP, Era and Forever
-- sources).
local function PaintBlend(tex, top, bottom, alpha)
    alpha = alpha or 1
    if bottom then
        tex:SetGradient("VERTICAL", CreateColor(bottom[1], bottom[2], bottom[3], alpha),
            CreateColor(top[1], top[2], top[3], alpha))
    else
        tex:SetVertexColor(top[1], top[2], top[3], alpha)
    end
end

-- A surface in its theme colour, blended when the theme gives that surface
-- a second colour and the caller allows it (big surfaces only).
local function PaintSurface(tex, name, alpha, blend)
    PaintBlend(tex, Theme.c[name], blend and Theme.g[name] or nil, alpha)
end

-- ============================================================
-- TEXT IN THE PLAYER'S LANGUAGE (2.2)
--
-- Search that ignores accents and case ("eclat" finds "Éclat"), sorting
-- as a dictionary does, numbers and dates written the local way. C_Intl
-- exists on Retail since 12.1.5 and on WoW: Forever; elsewhere each helper
-- keeps FarmMap's earlier behaviour. Every call is guarded: C_Intl may
-- return nothing, and a missing feature must never break a page.
-- ============================================================

local Intl = {}
ns.Intl = Intl

local CI = C_Intl
local function EnumValue(group, name, default)
    return Enum and Enum[group] and Enum[group][name] or default
end
local PRIMARY   = EnumValue("CollationStrength", "Primary", 0)    -- ignores accents and case
local SECONDARY = EnumValue("CollationStrength", "Secondary", 1)  -- accents count, case does not
local INTEGER   = EnumValue("NumberStyle", "Integer", 1)
local LONG_DATE = EnumValue("DateTimeStyle", "Long", 3)

-- The game fonts have no narrow no-break space (French thousands) and may
-- lack the no-break space: a plain space instead, or the digits would sit
-- around an empty box (as the em dash did on Korean clients).
local function PlainSpaces(s)
    return (s:gsub("\226\128\175", " "):gsub("\194\160", " "))
end

local function Call(fn, ...)
    if not (CI and CI[fn]) then return nil end
    local ok, result = pcall(CI[fn], ...)
    if ok then return result end
end

-- Whether `text` contains `query`, ignoring accents and case.
function Intl.Match(text, query)
    if not query or query == "" then return true end
    local hits = Call("FindStringMatches", text, query, PRIMARY)
    if type(hits) == "table" then return #hits > 0 end
    return text:lower():find(query:lower(), 1, true) ~= nil
end

-- Sort order of two names, as a dictionary of the player's language
-- orders them ("Éclat" next to "Eclat", not after "Z").
function Intl.Less(a, b)
    local r = Call("CompareStrings", a, b, SECONDARY)
    if type(r) == "number" and r ~= 0 then return r < 0 end
    return a < b
end

-- A whole number with the local thousands separator: 12,345 / 12 345.
function Intl.Number(n)
    local s = Call("FormatNumber", n, INTEGER)
    if type(s) == "string" and s ~= "" then return PlainSpaces(s) end
    return tostring(n)
end

-- A "dd/mm/yyyy" date (the changelog's) as the language writes it in
-- full: 9 octobre 2026, October 9, 2026. Unchanged when it cannot be read.
function Intl.Date(text)
    local d, m, y = tostring(text or ""):match("^(%d+)/(%d+)/(%d+)$")
    if not d then return text end
    local at = time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 })
    local s = at and Call("FormatDate", at, LONG_DATE, "")
    if type(s) == "string" and s ~= "" then return PlainSpaces(s) end
    return text
end

-- ============================================================
-- FONT
-- ============================================================

-- Narrow and clean, like KAO's. Locale fonts win when the active language
-- or the client's needs a script ARIALN cannot draw.
local DEFAULT_FONT = "Fonts\\ARIALN.TTF"

function Theme.FontPath(localeCode)
    local fonts = ns.LOCALE_FONTS or {}
    if localeCode then return fonts[localeCode] or DEFAULT_FONT end
    return fonts[GetLocale()]
        or fonts[ns.ActiveLocale and ns.ActiveLocale() or ""]
        or DEFAULT_FONT
end

-- Every size in this file and the window is a base value times this. The
-- first build used the bases as they are and was too small to read on
-- Retail (Kroosstii, 2026-10-07). Fixed like the rest: not themeable.
local TEXT_SCALE = 1.25
function Theme.Size(base) return base * TEXT_SCALE end

-- Sets a font at a base size, scaled.
function Theme.SetFont(fs, size, font)
    fs:SetFont(font or Theme.FontPath(), size * TEXT_SCALE, "")
end

-- `colorName` is a palette key, re-read on every repaint. `font` overrides
-- the path for a string written in another script (a language naming itself).
function Theme.Font(fs, size, colorName, font)
    Theme.SetFont(fs, size, font)
    if colorName then
        Theme.Track(fs, function(self) self:SetTextColor(RGB(colorName)) end)
    end
    return fs
end

-- ============================================================
-- SURFACES
-- ============================================================

-- A rounded plate: fill and 1 px outline from the generated textures, cut
-- in nine by the game so the corners keep their radius at any size.
-- small = the 3 px radius of buttons and tags, otherwise the 8 px one.
function Theme.Plate(frame, fillName, lineName, small, fillAlpha)
    local prefix  = small and "tag-" or "frame-"
    local margin  = small and 4 or 10

    local fill = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    fill:SetAllPoints()
    fill:SetTexture(UI_PATH .. prefix .. "fill")
    fill:SetTextureSliceMargins(margin, margin, margin, margin)

    local edge = frame:CreateTexture(nil, "BACKGROUND", nil, -6)
    edge:SetAllPoints()
    edge:SetTexture(UI_PATH .. prefix .. "border")
    edge:SetTextureSliceMargins(margin, margin, margin, margin)

    frame.plateFill, frame.plateEdge = fill, edge
    frame.plateColors = { fill = fillName, line = lineName, alpha = fillAlpha or 1, small = small }
    Theme.Track(frame, function(self) Theme.PaintPlate(self) end)
    return frame
end

-- The fill of a band laid along one edge of a rounded window (title bar,
-- footer): rounded corners on that edge (side = "TOP" or "BOTTOM"), square
-- on the other, where it meets the window's content. A plain square band
-- showed its corners past the window's rounded ones (seen on Forever's
-- palette, 2026-10-08). The small 3 px radius sits inside the window's
-- 8 px curve at the 3 px inset the windows use. Coloured by the theme.
function Theme.Band(frame, colorName, side)
    local rounded = frame:CreateTexture(nil, "BACKGROUND")
    rounded:SetAllPoints()
    rounded:SetTexture(UI_PATH .. "tag-fill")
    rounded:SetTextureSliceMargins(4, 4, 4, 4)
    -- The square half covers the rounded corners of the inner edge.
    local square = frame:CreateTexture(nil, "BACKGROUND")
    square:SetTexture(WHITE)
    if side == "BOTTOM" then
        square:SetPoint("TOPLEFT")
        square:SetPoint("BOTTOMRIGHT", 0, 4)
    else
        square:SetPoint("TOPLEFT", 0, -4)
        square:SetPoint("BOTTOMRIGHT")
    end
    -- With a gradient, the square half takes the share of it that covers
    -- its own height, so the two halves read as one surface.
    local function Paint()
        local top, bottom = Theme.c[colorName], Theme.g[colorName]
        PaintBlend(rounded, top, bottom)
        if not bottom then
            PaintBlend(square, top)
            return
        end
        local h = frame:GetHeight()
        local t = h > 4 and 4 / h or 0
        if side == "BOTTOM" then
            PaintBlend(square, top, Mix(top, bottom, 1 - t))
        else
            PaintBlend(square, Mix(top, bottom, t), bottom)
        end
    end
    Theme.Track(rounded, Paint)
    return rounded, square
end

-- The size of one screen pixel in a frame's own units (its effective
-- scale), as Blizzard's PixelUtil counts it.
function Theme.PixelSize(frame)
    return PixelUtil.GetPixelToUIUnitFactor() / frame:GetEffectiveScale()
end

-- Puts a window's edges on whole screen pixels. At most UI scales a
-- centred window lands between pixels, and every edge of the bands inside
-- it rounds its own way: the margins around the title bar and the footer
-- came out uneven, wider on the right (seen on Forever, 2026-10-08).
-- Called when the window shows, and after a drag or a resize.
function Theme.SnapToPixels(frame)
    local left, top = frame:GetLeft(), frame:GetTop()
    if not (left and top) then return end
    -- Screen pixels per UI unit, as Blizzard's PixelUtil counts them:
    -- the effective scale over 768 / the screen's physical height.
    local perPixel = PixelUtil.GetPixelToUIUnitFactor() / frame:GetEffectiveScale()
    local function Px(v) return math.floor(v / perPixel + 0.5) * perPixel end
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", Px(left), Px(top))
    local w, h = Px(frame:GetWidth()), Px(frame:GetHeight())
    if math.abs(w - frame:GetWidth()) > 0.001 or math.abs(h - frame:GetHeight()) > 0.001 then
        frame:SetSize(w, h)
    end
end

-- ---- Window size (FarmMapDB.uiScale) ----
-- The player's own size for FarmMap's big windows, on top of the game's UI
-- scale. Each client keeps its own (SavedVariables are per client): Classic
-- Era's UI scale drew the same window 25% bigger than Retail's (Kroosstii,
-- 2026-10-08). A size setting, not a theme one: themes never touch sizes.
local scaledWindows = {}

function Theme.WindowScale()
    local s = FarmMapDB and tonumber(FarmMapDB.uiScale)
    if not s or s < 0.3 or s > 1.5 then return 1 end
    return s
end

-- Registers a window and gives it the current size.
function Theme.ScaledWindow(frame)
    scaledWindows[#scaledWindows + 1] = frame
    frame:SetScale(Theme.WindowScale())
end

-- Re-applies the size to every registered window, keeping each shown one
-- where it is on screen (a scale change alone would move it).
function Theme.RescaleWindows()
    local scale = Theme.WindowScale()
    for _, frame in ipairs(scaledWindows) do
        if frame:IsShown() and frame:GetLeft() then
            local eff = frame:GetEffectiveScale()
            local left, top = frame:GetLeft() * eff, frame:GetTop() * eff
            frame:SetScale(scale)
            local newEff = frame:GetEffectiveScale()
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left / newEff, top / newEff)
            Theme.SnapToPixels(frame)
        else
            frame:SetScale(scale)
        end
        for _, place in ipairs(frame.insetBands or {}) do place() end
    end
end

-- Lays a band inside a window at an inset of whole pixels on every side
-- (PixelUtil rounds the inset at the window's scale), so the margins match.
local function PlaceBand(band, window, side, inset)
    band:ClearAllPoints()
    if side == "TOP" then
        PixelUtil.SetPoint(band, "TOPLEFT", window, "TOPLEFT", inset, -inset)
        PixelUtil.SetPoint(band, "TOPRIGHT", window, "TOPRIGHT", -inset, -inset)
    else
        PixelUtil.SetPoint(band, "BOTTOMLEFT", window, "BOTTOMLEFT", inset, inset)
        PixelUtil.SetPoint(band, "BOTTOMRIGHT", window, "BOTTOMRIGHT", -inset, inset)
    end
end

-- The window remembers its bands: the whole-pixel inset depends on the
-- scale, so a size change places them again (Theme.RescaleWindows).
function Theme.InsetBand(band, window, side, inset)
    window.insetBands = window.insetBands or {}
    table.insert(window.insetBands, function() PlaceBand(band, window, side, inset) end)
    PlaceBand(band, window, side, inset)
end

-- Repaints a plate with its own colours, or with an override (hover, focus).
function Theme.PaintPlate(frame, fillName, lineName, fillAlpha, lineAlpha)
    local pc = frame.plateColors
    if not pc then return end
    PaintSurface(frame.plateFill, fillName or pc.fill, fillAlpha or pc.alpha, not pc.small)
    local lr, lg, lb = RGB(lineName or pc.line)
    frame.plateEdge:SetVertexColor(lr, lg, lb, lineAlpha or 1)
end

-- A 1 px rule, snapped to a real pixel so it survives any UI scale.
function Theme.Rule(parent, vertical, colorName)
    local tex = parent:CreateTexture(nil, "ARTWORK")
    tex:SetTexture(WHITE)
    if vertical then
        PixelUtil.SetWidth(tex, 1, 1)
    else
        PixelUtil.SetHeight(tex, 1, 1)
    end
    Theme.Track(tex, function(self) self:SetVertexColor(RGB(colorName or "line")) end)
    return tex
end

-- ============================================================
-- TOOLTIP
-- ============================================================

-- Our own tooltip: GameTooltip would bring the game's border into a window
-- that draws its own. Follows the cursor, below and left of it, so the
-- arrow never covers the first word.
local tip
local TIP_MAX_WIDTH = 280

local function EnsureTip()
    if tip then return tip end
    tip = CreateFrame("Frame", nil, UIParent)
    tip:SetFrameStrata("TOOLTIP")
    tip:SetClampedToScreen(true)
    Theme.Plate(tip, "panel2", "line")

    tip.title = Theme.Font(tip:CreateFontString(nil, "OVERLAY"), 13, "text")
    tip.title:SetPoint("TOPLEFT", 10, -8)
    tip.title:SetJustifyH("LEFT")

    tip.body = Theme.Font(tip:CreateFontString(nil, "OVERLAY"), 12, "dim")
    tip.body:SetPoint("TOPLEFT", tip.title, "BOTTOMLEFT", 0, -4)
    tip.body:SetJustifyH("LEFT")
    tip.body:SetWordWrap(true)
    tip:Hide()
    return tip
end

local function PositionTip(t)
    local scale = UIParent:GetEffectiveScale()
    local x, y = GetCursorPosition()
    x, y = x / scale, y / scale
    local roomLeft  = x >= t:GetWidth() + 16
    local roomBelow = y >= t:GetHeight() + 20
    t:ClearAllPoints()
    if roomLeft and roomBelow then
        t:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", x - 12, y - 16)
    elseif roomBelow then
        t:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x + 18, y - 16)
    elseif roomLeft then
        t:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", x - 12, y + 18)
    else
        t:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x + 18, y + 18)
    end
end

function Theme.ShowTip(title, body)
    if not title or title == "" then return end
    local t = EnsureTip()
    t.title:SetText(title)
    -- Width BEFORE height: a wrapped string measured without a width
    -- reports a single line.
    local width = math.floor(t.title:GetStringWidth() + 0.5)
    if body and body ~= "" then
        t.body:SetWidth(math.min(TIP_MAX_WIDTH, math.max(width, 200)))
        t.body:SetText(body)
        t.body:Show()
        width = math.max(width, math.floor(t.body:GetStringWidth() + 0.5))
    else
        t.body:SetText("")
        t.body:Hide()
    end
    local height = math.floor(t.title:GetStringHeight() + 0.5) + 16
    if t.body:IsShown() then
        height = height + math.floor(t.body:GetStringHeight() + 0.5) + 4
    end
    t:SetSize(math.min(TIP_MAX_WIDTH, width) + 20, height)
    PositionTip(t)
    t:SetScript("OnUpdate", PositionTip)
    t:Show()
end

function Theme.HideTip()
    if tip then
        tip:SetScript("OnUpdate", nil)
        tip:Hide()
    end
end

-- ============================================================
-- BUTTONS
-- ============================================================

-- A plate with a label: the window's actions (Reload, Close, Import...).
-- accent = the one action a page leads with.
function Theme.ActionButton(parent, label, accent)
    local b = CreateFrame("Button", nil, parent)
    b:SetHeight(30)
    Theme.Plate(b, "panel2", accent and "accentSoft" or "line", true)
    b.text = Theme.Font(b:CreateFontString(nil, "OVERLAY"), 13, accent and "accent" or "text")
    b.text:SetAllPoints()
    b.text:SetJustifyH("CENTER")
    b.text:SetJustifyV("MIDDLE")

    function b:SetLabel(text)
        self.text:SetText(text)
        -- Even width: an odd one centres the label on a half-pixel.
        local w = math.floor(self.text:GetStringWidth() + 0.5) + 28
        if w % 2 == 1 then w = w + 1 end
        self:SetWidth(math.max(w, self.minWidth or 0))
    end
    b:SetLabel(label)

    b:SetScript("OnEnter", function(self)
        Theme.PaintPlate(self, nil, "accent")
        if self.tipTitle then Theme.ShowTip(self.tipTitle, self.tipBody) end
    end)
    b:SetScript("OnLeave", function(self)
        Theme.PaintPlate(self)
        Theme.HideTip()
    end)
    return b
end

-- A small clickable glyph: close cross, clear field.
function Theme.GlyphButton(parent, glyph, size)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(size, size)
    b.text = Theme.Font(b:CreateFontString(nil, "OVERLAY"), size, "dim", DEFAULT_FONT)
    b.text:SetAllPoints()
    b.text:SetJustifyH("CENTER")
    b.text:SetJustifyV("MIDDLE")
    b.text:SetText(glyph)
    b:SetScript("OnEnter", function(self) self.text:SetTextColor(RGB("bad")) end)
    b:SetScript("OnLeave", function(self) self.text:SetTextColor(RGB("dim")) end)
    return b
end

-- Three stepped ticks in the corner, the resize handle.
function Theme.ResizeGrip(parent)
    local grip = CreateFrame("Button", nil, parent)
    grip:SetSize(16, 16)
    grip:SetPoint("BOTTOMRIGHT", -3, 3)
    grip:SetFrameLevel(parent:GetFrameLevel() + 10)
    grip.ticks = {}
    for i = 1, 3 do
        local tick = grip:CreateTexture(nil, "OVERLAY")
        tick:SetSize(i * 3 + 2, 1)
        tick:SetPoint("BOTTOMRIGHT", -2, 1 + (i - 1) * 3)
        tick:SetTexture(WHITE)
        grip.ticks[i] = tick
    end
    local function Paint(self, alpha)
        for _, t in ipairs(self.ticks) do t:SetVertexColor(Theme.RGBA("dim", alpha)) end
    end
    Theme.Track(grip, function(self) Paint(self, 0.5) end)
    grip:SetScript("OnEnter", function(self) Paint(self, 1) end)
    grip:SetScript("OnLeave", function(self) Paint(self, 0.5) end)
    return grip
end

-- ============================================================
-- INPUTS
-- ============================================================

-- Search field with a placeholder and a clear cross.
function Theme.SearchBox(parent, placeholder)
    local box = CreateFrame("EditBox", nil, parent)
    box:SetHeight(30)
    box:SetAutoFocus(false)
    box:SetTextInsets(8, 24, 0, 0)
    Theme.Font(box, 13, "text")
    Theme.Plate(box, "bg", "line", true)

    box.placeholder = Theme.Font(box:CreateFontString(nil, "OVERLAY"), 13, "faint")
    box.placeholder:SetPoint("LEFT", 9, 0)
    box.placeholder:SetPoint("RIGHT", -22, 0)
    box.placeholder:SetJustifyH("LEFT")
    box.placeholder:SetWordWrap(false)
    box.placeholder:SetText(placeholder or "")

    box.clear = Theme.GlyphButton(box, "\195\151", 16)   -- multiplication sign
    box.clear:SetPoint("RIGHT", -4, 0)
    box.clear:Hide()
    box.clear:SetScript("OnClick", function() box:SetText("") box:ClearFocus() end)

    local function Sync()
        local hasText = box:GetText() ~= ""
        box.placeholder:SetShown(not hasText and not box:HasFocus())
        box.clear:SetShown(hasText)
    end
    box:SetScript("OnTextChanged", function(self, userInput)
        Sync()
        if self.onChange then self.onChange(self:GetText(), userInput) end
    end)
    box:SetScript("OnEditFocusGained", function(self) Theme.PaintPlate(self, nil, "accent") Sync() end)
    box:SetScript("OnEditFocusLost", function(self) Theme.PaintPlate(self) Sync() end)
    box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    box:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    Sync()
    return box
end

-- ============================================================
-- SETTING ROWS
--
-- Full-width rows: name and explanation on the left, control on the right
-- or below, hairline underneath. The explanation sits on the page rather
-- than in a tooltip: a tooltip only reaches someone already hovering.
-- Every row has SetContent(name, desc, width), Bind(get, set) and Update(),
-- so the window can reuse one row object per setting across visits.
-- ============================================================

local function RowText(row)
    row.label = Theme.Font(row:CreateFontString(nil, "OVERLAY"), 14, "text")
    row.label:SetPoint("TOPLEFT", 0, -9)
    row.label:SetJustifyH("LEFT")

    row.desc = Theme.Font(row:CreateFontString(nil, "OVERLAY"), 12.5, "dim")
    row.desc:SetPoint("TOPLEFT", row.label, "BOTTOMLEFT", 0, -3)
    row.desc:SetJustifyH("LEFT")
    row.desc:SetWordWrap(true)

    row.rule = Theme.Rule(row, false, "line")
    row.rule:SetPoint("BOTTOMLEFT")
    row.rule:SetPoint("BOTTOMRIGHT")
end

-- Lays out the name and description at a width; returns where they end.
local function RowMeasure(row, name, desc, width)
    row.label:SetWidth(width)
    row.label:SetText(name or "")
    local y = 9 + row.label:GetStringHeight()
    if desc and desc ~= "" then
        row.desc:SetWidth(width)
        row.desc:SetText(desc)
        row.desc:Show()
        y = y + 3 + row.desc:GetStringHeight()
    else
        row.desc:Hide()
    end
    -- Rounded: fractional heights put the next row on a half-pixel, where
    -- 1 px lines lose an edge.
    return math.floor(y + 0.5)
end

-- On/off switch row.
function Theme.SwitchRow(parent)
    local row = CreateFrame("Button", nil, parent)
    RowText(row)

    local switch = CreateFrame("Frame", nil, row)
    PixelUtil.SetSize(switch, 40, 20)
    PixelUtil.SetPoint(switch, "TOPRIGHT", row, "TOPRIGHT", -2, -10)
    Theme.Plate(switch, "bg", "line", true)
    local knob = switch:CreateTexture(nil, "OVERLAY")
    PixelUtil.SetSize(knob, 14, 14)
    knob:SetTexture(UI_PATH .. "tag-fill")
    knob:SetTextureSliceMargins(4, 4, 4, 4)
    row.switch, row.knob = switch, knob

    function row:SetContent(name, desc, width)
        self:SetHeight(math.max(RowMeasure(self, name, desc, width - 60) + 12, 42))
    end

    function row:Bind(get, set)
        self.get, self.set = get, set
        self:Update()
    end

    function row:Update()
        local on = self.get and self.get() or false
        local disabled = self.isDisabled and self.isDisabled()
        Theme.PaintPlate(switch, nil, on and "accent" or "line")
        knob:ClearAllPoints()
        if on then
            PixelUtil.SetPoint(knob, "RIGHT", switch, "RIGHT", -3, 0)
            knob:SetVertexColor(RGB("accent"))
        else
            PixelUtil.SetPoint(knob, "LEFT", switch, "LEFT", 3, 0)
            knob:SetVertexColor(RGB("faint"))
        end
        self:SetAlpha(disabled and 0.45 or 1)
    end
    Theme.Track(row, function(self) if self.get then self:Update() end end)

    row:SetScript("OnClick", function(self)
        if not self.set or (self.isDisabled and self.isDisabled()) then return end
        self.set(not (self.get and self.get()))
        self:Update()
    end)
    row:SetScript("OnEnter", function(self) self.label:SetTextColor(1, 1, 1) end)
    row:SetScript("OnLeave", function(self) self.label:SetTextColor(RGB("text")) end)
    return row
end

-- Section title inside a page: uppercase accent label, a rule to the edge.
-- Its height carries the space above it.
function Theme.SectionHeader(parent)
    local f = CreateFrame("Frame", nil, parent)
    f.label = Theme.Font(f:CreateFontString(nil, "OVERLAY"), 12.5, "accent")
    f.label:SetPoint("BOTTOMLEFT", 0, 4)
    f.rule = Theme.Rule(f, false, "line")
    f.rule:SetPoint("LEFT", f.label, "RIGHT", 10, 0)
    f.rule:SetPoint("RIGHT", f, "RIGHT", -1, 0)
    function f:SetContent(text)
        self.label:SetText((text or ""):upper())
        self:SetHeight(36)
    end
    return f
end

-- A paragraph of help text between rows.
function Theme.HintRow(parent)
    local f = CreateFrame("Frame", nil, parent)
    f.text = Theme.Font(f:CreateFontString(nil, "OVERLAY"), 12.5, "dim")
    f.text:SetPoint("TOPLEFT", 0, -6)
    f.text:SetJustifyH("LEFT")
    f.text:SetWordWrap(true)
    function f:SetContent(text, width)
        self.text:SetWidth(width)
        self.text:SetText(text or "")
        self:SetHeight(math.floor(self.text:GetStringHeight() + 0.5) + 10)
    end
    return f
end

-- A row whose control is a button on the right: actions such as resetting
-- the filter bar or clearing the database.
function Theme.ButtonRow(parent)
    local row = CreateFrame("Frame", nil, parent)
    RowText(row)
    row.button = Theme.ActionButton(row, "")
    function row:SetContent(name, desc, width, label)
        self.button:SetLabel(label or "")
        self.button:ClearAllPoints()
        self.button:SetPoint("TOPRIGHT", -1, -8)
        local y = RowMeasure(self, name, desc, width - self.button:GetWidth() - 20)
        self:SetHeight(math.max(y + 12, 48))
    end
    return row
end

-- A small status label: "detected", "not installed". The colour says which.
function Theme.Tag(parent)
    local t = CreateFrame("Frame", nil, parent)
    t:SetHeight(22)
    Theme.Plate(t, "bg", "line", true)
    t.text = t:CreateFontString(nil, "OVERLAY")
    Theme.SetFont(t.text, 11.5)
    t.text:SetPoint("CENTER")
    -- One painter for the whole tag (it replaces the plate's own), so a
    -- theme switch keeps the status colour instead of resetting it.
    Theme.Track(t, function(self)
        local name = self.colorName or "dim"
        self.text:SetTextColor(RGB(name))
        Theme.PaintPlate(self, nil, name, nil, 0.6)
    end)
    function t:SetTag(text, colorName)
        self.colorName = colorName
        self.text:SetText(text or "")
        local w = math.floor(self.text:GetStringWidth() + 0.5) + 18
        if w % 2 == 1 then w = w + 1 end
        self:SetWidth(w)
        self.text:SetTextColor(RGB(colorName))
        Theme.PaintPlate(self, nil, colorName, nil, 0.6)
    end
    return t
end

-- Dropdown menu, parented to UIParent so the scroll frame does not clip it.
local DROP_ROW_H = 28
local openMenu

function Theme.Dropdown(parent)
    local dd = CreateFrame("Button", nil, parent)
    dd:SetHeight(32)
    Theme.Plate(dd, "panel2", "line", true)

    dd.text = Theme.Font(dd:CreateFontString(nil, "OVERLAY"), 13, "text")
    dd.text:SetPoint("LEFT", 10, 0)
    dd.text:SetPoint("RIGHT", -24, 0)
    dd.text:SetJustifyH("LEFT")
    dd.text:SetWordWrap(false)

    dd.arrow = Theme.Font(dd:CreateFontString(nil, "OVERLAY"), 10, "dim", DEFAULT_FONT)
    dd.arrow:SetPoint("RIGHT", -10, 0)
    dd.arrow:SetText("\226\150\188")   -- black down-pointing triangle

    local menu = CreateFrame("Frame", nil, UIParent)
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:SetClampedToScreen(true)
    Theme.Plate(menu, "panel2", "accentSoft")
    menu:Hide()

    -- A click anywhere else closes the menu.
    local catcher = CreateFrame("Button", nil, UIParent)
    catcher:SetAllPoints(UIParent)
    catcher:SetFrameStrata("FULLSCREEN_DIALOG")
    catcher:Hide()
    catcher:SetScript("OnClick", function() menu:Hide() end)
    menu:SetFrameLevel(catcher:GetFrameLevel() + 10)
    menu:SetScript("OnHide", function() catcher:Hide() if openMenu == menu then openMenu = nil end end)

    dd.menu, dd.rows = menu, {}

    -- choices = { { value = , label = , font = } }, rebuilt on every Bind:
    -- a list of languages or themes can grow while the game runs.
    function dd:SetChoices(choices)
        self.choices = choices
        for _, r in ipairs(self.rows) do r:Hide() end
        local widest = 0
        for i, choice in ipairs(choices) do
            local r = self.rows[i]
            if not r then
                r = CreateFrame("Button", nil, menu)
                r:SetHeight(DROP_ROW_H)
                r.hi = r:CreateTexture(nil, "BACKGROUND")
                r.hi:SetAllPoints()
                r.hi:SetTexture(WHITE)
                r.hi:SetVertexColor(1, 1, 1, 0.07)
                r.hi:Hide()
                r.text = r:CreateFontString(nil, "OVERLAY")
                r.text:SetPoint("LEFT", 10, 0)
                r.text:SetPoint("RIGHT", -10, 0)
                r.text:SetJustifyH("LEFT")
                r:SetScript("OnEnter", function(self) self.hi:Show() end)
                r:SetScript("OnLeave", function(self) self.hi:Hide() end)
                r:SetScript("OnClick", function(self)
                    menu:Hide()
                    if dd.set then dd.set(self.value) end
                    dd:Update()
                end)
                self.rows[i] = r
            end
            r.value, r.label, r.font = choice.value, choice.label, choice.font
            Theme.SetFont(r.text, 13, choice.font)
            r.text:SetText(choice.label)
            widest = math.max(widest, r.text:GetStringWidth())
            r:ClearAllPoints()
            r:SetPoint("TOPLEFT", 1, -(4 + (i - 1) * DROP_ROW_H))
            r:SetPoint("TOPRIGHT", -1, -(4 + (i - 1) * DROP_ROW_H))
            r:Show()
        end
        local width = math.max(math.floor(widest + 0.5) + 44, self.minWidth or 160)
        if width % 2 == 1 then width = width + 1 end
        self:SetWidth(width)
        menu:SetSize(width, #choices * DROP_ROW_H + 8)
        menu:ClearAllPoints()
        menu:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -2)
    end

    function dd:Update()
        local current = self.get and self.get()
        for _, r in ipairs(self.rows) do
            if r:IsShown() then
                local on = r.value == current
                r.text:SetTextColor(RGB(on and "accent" or "dim"))
                if on then
                    Theme.SetFont(self.text, 13, r.font)
                    self.text:SetText(r.label)
                end
            end
        end
    end
    Theme.Track(dd, function(self) if self.get then self:Update() end end)

    function dd:Bind(get, set, choices)
        self.get, self.set = get, set
        if choices then self:SetChoices(choices) end
        self:Update()
    end

    dd:SetScript("OnClick", function(self)
        if menu:IsShown() then menu:Hide() return end
        if openMenu then openMenu:Hide() end
        catcher:Show()
        menu:Show()
        openMenu = menu
        self:Update()
    end)
    dd:SetScript("OnEnter", function(self) Theme.PaintPlate(self, nil, "accent") end)
    dd:SetScript("OnLeave", function(self) Theme.PaintPlate(self) end)
    dd:SetScript("OnHide", function() menu:Hide() end)
    return dd
end

-- Row with a dropdown under its text.
function Theme.ChoiceRow(parent)
    local row = CreateFrame("Frame", nil, parent)
    RowText(row)
    row.dropdown = Theme.Dropdown(row)

    function row:SetContent(name, desc, width)
        local y = RowMeasure(self, name, desc, width) + 6
        self.dropdown:ClearAllPoints()
        self.dropdown:SetPoint("TOPLEFT", 1, -y)
        self:SetHeight(y + 32 + 12)
    end
    function row:Bind(get, set, choices) self.dropdown:Bind(get, set, choices) end
    function row:Update() self.dropdown:Update() end
    return row
end

-- Slider row; the readout is also an input box.
function Theme.SliderRow(parent)
    local row = CreateFrame("Frame", nil, parent)
    RowText(row)

    -- Wide enough for a word, not only a number: "No limit" was cut to
    -- "No limi" and pushed against the edge (route's longest lap, 2.2).
    local value = CreateFrame("EditBox", nil, row)
    value:SetSize(96, 28)
    value:SetPoint("TOPRIGHT", -1, -7)
    value:SetAutoFocus(false)
    value:SetJustifyH("RIGHT")
    value:SetMaxLetters(14)
    value:SetTextInsets(4, 7, 0, 0)
    Theme.Font(value, 13, "dim")
    Theme.Plate(value, "bg", "line", true)

    local slider = CreateFrame("Slider", nil, row)
    slider:SetHeight(16)
    slider:SetOrientation("HORIZONTAL")
    slider:SetObeyStepOnDrag(true)
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetHeight(2)
    track:SetPoint("LEFT")
    track:SetPoint("RIGHT")
    track:SetTexture(WHITE)
    local thumb = slider:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(12, 12)
    thumb:SetTexture(UI_PATH .. "tag-fill")
    thumb:SetTextureSliceMargins(4, 4, 4, 4)
    slider:SetThumbTexture(thumb)
    Theme.Track(slider, function()
        track:SetVertexColor(RGB("line"))
        thumb:SetVertexColor(RGB("accent"))
    end)
    row.slider, row.value = slider, value

    local function Format(v)
        return row.format and row.format(v) or ("%.2f"):format(v)
    end

    function row:SetRange(minValue, maxValue, step)
        self.minValue, self.maxValue, self.step = minValue, maxValue, step
        slider:SetMinMaxValues(minValue, maxValue)
        slider:SetValueStep(step)
    end

    function row:SetContent(name, desc, width)
        local y = RowMeasure(self, name, desc, width - 110) + 12
        slider:ClearAllPoints()
        slider:SetPoint("TOPLEFT", 2, -y)
        slider:SetPoint("TOPRIGHT", -2, -y)
        self:SetHeight(y + 16 + 14)
    end

    function row:Bind(get, set)
        self.get, self.set = get, set
        self:Update()
    end

    function row:Update()
        local v = self.get and self.get() or self.minValue or 0
        self.updating = true        -- SetValue fires OnValueChanged
        slider:SetValue(v)
        self.updating = false
        value:SetText(Format(v))
        value:SetTextColor(RGB("dim"))
        -- Greyed and inert while the setting it depends on is off.
        local disabled = self.isDisabled and self.isDisabled()
        slider:EnableMouse(not disabled)
        value:EnableMouse(not disabled)
        self:SetAlpha(disabled and 0.45 or 1)
    end

    slider:SetScript("OnValueChanged", function(_, v)
        if row.updating then return end
        value:SetText(Format(v))
        if row.set then row.set(v) end
    end)
    -- The thumb is placed from the slider's width, unknown until anchored.
    slider:SetScript("OnSizeChanged", function() if row.get then row:Update() end end)

    -- Typed values are clamped, snapped to the step, applied, then rewritten
    -- from the setting: the box never shows a value the addon is not using.
    local function Commit(self)
        -- The first number in the box: "23", "23 min" and "23,5" all read.
        local typed = (self:GetText() or ""):match("%-?%d+[.,]?%d*") or ""
        local v = tonumber((typed:gsub(",", ".")))
        if v and row.set and row.minValue then
            v = math.max(row.minValue, math.min(row.maxValue, v))
            v = math.floor((v - row.minValue) / row.step + 0.5) * row.step + row.minValue
            row.set(v)
        end
        row:Update()
        self:ClearFocus()
    end
    value:SetScript("OnEnterPressed", Commit)
    value:SetScript("OnEditFocusLost", Commit)
    value:SetScript("OnEscapePressed", function(self) row:Update() self:ClearFocus() end)
    value:SetScript("OnEditFocusGained", function(self)
        self:SetTextColor(RGB("text"))
        self:HighlightText()
    end)
    return row
end

-- ============================================================
-- SCROLLING
-- ============================================================

-- Bare ScrollFrame plus a thin themed rail that only shows when there is
-- something to scroll. Returns the frame and its content child, whose width
-- is pinned to the viewport (a scroll child gets none from anchors).
function Theme.ScrollFrame(parent)
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)
    scroll:SetScript("OnSizeChanged", function(_, width) content:SetWidth(width) end)

    local rail = CreateFrame("Frame", nil, scroll)
    rail:SetWidth(4)
    rail:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 9, 0)
    rail:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 9, 0)
    local thumb = rail:CreateTexture(nil, "ARTWORK")
    thumb:SetWidth(4)
    thumb:SetTexture(UI_PATH .. "tag-fill")
    thumb:SetTextureSliceMargins(2, 2, 2, 2)
    Theme.Track(thumb, function(self) self:SetVertexColor(RGB("accentSoft")) end)

    local function Layout()
        local viewport = scroll:GetHeight() or 0
        local total = content:GetHeight() or 0
        local overflow = total - viewport
        -- A page shorter than the last one keeps the old offset: clamp it.
        local limit = math.max(0, overflow)
        if scroll:GetVerticalScroll() > limit then scroll:SetVerticalScroll(limit) end
        if overflow <= 1 or viewport <= 0 then rail:Hide() return end
        rail:Show()
        local height = math.max(24, math.floor(viewport * viewport / total))
        local offset = scroll:GetVerticalScroll() / overflow
        thumb:SetHeight(height)
        thumb:ClearAllPoints()
        thumb:SetPoint("TOP", rail, "TOP", 0, -math.floor(offset * (viewport - height)))
    end

    -- Puts the page's top on a whole screen pixel. A scroll offset (or the
    -- page's own anchor, at the window's scale) between two pixels drew the
    -- 1 px edges of switches and buttons thinner on one side, top or bottom
    -- depending on the row (seen again in 2.2, Kroosstii, 2026-10-22).
    local snapping
    local function SnapScroll()
        if snapping then return end
        local top = scroll:GetTop()
        if not top then return end
        local px = Theme.PixelSize(content)
        local v = scroll:GetVerticalScroll()
        local pageTop = top + v
        local nv = v + (math.floor(pageTop / px + 0.5) * px - pageTop)
        if nv < 0 then nv = nv + px end
        if math.abs(nv - v) > 0.0001 then
            snapping = true
            scroll:SetVerticalScroll(nv)
            snapping = false
        end
    end

    -- The wheel must work over every control drawn on top of the page.
    local function Wheel(_, delta)
        local overflow = math.max(0, (content:GetHeight() or 0) - (scroll:GetHeight() or 0))
        scroll:SetVerticalScroll(math.max(0, math.min(overflow,
            scroll:GetVerticalScroll() - delta * 40)))
        SnapScroll()
    end
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", Wheel)
    content:EnableMouseWheel(true)
    content:SetScript("OnMouseWheel", Wheel)
    scroll.Wheel, scroll.Layout = Wheel, Layout

    scroll:HookScript("OnVerticalScroll", Layout)
    scroll:HookScript("OnSizeChanged", Layout)
    content:HookScript("OnSizeChanged", Layout)
    -- Once the page is placed: shown, resized, or a new page laid out.
    scroll:HookScript("OnShow", function() C_Timer.After(0, SnapScroll) end)
    scroll:HookScript("OnSizeChanged", function() C_Timer.After(0, SnapScroll) end)
    content:HookScript("OnSizeChanged", function() C_Timer.After(0, SnapScroll) end)
    scroll.SnapScroll = SnapScroll
    return scroll, content
end

-- Hands the page's wheel to a control drawn over it.
function Theme.CatchWheel(frame, scroll)
    if not (frame and scroll and scroll.Wheel) then return end
    frame:EnableMouseWheel(true)
    frame:SetScript("OnMouseWheel", scroll.Wheel)
end
