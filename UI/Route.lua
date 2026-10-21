-- ============================================================
--  FarmMap — optimal route (2.2)
--
--  A loop through the known nodes of a zone, for the filters that are on:
--  drawn on the world map (solid line in the theme's accent, small arrows
--  for the direction) and as dots on the minimap. Shown with the Route
--  button of the filter bar (FarmMapDB.routeShown). With "Guide me along
--  the route" (FarmMapDB.routeGuide, off by default), each harvest of a
--  route node moves the TomTom / WaypointUI waypoint to the next node;
--  Shift-click on the button skips a node someone else already took.
--
--  The loop: nearest neighbour from the node closest to the player, then
--  2-opt (swap two segments while it shortens the loop). Over 200 nodes,
--  only the 200 most harvested are kept: a readable loop through the good
--  spots. Built once per zone and filter set, not on every frame.
-- ============================================================

local _, ns = ...

local Route = {}
ns.Route = Route

local HBD     = LibStub("HereBeDragons-2.0")
local HBDPins = LibStub("HereBeDragons-Pins-2.0")

local MAX_NODES     = 200
local MAX_PASSES    = 25      -- 2-opt passes; each one scans every pair once
local MINIMAP_STEP  = 15      -- yards between two dots on the minimap
local MINIMAP_RANGE = 400     -- dots only this far around the player (the minimap shows less)
local REBUILD_MOVE  = 100     -- yards moved before the dots are placed again
local MAX_DOTS      = 400
local LINE_PX       = 2.5     -- on screen, whatever the map's zoom
local OUTLINE_PX    = 5
local ARROW_PX      = 7
local MINIMAP_REF   = "FarmMapRoute"   -- its own HBD key: node pins are untouched

local function L(key) return ns.L[key] or key end

-- The zone a sub-zone (a town, a cave) belongs to: the player is often on
-- such a smaller map while the route lives on the zone's. The minimap
-- showed the route only now and then because of this (Kroosstii,
-- 2026-10-22).
local ZONE_TYPE = Enum and Enum.UIMapType and Enum.UIMapType.Zone or 3
local function ZoneOf(mapID)
    local data, id = HBD.mapData, mapID
    while data[id] and data[id].mapType ~= ZONE_TYPE and (data[id].parent or 0) > 0 do
        id = data[id].parent
    end
    if data[id] and data[id].mapType == ZONE_TYPE then return id end
    return mapID
end

-- ---- speed: lap time and time limit ------------------------------------------
--
-- An estimate, said as one: the loop's length at a speed, plus a few
-- seconds per node for the harvest. The speed starts as a ground mount's
-- and becomes the player's own, measured while the route is shown (only
-- while moving: stops are counted by the harvest time already).

local BASE_SPEED   = 14     -- yards per second, a ground mount (100% bonus)
local HARVEST_TIME = 3      -- seconds per node: cast and loot
local MIN_SAMPLES  = 20     -- half-second samples before trusting the measure
local NO_LIMIT     = 61     -- the time slider's last step: no limit (65 before, read the same)

local function Speed()
    local s = FarmMapDB.routeSpeed
    if s and s.n >= MIN_SAMPLES then return s.v, true end
    return BASE_SPEED, false
end

local function LapSeconds(length, count)
    return length / Speed() + count * HARVEST_TIME
end

-- The longest lap the player allows, in seconds (nil: no limit).
local function Budget()
    local m = tonumber(FarmMapDB.routeMaxMinutes)
    if not m or m >= NO_LIMIT then return nil end
    return m * 60
end

-- ---- the loop ---------------------------------------------------------------

local cache = {}    -- [mapID] = { sig =, loop = { nodes in order }, total =, length = }
local offered = {}  -- [mapID] = { [edge key] = true }: loops "Another route" already gave

-- 0 = the route built from the player's position; each "Another route"
-- moves the zone to the next variant (saved, so the route stays after a
-- reload).
local function Variant(mapID)
    return FarmMapDB.routeVariant and FarmMapDB.routeVariant[mapID] or 0
end

-- What a loop depends on: the zone's node count, the filters and the
-- route's own settings.
local function Signature(mapID)
    local list = FarmMapDB[mapID]
    return table.concat({ type(list) == "table" and #list or 0,
        tostring(FarmMapDB.showHerbo), tostring(FarmMapDB.showMinage),
        tostring(FarmMapDB.showPeche), tostring(FarmMapDB.showBois),
        tostring(FarmMapDB.routeReverse), tostring(FarmMapDB.routeMaxMinutes),
        Variant(mapID) }, ":")
end

-- The zone's nodes the filters show, most harvested first, at most
-- MAX_NODES. Returns them and how many there were before the cut.
local function Candidates(mapID)
    local nodes, count = {}, {}
    local list = FarmMapDB[mapID]
    for i, node in ipairs(type(list) == "table" and list or {}) do
        if ns.ShouldShowNode(node.type) then
            nodes[#nodes + 1] = node
            count[node] = ns.NodeHarvests(mapID, node) * 100000 - i   -- ties: older first
        end
    end
    table.sort(nodes, function(a, b) return count[a] > count[b] end)
    local total = #nodes
    for i = total, MAX_NODES + 1, -1 do nodes[i] = nil end
    return nodes, total
end

-- A repeatable random sequence (Park-Miller) for a variant.
local function Random(seed)
    local s = seed * 7919 % 2147483646 + 1
    return function()
        s = s * 16807 % 2147483647
        return s / 2147483647
    end
end

-- One loop through `nodes` (two or more). Variant 0 starts from the node
-- nearest the player and always takes the nearest next node; a variant
-- starts elsewhere and picks among the three nearest at each step, for
-- a loop of another shape. Then 2-opt either way.
local function Solve(nodes, w, h, mapID, variant)
    local n = #nodes
    local d = {}
    for i = 1, n do
        d[i] = {}
        for j = 1, n do
            local dx, dy = (nodes[i].x - nodes[j].x) * w, (nodes[i].y - nodes[j].y) * h
            d[i][j] = math.sqrt(dx * dx + dy * dy)
        end
    end

    local rand = variant > 0 and Random(variant) or nil
    local start = 1
    if rand then
        start = math.floor(rand() * n) + 1
    else
        local px, py, pmap = HBD:GetPlayerZonePosition()
        if px and ZoneOf(pmap) == mapID then
            local best = math.huge
            for i, node in ipairs(nodes) do
                local dx, dy = (node.x - px) * w, (node.y - py) * h
                local dd = dx * dx + dy * dy
                if dd < best then best, start = dd, i end
            end
        end
    end

    -- Nearest neighbour (one of the three nearest, for a variant).
    local order, used = { start }, { [start] = true }
    for _ = 2, n do
        local last = order[#order]
        local near = {}
        for j = 1, n do
            if not used[j] then
                local k = #near + 1
                near[k] = j
                -- Keep the three nearest, sorted.
                while k > 1 and d[last][near[k]] < d[last][near[k - 1]] do
                    near[k], near[k - 1] = near[k - 1], near[k]
                    k = k - 1
                end
                if #near > 3 then near[4] = nil end
            end
        end
        local pick = near[1]
        if rand and #near > 1 then pick = near[math.floor(rand() * #near) + 1] end
        order[#order + 1] = pick
        used[pick] = true
    end

    -- 2-opt: reverse a stretch whenever that shortens the loop.
    for _ = 1, MAX_PASSES do
        local improved = false
        for i = 1, n - 2 do
            for k = i + 2, n do
                local a, b, c = order[i], order[i + 1], order[k]
                local e = order[k % n + 1]
                if a ~= e and d[a][c] + d[b][e] < d[a][b] + d[c][e] - 0.01 then
                    local lo, hi = i + 1, k
                    while lo < hi do
                        order[lo], order[hi] = order[hi], order[lo]
                        lo, hi = lo + 1, hi - 1
                    end
                    improved = true
                end
            end
        end
        if not improved then break end
    end

    local loop, length = {}, 0
    for i, idx in ipairs(order) do
        loop[i] = nodes[idx]
        length = length + d[idx][order[i % n + 1]]
    end
    return loop, length
end

-- A fixed direction, clockwise unless the player reverses it (options,
-- session window): a rebuilt loop (a new node) used to come out the other
-- way round and the guidance sent the player back (Kroosstii, 2026-10-22).
-- Signed area with y growing downwards: positive = clockwise on screen.
local function Orient(loop, w, h)
    local n, area = #loop, 0
    for i = 1, n do
        local a, b = loop[i], loop[i % n + 1]
        area = area + (a.x * w) * (b.y * h) - (b.x * w) * (a.y * h)
    end
    if (area > 0) ~= (not FarmMapDB.routeReverse) then
        -- Same start, the other way round.
        for i = 2, math.floor(n / 2) + 1 do
            local j = n + 2 - i
            if i < j then loop[i], loop[j] = loop[j], loop[i] end
        end
    end
end

local function Build(mapID)
    local nodes, total = Candidates(mapID)
    if #nodes < 2 then return { loop = nodes, total = total, length = 0 } end
    -- Distances in yards: zone coordinates are not square.
    local w, h = HBD:GetZoneSize(mapID)
    if not w or w <= 0 or not h or h <= 0 then w, h = 1000, 1000 end
    local variant = Variant(mapID)
    local loop, length = Solve(nodes, w, h, mapID, variant)

    -- Longest lap allowed: the most nodes that fit, most harvested first
    -- (they come first in `nodes`). Binary search on how many to keep.
    local budget = Budget()
    if budget and LapSeconds(length, #loop) > budget then
        local lo, hi, fit = 2, #nodes - 1, nil
        while lo <= hi do
            local k = math.floor((lo + hi) / 2)
            local l, len = Solve({ unpack(nodes, 1, k) }, w, h, mapID, variant)
            if LapSeconds(len, k) <= budget then
                fit, lo = { l, len }, k + 1
            else
                hi = k - 1
            end
        end
        -- Even two nodes are too far apart: the two best, all the same.
        if fit then
            loop, length = fit[1], fit[2]
        else
            loop, length = Solve({ nodes[1], nodes[2] }, w, h, mapID, variant)
        end
    end
    Orient(loop, w, h)
    return { loop = loop, total = total, length = length }
end

-- The loop of a zone, rebuilt only when its nodes or the filters changed.
function Route.Get(mapID)
    if not (mapID and FarmMapDB) then return { loop = {}, total = 0, length = 0 } end
    local sig = Signature(mapID)
    local r = cache[mapID]
    if not r or r.sig ~= sig then
        r = Build(mapID)
        r.sig = sig
        cache[mapID] = r
    end
    return r
end

-- ---- measuring the player's speed ----------------------------------------------

local lastPos   -- { x, y, instance } at the previous sample

local function SampleSpeed(dt)
    local px, py, instance = HBD:GetPlayerWorldPosition()
    if not px then lastPos = nil return end
    local prev = lastPos
    lastPos = { px, py, instance }
    if not prev or prev[3] ~= instance then return end
    local speed = HBD:GetWorldDistance(instance, prev[1], prev[2], px, py) / dt
    -- Standing still, or a teleport / flight path jump: not a riding speed.
    if not speed or speed < 2 or speed > 120 then return end
    local s = FarmMapDB.routeSpeed or { v = speed, n = 0 }
    s.v = s.v * 0.95 + speed * 0.05
    s.n = s.n + 1
    FarmMapDB.routeSpeed = s
end

local function LapText(r)
    local _, measured = Speed()
    local m = math.max(1, math.floor(LapSeconds(r.length, #r.loop) / 60 + 0.5))
    local time = m < 60 and L("UI_DUR_MIN"):format(m) or L("UI_DUR_H"):format(math.floor(m / 60), m % 60)
    return L("ROUTE_TIME"):format(time, L(measured and "ROUTE_SPEED_MEASURED" or "ROUTE_SPEED_BASE"))
end

-- The zone the player farms (a sub-zone counts as its zone).
function Route.PlayerZone()
    local mapID = HBD:GetPlayerZone()
    return mapID and ZoneOf(mapID)
end

-- A lap of a zone's route in minutes, nil without a route there (the
-- session window shows it).
function Route.LapMinutes(mapID)
    local r = Route.Get(mapID)
    if #r.loop < 2 then return nil end
    return math.max(1, math.floor(LapSeconds(r.length, #r.loop) / 60 + 0.5))
end

-- Tooltip lines for the Route button: what the route of a map holds.
function Route.Describe(mapID)
    local r = Route.Get(mapID)
    if #r.loop < 2 then return { L("ROUTE_NONE") } end
    local lines = { L("ROUTE_INFO"):format(ns.Intl.Number(#r.loop),
                    L("UNIT_YARDS"):format(math.floor(r.length / 10 + 0.5) * 10)),
                    LapText(r),
                    L(FarmMapDB.routeReverse and "ROUTE_DIR_CCW" or "ROUTE_DIR_CW") }
    if r.total > #r.loop then lines[#lines + 1] = L("ROUTE_CAPPED"):format(#r.loop) end
    return lines
end

-- ---- the world map ------------------------------------------------------------

local provider = CreateFromMixins(MapCanvasDataProviderMixin)

function provider:OnAdded(map)
    MapCanvasDataProviderMixin.OnAdded(self, map)
    self.frame = CreateFrame("Frame", nil, map:GetCanvas())
    self.frame:SetAllPoints()
    self.lines, self.used = {}, 0
end

function provider:RemoveAllData()
    for i = 1, self.used do self.lines[i]:Hide() end
    self.used = 0
end

-- One segment, from the canvas's top-left corner (y grows downwards).
function provider:Line(sublayer, thickness, r, g, b, a, x1, y1, x2, y2)
    self.used = self.used + 1
    local line = self.lines[self.used]
    if not line then
        line = self.frame:CreateLine(nil, "ARTWORK")
        self.lines[self.used] = line
    end
    line:SetDrawLayer("ARTWORK", sublayer)
    line:SetThickness(thickness)
    line:SetColorTexture(r, g, b, a)
    line:SetStartPoint("TOPLEFT", self.frame, x1, -y1)
    line:SetEndPoint("TOPLEFT", self.frame, x2, -y2)
    line:Show()
end

function provider:RefreshAllData()
    self:RemoveAllData()
    if not (FarmMapDB and FarmMapDB.routeShown) then return end
    local map = self:GetMap()
    local r = Route.Get(map:GetMapID())
    local loop, n = r.loop, #r.loop
    if n < 2 then return end
    -- Above the map's own art, under every pin.
    self.frame:SetFrameLevel(map:GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_MAP_HIGHLIGHT"))
    local canvas = map:GetCanvas()
    local W, H = canvas:GetWidth(), canvas:GetHeight()
    -- The canvas is scaled when zooming: widths divided by that scale keep
    -- the same width on screen.
    local scale = map:GetCanvasScale() or 1
    local thick, outline, arrow = LINE_PX / scale, OUTLINE_PX / scale, ARROW_PX / scale
    local cr, cg, cb = ns.Theme.RGB("accent")
    for i = 1, n do
        local a, b = loop[i], loop[i % n + 1]
        local x1, y1, x2, y2 = a.x * W, a.y * H, b.x * W, b.y * H
        self:Line(0, outline, 0, 0, 0, 0.45, x1, y1, x2, y2)
        self:Line(1, thick, cr, cg, cb, 0.95, x1, y1, x2, y2)
        -- The direction, at the middle of each segment long enough for it.
        local dx, dy = x2 - x1, y2 - y1
        local len = math.sqrt(dx * dx + dy * dy)
        if len > arrow * 6 then
            local ux, uy = dx / len, dy / len
            local mx, my = (x1 + x2) / 2 + ux * arrow * 0.5, (y1 + y2) / 2 + uy * arrow * 0.5
            -- Two strokes back from the tip, 35 degrees either side.
            local c, s = math.cos(math.rad(35)), math.sin(math.rad(35))
            for _, side in ipairs({ 1, -1 }) do
                local bx = -(ux * c - side * uy * s) * arrow
                local by = -(uy * c + side * ux * s) * arrow
                self:Line(2, thick, cr, cg, cb, 0.95, mx, my, mx + bx, my + by)
            end
        end
    end
end

function provider:OnCanvasScaleChanged() self:RefreshAllData() end

WorldMapFrame:AddDataProvider(provider)

-- ---- the minimap ------------------------------------------------------------------

local dots = {}

local function Dot(i)
    local dot = dots[i]
    if dot then return dot end
    dot = CreateFrame("Frame")
    dot:SetSize(5, 5)
    local tex = dot:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints()
    tex:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")   -- a white disc
    ns.Theme.Track(tex, function(self) self:SetVertexColor(ns.Theme.RGBA("accent", 0.9)) end)
    dots[i] = dot
    return dot
end

-- The route's dots in FarmMap's proximity list (fiote's "hide nearby
-- pins"): the ones close to the player fade like the node pins, so the
-- nodes under the route stay visible. Taken out before each rebuild.
local function Unlist()
    local list = ns.MinimapProximity.pins
    for i = #list, 1, -1 do
        if list[i].farmMapRouteDot then table.remove(list, i) end
    end
end

local built   -- where the dots were last placed: { x =, y =, instance = }

-- Dots every MINIMAP_STEP yards along the route of the player's zone,
-- within MINIMAP_RANGE yards of the player only: a whole long loop came
-- out cut short at the old cap. Placed in world coordinates, so they show
-- in the zone's sub-zones too; HereBeDragons rotates and zooms them with
-- the minimap. Rebuilt as the player moves (ticker below).
local function UpdateMinimap()
    HBDPins:RemoveAllMinimapIcons(MINIMAP_REF)
    Unlist()
    built = nil
    if not (FarmMapDB and FarmMapDB.routeShown) then return end
    local px, py, instance = HBD:GetPlayerWorldPosition()
    local mapID = HBD:GetPlayerZone()
    if not (px and mapID) then return end
    local zone = ZoneOf(mapID)
    local r = Route.Get(zone)
    if #r.loop < 2 and zone ~= mapID then zone, r = mapID, Route.Get(mapID) end
    local loop, n = r.loop, #r.loop
    if n < 2 then return end
    built = { x = px, y = py, instance = instance }

    local pts = {}
    for i, node in ipairs(loop) do
        local wx, wy, inst = HBD:GetWorldCoordinatesFromZone(node.x, node.y, zone)
        if not wx or inst ~= instance then return end
        pts[i] = { wx, wy }
    end
    local range2, k = MINIMAP_RANGE * MINIMAP_RANGE, 0
    local list = ns.MinimapProximity.pins
    for i = 1, n do
        local a, b = pts[i], pts[i % n + 1]
        local dx, dy = b[1] - a[1], b[2] - a[2]
        local steps = math.floor(math.sqrt(dx * dx + dy * dy) / MINIMAP_STEP)
        -- Not on the nodes themselves: their own pins are there.
        for s = 1, steps - 1 do
            local x, y = a[1] + dx * s / steps, a[2] + dy * s / steps
            if (x - px) ^ 2 + (y - py) ^ 2 <= range2 then
                if k >= MAX_DOTS then return end
                k = k + 1
                local dot = Dot(k)
                dot.farmMapWorldX, dot.farmMapWorldY, dot.farmMapInstance = x, y, instance
                dot.farmMapRouteDot = true
                list[#list + 1] = dot
                ns.MinimapProximity.Apply(dot)
                HBDPins:AddMinimapIconWorld(MINIMAP_REF, dot, instance, x, y, false)
            end
        end
    end
end

-- Once a second: moved far enough, the dots around the player are placed
-- again. Cheap when standing still (one position read).
C_Timer.NewTicker(1, function()
    if not (FarmMapDB and FarmMapDB.routeShown) then return end
    local px, py, instance = HBD:GetPlayerWorldPosition()
    if not px then return end
    if not built or built.instance ~= instance
       or (px - built.x) ^ 2 + (py - built.y) ^ 2 > REBUILD_MOVE * REBUILD_MOVE then
        UpdateMinimap()
    end
end)

-- ---- guidance --------------------------------------------------------------------

local target   -- { mapID =, node = } the node the waypoint points at

local function GuideTo(mapID, node)
    target = { mapID = mapID, node = node }
    ns.SetWaypoint(mapID, node)
end

local function IndexOf(loop, node)
    for i, n in ipairs(loop) do if n == node then return i end end
end

local function Guiding()
    return FarmMapDB and FarmMapDB.routeShown and FarmMapDB.routeGuide == true
end

-- The route node closest to the player, in the player's zone.
local function Nearest()
    local px, py, mapID = HBD:GetPlayerZonePosition()
    if not px then return end
    local loop = Route.Get(mapID).loop
    local best, node = math.huge, nil
    for _, n in ipairs(loop) do
        local d = (n.x - px) ^ 2 + (n.y - py) ^ 2
        if d < best then best, node = d, n end
    end
    return mapID, node
end

local function GuideNearest()
    local mapID, node = Nearest()
    if node then GuideTo(mapID, node) end
end

-- The route changed under the guidance (direction, another route): the
-- waypoint goes at once to the nearest node, or past it when the player
-- stands on it - in the route's new order. It waited for the next
-- arrival before (Kroosstii, 2026-10-22).
local ARRIVAL = 30
local function GuideAhead()
    local mapID, node = Nearest()
    if not node then return end
    local px, py, instance = HBD:GetPlayerWorldPosition()
    local wx, wy, winst = HBD:GetWorldCoordinatesFromZone(node.x, node.y, mapID)
    if px and wx and instance == winst then
        local d = HBD:GetWorldDistance(instance, px, py, wx, wy)
        if d and d <= ARRIVAL then
            local loop = Route.Get(mapID).loop
            local i = IndexOf(loop, node)
            if i and #loop > 1 then node = loop[i % #loop + 1] end
        end
    end
    GuideTo(mapID, node)
end

-- Within ARRIVAL yards of the node the waypoint points at (flying over it
-- included), the waypoint moves on: an empty node or one already taken
-- no longer holds the guidance (Kroosstii, 2026-10-22). Harvesting it
-- next sends it to the same next node, so nothing is skipped. Height
-- never counts; 30 yards (ARRIVAL, above), as landing on the slope above
-- a node left the player more than 10 yards away from it.
C_Timer.NewTicker(0.5, function()
    -- The lap time learns the player's speed while the route is shown.
    if FarmMapDB and FarmMapDB.routeShown then SampleSpeed(0.5) else lastPos = nil end
    if not (target and Guiding()) then return end
    local px, py, instance = HBD:GetPlayerWorldPosition()
    local wx, wy, winst = HBD:GetWorldCoordinatesFromZone(target.node.x, target.node.y, target.mapID)
    if not (px and wx) or instance ~= winst then return end
    local d = HBD:GetWorldDistance(instance, px, py, wx, wy)
    if not (d and d <= ARRIVAL) then return end
    local loop = Route.Get(target.mapID).loop
    local i = IndexOf(loop, target.node)
    if i and #loop > 1 then GuideTo(target.mapID, loop[i % #loop + 1]) end
end)

-- ---- public ----------------------------------------------------------------------

-- Drawn again now; a loop is rebuilt only if its zone's nodes or the
-- filters changed (Signature), not on every refresh.
function Route.Refresh()
    if WorldMapFrame:IsShown() then provider:RefreshAllData() end
    UpdateMinimap()
end

-- Off: the guidance's waypoint goes with the route.
local function StopGuiding()
    target = nil
    ns.ClearRouteWaypoint()
end

-- Everything that shows the route's state follows a change.
local function Changed()
    if FarmMap_UpdateRouteButton then FarmMap_UpdateRouteButton() end
    if ns.SessionWindow then ns.SessionWindow:Update() end
    if ns.OptionsWindow then ns.OptionsWindow:Refresh() end
end

function Route.Toggle()
    FarmMapDB.routeShown = not FarmMapDB.routeShown or nil
    Route.Refresh()
    if Guiding() then GuideNearest() elseif not FarmMapDB.routeShown then StopGuiding() end
    Changed()
end

function Route.IsGuiding() return Guiding() and true or false end

-- Clockwise or anticlockwise (options, session window). The guidance
-- keeps its node; the next one follows the new direction.
function Route.SetReverse(on)
    FarmMapDB.routeReverse = on and true or nil
    Route.Refresh()
    if Guiding() then GuideAhead() end
    Changed()
end

function Route.Reverse() Route.SetReverse(not FarmMapDB.routeReverse) end

-- A slider moves many times a second: one redraw once it rests.
local refreshQueued
function Route.RefreshSoon()
    if refreshQueued then return end
    refreshQueued = true
    C_Timer.After(0.3, function()
        refreshQueued = false
        Route.Refresh()
    end)
end

-- A loop's edges, whatever its start and direction: to tell loops apart.
local function EdgeKey(loop)
    local keys, n = {}, #loop
    for i = 1, n do
        local a, b = loop[i], loop[i % n + 1]
        local ka, kb = ("%.4f,%.4f"):format(a.x, a.y), ("%.4f,%.4f"):format(b.x, b.y)
        keys[i] = ka < kb and (ka .. "-" .. kb) or (kb .. "-" .. ka)
    end
    table.sort(keys)
    return table.concat(keys, ";")
end

-- "Another route" (options, session window): the next variant of the
-- player's zone that gives a loop not offered yet. When the nodes allow
-- no new one, the variants start over (a cycle of the few loops there
-- are). Up to 4 tries: each one rebuilds the loop.
function Route.NewRoute()
    local mapID = ZoneOf(HBD:GetPlayerZone())
    if not mapID then return end
    local seen = offered[mapID] or {}
    offered[mapID] = seen
    seen[EdgeKey(Route.Get(mapID).loop)] = true
    FarmMapDB.routeVariant = FarmMapDB.routeVariant or {}
    local v, fresh = Variant(mapID), false
    for _ = 1, 4 do
        v = v + 1
        FarmMapDB.routeVariant[mapID] = v
        local key = EdgeKey(Route.Get(mapID).loop)
        if not seen[key] then
            seen[key], fresh = true, true
            break
        end
    end
    if not fresh then offered[mapID] = nil end   -- all seen: a new cycle
    Route.Refresh()
    if Guiding() then GuideAhead() end
    Changed()
end

-- The guidance turned on or off in one click (a pin's right-click menu,
-- the session window): on, the route is shown too, and the waypoint goes
-- to `node` when given (the pin clicked), else to the nearest route node.
function Route.Guide(on, mapID, node)
    FarmMapDB.routeGuide = on and true or false
    if on then
        if not FarmMapDB.routeShown then
            FarmMapDB.routeShown = true
            Route.Refresh()
        end
        if node then GuideTo(mapID, node) else GuideNearest() end
    else
        StopGuiding()
    end
    Changed()
end

-- Shift-click: the waypoint moves on to the next node of the loop.
function Route.Skip()
    if not Guiding() then return end
    if target then
        local loop = Route.Get(target.mapID).loop
        local i = IndexOf(loop, target.node)
        if i then return GuideTo(target.mapID, loop[i % #loop + 1]) end
    end
    GuideNearest()
end

-- After each harvest (FarmMap.lua): a new node joins the loop; a route
-- node, with the guidance on, sends the waypoint to the next one.
function Route.OnHarvest(mapID, node, isNew)
    if isNew then Route.Refresh() end
    if not (Guiding() and node) then return end
    local loop = Route.Get(mapID).loop
    local i = IndexOf(loop, node)
    if i and #loop > 1 then GuideTo(mapID, loop[i % #loop + 1]) end
end

-- The guidance switch (options): turning it on points at the nearest node.
function Route.SetGuide(on)
    FarmMapDB.routeGuide = on and true or false
    if Guiding() then GuideNearest() elseif not on then StopGuiding() end
    if ns.SessionWindow then ns.SessionWindow:Update() end
end

-- A new zone: the minimap shows that zone's route.
local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
events:SetScript("OnEvent", function() UpdateMinimap() end)
