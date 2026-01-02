-- HistoryAndProfiles.lua
-- Command history and profile manager for Studio plugins, circular/persistent

local plugin = plugin or getfenv and getfenv(0).plugin -- For ModuleScript and command line testing
local HttpService = game:GetService("HttpService")
local placeId = game.GameId or 0

local keyHistory = "GBLT_History_"..placeId
local keyProfiles = "GBLT_Profiles_"..placeId
local CAP = 100

local HistoryAndProfiles = {}

local function loadSetting(key)
    if plugin and plugin:GetSetting then
        local str = plugin:GetSetting(key)
        if str then
            local ok, result = pcall(function() return HttpService:JSONDecode(str) end)
            if ok then return result end
        end
    end
    return nil
end

local function saveSetting(key, val)
    if plugin and plugin:SetSetting then
        plugin:SetSetting(key, HttpService:JSONEncode(val))
    end
end

-- ========== HISTORY ==========
local state = loadSetting(keyHistory) or {cursor=0, buffer={}, lastSearch=""}
state.cursor = state.cursor or 0
state.buffer = state.buffer or {}

function HistoryAndProfiles.Add(cmd)
    state.cursor = (state.cursor % CAP) + 1
    state.buffer[state.cursor] = {cmd=cmd, ts=os.time()}
    saveSetting(keyHistory, state)
end

function HistoryAndProfiles.List()
    local list = {}
    for i=1,CAP do
        local idx = ((state.cursor+i-1)%CAP)+1
        local entry = state.buffer[idx]
        if entry then table.insert(list, entry) end
    end
    return list
end

function HistoryAndProfiles.Search(str)
    str = str:lower()
    local out = {}
    for _,entry in ipairs(HistoryAndProfiles.List()) do
        if entry.cmd:lower():find(str,1,true) then
            table.insert(out, entry)
        end
    end
    state.lastSearch = str
    return out
end

-- ========== PROFILES ==========

local profiles = loadSetting(keyProfiles) or {}

function HistoryAndProfiles.SaveProfile(profileName, cmds)
    profiles[profileName] = cmds
    saveSetting(keyProfiles, profiles)
end

function HistoryAndProfiles.GetProfile(profileName)
    return profiles[profileName]
end

function HistoryAndProfiles.ListProfiles()
    local out = {}
    for k in pairs(profiles) do table.insert(out,k) end
    return out
end

function HistoryAndProfiles.RunProfile(profileName, commandRunner)
    local cmds = profiles[profileName]
    if not cmds then return false,"Profile not found" end
    for _,cmd in ipairs(cmds) do
        commandRunner(cmd)
    end
    return true
end

function HistoryAndProfiles.DiffProfiles(a,b)
    local first = profiles[a] or {}
    local second = profiles[b] or {}
    local diff = {}
    -- very basic: show commands in one but not other
    local setA = {}
    for _,v in ipairs(first) do setA[v]=true end
    for _,v in ipairs(second) do if not setA[v] then table.insert(diff,"+ "..v) end end
    local setB = {}
    for _,v in ipairs(second) do setB[v]=true end
    for _,v in ipairs(first) do if not setB[v] then table.insert(diff,"- "..v) end end
    return diff
end

return HistoryAndProfiles