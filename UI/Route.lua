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

-- ---- the loop ---------------------------------------------------------------

local cache = {}   -- [mapID] = { sig =, loop = { nodes in order }, total =, length = }

-- What a loop depends on: the zone's node count and the filters.
local function Signature(mapID)
    local list = FarmMapDB[mapID]
    return table.concat({ type(list) == "table" and #list or 0,
        tostring(FarmMapDB.showHerbo), tostring(FarmMapDB.showMinage),
        tostring(FarmMapDB.showPeche), tostring(FarmMapDB.showBois) }, ":")
end

local function Build(mapID)
    local nodes = {}
    local list = FarmMapDB[mapID]
    for _, node in ipairs(type(list) == "table" and list or {}) do
        if ns.ShouldShowNode(node.type) then nodes[#nodes + 1] = node end
    end
    local total = #nodes
    if total > MAX_NODES then
        local count = {}
        for _, node in ipairs(nodes) do count[node] = ns.NodeHarvests(mapID, node) end
        table.sort(nodes, function(a, b) return count[a] > count[b] end)
        for i = total, MAX_NODES + 1, -1 do nodes[i] = nil end
    end
    local n = #nodes
    if n < 2 then return { loop = nodes, total = total, length = 0 } end

    -- Distances in yards: zone coordinates are not square.
    local w, h = HBD:GetZoneSize(mapID)
    if not w or w <= 0 or not h or h <= 0 then w, h = 1000, 1000 end
    local d = {}
    for i = 1, n do
        d[i] = {}
        for j = 1, n do
            local dx, dy = (nodes[i].x - nodes[j].x) * w, (nodes[i].y - nodes[j].y) * h
            d[i][j] = math.sqrt(dx * dx + dy * dy)
        end
    end

    -- Start from the node closest to the player when the player is here.
    local start = 1
    local px, py, pmap = HBD:GetPlayerZonePosition()
    if pmap == mapID and px then
        local best = math.huge
        for i, node in ipairs(nodes) do
            local dx, dy = (node.x - px) * w, (node.y - py) * h
            local dd = dx * dx + dy * dy
            if dd < best then best, start = dd, i end
        end
    end

    -- Nearest neighbour.
    local order, used = { start }, { [start] = true }
    for _ = 2, n do
        local last, best, bi = order[#order], math.huge, nil
        for j = 1, n do
            if not used[j] and d[last][j] < best then best, bi = d[last][j], j end
        end
        order[#order + 1] = bi
        used[bi] = true
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

-- Tooltip lines for the Route button: what the route of a map holds.
function Route.Describe(mapID)
    local r = Route.Get(mapID)
    if #r.loop < 2 then return { L("ROUTE_NONE") } end
    local lines = { L("ROUTE_INFO"):format(ns.Intl.Number(#r.loop),
                    L("UNIT_YARDS"):format(math.floor(r.length / 10 + 0.5) * 10)) }
    if r.total > #r.loop then lines[2] = L("ROUTE_CAPPED"):format(#r.loop) end
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

function Route.Toggle()
    FarmMapDB.routeShown = not FarmMapDB.routeShown or nil
    Route.Refresh()
    if Guiding() then GuideNearest() elseif not FarmMapDB.routeShown then StopGuiding() end
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
end

-- A new zone: the minimap shows that zone's route.
local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
events:SetScript("OnEvent", function() UpdateMinimap() end)
