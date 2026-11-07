-- ============================================================
--  FarmMap — Sharing in chat (2.4, PROTOTYPE)
--  The way WeakAuras shares an aura: the player puts a short text in the
--  chat ("[FarmMap: Elwynn Forest (42) #a1b2c]"), never the data itself.
--  On the clients that run FarmMap, that text becomes a link; a click asks
--  the sender for the nodes over an addon whisper, they arrive in pieces,
--  and the usual import preview opens. The sender must still be online.
--
--  The link itself cannot carry anything: the "addon" link type is local
--  only (Blizzard strips it from what is sent), hence the text that every
--  FarmMap turns back into a link on arrival.
-- ============================================================

local _, ns = ...

local Share = {}
ns.Share = Share

local function L(key) return ns.L[key] or key end

local PREFIX    = "FarmMapShare"
local CHUNK     = 240     -- bytes of data per addon message (limit 255)
local PACE      = 0.3     -- seconds between two pieces: ~800 bytes a second,
                          -- what ChatThrottleLib keeps to so nothing is dropped
local TIMEOUT   = 10      -- seconds without any answer to a request
local MAX_PARTS = 5000    -- a share bigger than ~1.2 MB is refused on arrival
local LINK_COLOR = "ff6cb6ff"

local shares   = {}       -- [id] = { data =, label = }: this session's own shares
local incoming = {}       -- [id] = { from =, parts =, n =, got =, label = }
local queue    = {}       -- pieces waiting to be sent: { target =, msg = }
local ticker

local ChatOpen   = (ChatFrameUtil and ChatFrameUtil.OpenChat) or ChatFrame_OpenChat
local AddFilter  = (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter) or ChatFrame_AddMessageEventFilter

local function Say(text) print("|cffffd100FarmMap :|r " .. text) end

-- Newlines matter in an export (its first line is a comment): escaped so a
-- piece of addon message never carries one.
local function Encode(s) return (s:gsub("~", "~~"):gsub("\n", "~n")) end
local function Decode(s) return (s:gsub("~(.)", function(c) return c == "n" and "\n" or c end)) end

-- ---- sending ------------------------------------------------------------------

local function Pump()
    local item = queue[1]
    if not item then
        ticker:Cancel()
        ticker = nil
        return
    end
    local ok, result = pcall(C_ChatInfo.SendAddonMessage, PREFIX, item.msg, "WHISPER", item.target)
    -- Retail answers with an enum (0 = sent), the Classic clients with a
    -- boolean or nothing. Anything else (throttled): the same piece next tick.
    if ok and (result == nil or result == true or result == 0) then
        table.remove(queue, 1)
    end
end

local function Queue(target, msg)
    queue[#queue + 1] = { target = target, msg = msg }
    if not ticker then ticker = C_Timer.NewTicker(PACE, Pump) end
end

local function SendShare(id, target)
    local s = shares[id]
    if not s then
        Queue(target, "E|" .. id .. "|gone")
        return
    end
    local data = Encode(s.data)
    local n = math.ceil(#data / CHUNK)
    Queue(target, ("M|%s|%d|%s"):format(id, n, s.label))
    for i = 1, n do
        Queue(target, ("D|%s|%d|%s"):format(id, i, data:sub((i - 1) * CHUNK + 1, i * CHUNK)))
    end
    Say(L("SHARE_SENDING"):format(s.label, Ambiguate(target, "none"),
        math.max(1, math.ceil(n * PACE))))
end

-- ---- the share text -----------------------------------------------------------

-- Zone name and node count of a share; mapID nil = the whole database.
local function Describe(mapID)
    local count = 0
    for key, list in pairs(FarmMapDB) do
        if type(key) == "number" and type(list) == "table" and (not mapID or key == mapID) then
            count = count + #list
        end
    end
    local name = mapID and C_Map.GetMapInfo(mapID) and C_Map.GetMapInfo(mapID).name
    return (name or L("SHARE_ALL_LABEL")), count
end

-- Puts the share text in the chat input: the player sends it wherever they
-- like (guild, trade, whisper...), like any message.
function Share.Start(mapID)
    local name, count = Describe(mapID)
    if count == 0 then
        Say(L("SHARE_EMPTY"))
        return
    end
    local id = ("%x"):format(math.random(0x10000, 0xfffff))
    local label = ("%s (%d)"):format(name, count)
    shares[id] = { data = ns.SerializeNodes(mapID), label = label }
    ChatOpen(("[FarmMap: %s #%s]"):format(label, id))
end

-- ---- receiving: the text becomes a link ------------------------------------

local CHAT_EVENTS = {
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
    "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_CHANNEL",
}

local function Filter(_, event, msg, author, ...)
    -- Midnight hides some chat from addons (secret values): left alone.
    if type(msg) ~= "string" or (issecretvalue and issecretvalue(msg)) then return false end
    if not msg:find("[FarmMap: ", 1, true) then return false end
    -- A whisper we sent names the receiver as its author: the share is ours.
    local from = event == "CHAT_MSG_WHISPER_INFORM" and UnitName("player") or author
    local new = msg:gsub("%[FarmMap: ([^%]#]+) #(%x+)%]", function(label, id)
        return ("|Haddon:FarmMapShare:%s:%s|h|c%s[FarmMap: %s]|r|h"):format(from, id, LINK_COLOR, label)
    end)
    return false, new, author, ...
end

for _, event in ipairs(CHAT_EVENTS) do AddFilter(event, Filter) end

-- A click on the link: ask its sender for the nodes.
local function OnLink(_, link)
    local from, id = tostring(link):match("^addon:FarmMapShare:([^:]+):(%x+)$")
    if not from then return end
    if shares[id] or Ambiguate(from, "none") == UnitName("player") then
        Say(L("SHARE_OWN"))
        return
    end
    if incoming[id] then return end   -- already on its way
    incoming[id] = { from = from, parts = {}, got = 0 }
    Queue(from, "R|" .. id)
    Say(L("SHARE_REQUEST"):format(Ambiguate(from, "none")))
    C_Timer.After(TIMEOUT, function()
        local inc = incoming[id]
        if inc and not inc.n then
            incoming[id] = nil
            Say(L("SHARE_NO_ANSWER"):format(Ambiguate(from, "none")))
        end
    end)
end
EventRegistry:RegisterCallback("SetItemRef", OnLink, Share)

-- ---- the addon whisper ------------------------------------------------------

local function OnAddonMessage(prefix, msg, _, sender)
    if prefix ~= PREFIX or type(msg) ~= "string" then return end
    local kind, id, rest = msg:match("^(%a)|(%x+)|?(.*)$")
    if not kind then return end
    if kind == "R" then
        SendShare(id, sender)
        return
    end
    -- Only what was asked for: nobody can push nodes unrequested.
    local inc = incoming[id]
    if not inc then return end
    if kind == "E" then
        incoming[id] = nil
        Say(L("SHARE_GONE"))
    elseif kind == "M" then
        local n, label = rest:match("^(%d+)|(.*)$")
        n = tonumber(n)
        if not n or n < 1 or n > MAX_PARTS then
            incoming[id] = nil
            return
        end
        inc.n, inc.label = n, label
        Say(L("SHARE_RECEIVING"):format(label, Ambiguate(sender, "none"),
            math.max(1, math.ceil(n * PACE))))
    elseif kind == "D" and inc.n then
        local i, piece = rest:match("^(%d+)|(.*)$")
        i = tonumber(i)
        if not i or i < 1 or i > inc.n or inc.parts[i] then return end
        inc.parts[i] = piece
        inc.got = inc.got + 1
        if inc.got == inc.n then
            incoming[id] = nil
            Say(L("SHARE_DONE"))
            ns.OptionsWindow.ImportFromText(Decode(table.concat(inc.parts)), Ambiguate(sender, "none"))
        end
    end
end

C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
local events = CreateFrame("Frame")
events:RegisterEvent("CHAT_MSG_ADDON")
events:SetScript("OnEvent", function(_, _, ...) OnAddonMessage(...) end)
