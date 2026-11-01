-- ============================================================
--  FarmMap — Radar (2.3, PROTOTYPE)
--  A transparent disc in the middle of the screen, like a large
--  minimap: the known nodes around the player and the route. The
--  mouse goes through it. Settings in FarmMapDB.radar, set by
--  /fm radar for now (no options page yet):
--    /fm radar             show / hide
--    /fm radar range 150   yards from the centre to the edge
--    /fm radar size 300    diameter on screen
--    /fm radar rotate      turns with the player / north up
--    /fm radar alpha 60    opacity of the disc, in %
-- ============================================================

local _, ns = ...

local Radar = {}
ns.Radar = Radar

local HBD = LibStub("HereBeDragons-2.0")

local TICK        = 0.05   -- seconds between two redraws (20 a second)
local CACHE_TICK  = 3      -- seconds between two reads of the node database
local MAX_ICONS   = 120
local MAX_LINES   = 200
local ICON_PX     = 18
local DEFAULTS    = { shown = false, range = 150, size = 300, rotate = true, alpha = 35 }

local frame, disc, arrow
local icons, lines = {}, {}
local nodes = {}           -- { wx, wy, type } of the player's instance
local nodesInstance, cacheAge = nil, CACHE_TICK
local loopSeen, loopWorld          -- the route's loop, and its points in world yards
local elapsed = 0

local function DB()
    FarmMapDB.radar = FarmMapDB.radar or {}
    local db = FarmMapDB.radar
    for k, v in pairs(DEFAULTS) do if db[k] == nil then db[k] = v end end
    return db
end

-- ---- the node database, in world yards ---------------------------------------

-- Every known node of the player's instance (continent), in world yards:
-- read again every few seconds, not on every redraw.
local function ReadNodes(instance)
    wipe(nodes)
    nodesInstance = instance
    for mapID, list in pairs(FarmMapDB) do
        if type(mapID) == "number" and type(list) == "table" then
            for _, node in ipairs(list) do
                local wx, wy, inst = HBD:GetWorldCoordinatesFromZone(node.x, node.y, mapID)
                if wx and inst == instance then
                    nodes[#nodes + 1] = { wx, wy, node.type }
                end
            end
        end
    end
end

-- ---- drawing ------------------------------------------------------------------

local function Icon(i)
    local tex = icons[i]
    if not tex then
        tex = frame:CreateTexture(nil, "ARTWORK")
        tex:SetSize(ICON_PX, ICON_PX)
        icons[i] = tex
    end
    return tex
end

local function Line(i)
    local line = lines[i]
    if not line then
        line = frame:CreateLine(nil, "BORDER")
        line:SetThickness(2)
        line:SetColorTexture(1, 0.82, 0, 0.7)
        lines[i] = line
    end
    return line
end

-- The part of segment a-b (unit disc coordinates) inside the disc, or nil.
local function Clip(ax, ay, bx, by)
    local dx, dy = bx - ax, by - ay
    local a = dx * dx + dy * dy
    if a == 0 then return nil end
    local b = 2 * (ax * dx + ay * dy)
    local c = ax * ax + ay * ay - 1
    local disc2 = b * b - 4 * a * c
    if disc2 <= 0 then return nil end
    local r = math.sqrt(disc2)
    local t0 = math.max(0, (-b - r) / (2 * a))
    local t1 = math.min(1, (-b + r) / (2 * a))
    if t0 >= t1 then return nil end
    return ax + dx * t0, ay + dy * t0, ax + dx * t1, ay + dy * t1
end

local function Redraw()
    local db = DB()
    local px, py, instance = HBD:GetPlayerWorldPosition()
    -- Instances give no position: nothing to show there.
    if not px then
        for _, t in ipairs(icons) do t:Hide() end
        for _, l in ipairs(lines) do l:Hide() end
        return
    end
    if instance ~= nodesInstance or cacheAge >= CACHE_TICK then
        ReadNodes(instance)
        cacheAge = 0
    end

    -- Same maths as HereBeDragons' minimap pins: a node at (wx, wy) sits at
    -- (px - wx, py - wy) from the player, turned by the facing when the
    -- radar turns with the player.
    local facing = db.rotate and GetPlayerFacing and GetPlayerFacing()
    local sin, cos = 0, 1
    if facing then sin, cos = math.sin(facing), math.cos(facing) end
    local range, half = db.range, db.size / 2
    local function ToDisc(wx, wy)
        local dx, dy = px - wx, py - wy
        if facing then dx, dy = dx * cos - dy * sin, dx * sin + dy * cos end
        return dx / range, dy / range
    end

    local shown = 0
    for _, n in ipairs(nodes) do
        if shown >= MAX_ICONS then break end
        if ns.ShouldShowNode(n[3]) then
            local ux, uy = ToDisc(n[1], n[2])
            local d2 = ux * ux + uy * uy
            if d2 <= 1 then
                shown = shown + 1
                local tex = Icon(shown)
                if tex.nodeType ~= n[3] then
                    ns.ApplyNodeIcon(tex, n[3])
                    tex.nodeType = n[3]
                end
                -- Fades out towards the edge, so the disc has no hard border.
                tex:SetAlpha(d2 < 0.6 and 1 or (1 - d2) / 0.4)
                tex:ClearAllPoints()
                tex:SetPoint("CENTER", frame, "CENTER", ux * half, -uy * half)
                tex:Show()
            end
        end
    end
    for i = shown + 1, #icons do icons[i]:Hide() end

    -- The route of the player's zone, cut at the edge of the disc.
    local used = 0
    if FarmMapDB.routeShown and ns.Route then
        local mapID = ns.Route.PlayerZone()
        local loop = mapID and ns.Route.Get(mapID).loop or {}
        local n = #loop
        if n >= 2 then
            -- World yards of the loop, kept until the loop itself changes.
            if loop ~= loopSeen then
                loopSeen, loopWorld = loop, {}
                for i, node in ipairs(loop) do
                    local wx, wy = HBD:GetWorldCoordinatesFromZone(node.x, node.y, mapID)
                    if wx then loopWorld[i] = { wx, wy } end
                end
            end
            local pts = {}
            for i = 1, n do
                local w = loopWorld[i]
                if w then pts[i] = { ToDisc(w[1], w[2]) } end
            end
            for i = 1, n do
                local a, b = pts[i], pts[i % n + 1]
                if a and b and used < MAX_LINES then
                    local x1, y1, x2, y2 = Clip(a[1], a[2], b[1], b[2])
                    if x1 then
                        used = used + 1
                        local line = Line(used)
                        line:SetStartPoint("CENTER", frame, x1 * half, -y1 * half)
                        line:SetEndPoint("CENTER", frame, x2 * half, -y2 * half)
                        line:Show()
                    end
                end
            end
        end
    end
    for i = used + 1, #lines do lines[i]:Hide() end

    -- North up: the arrow shows where the player faces.
    if not db.rotate and GetPlayerFacing then
        arrow:SetRotation(GetPlayerFacing() or 0)
    else
        arrow:SetRotation(0)
    end
end

-- ---- the frame ----------------------------------------------------------------

local function Build()
    frame = CreateFrame("Frame", "FarmMapRadar", UIParent)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("BACKGROUND")
    frame:EnableMouse(false)

    disc = frame:CreateTexture(nil, "BACKGROUND")
    disc:SetAllPoints()
    disc:SetColorTexture(0, 0, 0, 1)
    local mask = frame:CreateMaskTexture()
    mask:SetAllPoints(disc)
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    disc:AddMaskTexture(mask)

    arrow = frame:CreateTexture(nil, "OVERLAY")
    arrow:SetSize(28, 28)
    arrow:SetPoint("CENTER")
    arrow:SetTexture("Interface\\Minimap\\MinimapArrow")

    frame:SetScript("OnUpdate", function(_, dt)
        elapsed = elapsed + dt
        cacheAge = cacheAge + dt
        if elapsed < TICK then return end
        elapsed = 0
        Redraw()
    end)
end

function Radar.Apply()
    local db = DB()
    if not frame then
        if not db.shown then return end
        Build()
    end
    frame:SetSize(db.size, db.size)
    disc:SetAlpha(db.alpha / 100)
    cacheAge = CACHE_TICK   -- read the nodes again at once
    frame:SetShown(db.shown)
end

function Radar.Command(args)
    local db = DB()
    local key, value = args:match("^(%a+)%s*(%d*)$")
    value = tonumber(value)
    if args == "" then
        db.shown = not db.shown
    elseif key == "range" and value then
        db.range = math.max(20, math.min(1000, value))
    elseif key == "size" and value then
        db.size = math.max(100, math.min(1000, value))
    elseif key == "alpha" and value then
        db.alpha = math.max(0, math.min(100, value))
    elseif key == "rotate" then
        db.rotate = not db.rotate
    else
        print("|cffffd100FarmMap|r radar: /fm radar [range N | size N | alpha N | rotate]")
        return
    end
    print(("|cffffd100FarmMap|r radar: %s, range %d yd, size %d px, %s, disc %d%%"):format(
        db.shown and "on" or "off", db.range, db.size,
        db.rotate and "turns with you" or "north up", db.alpha))
    Radar.Apply()
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function() Radar.Apply() end)
