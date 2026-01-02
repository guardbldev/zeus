-- CommandParser.lua
-- Complete parser & autocomplete engine for CLI commands in Roblox Studio plugin

local Selection = game:GetService("Selection")
local HttpService = game:GetService("HttpService")

local CommandParser = {}

-- Regex util for splitting
local function splitArgs(input)
    local args = {}
    local i, len = 1, #input
    local cur, inQuote, esc = "", false, false
    while i <= len do
        local c = input:sub(i,i)
        if esc then
            cur = cur .. c
            esc = false
        elseif c == "\\" then
            esc = true
        elseif c == '"' or c == "'" then
            if inQuote == c then
                inQuote = false
            elseif not inQuote then
                inQuote = c
            else
                cur = cur .. c
            end
        elseif c == " " and not inQuote then
            if cur~="" then table.insert(args, cur) cur="" end
        else
            cur = cur .. c
        end
        i = i + 1
    end
    if cur~="" then table.insert(args, cur) end
    return args
end

-- AST builder
function CommandParser.Parse(input)
    local tokens = splitArgs(input)
    if #tokens == 0 then return nil end
    local ast = {
        raw = input,
        command = tokens[1],
        subcommand = nil,
        flags = {},
        args = {},
    }
    local i = 2
    while i <= #tokens do
        local tok = tokens[i]
        if tok:sub(1,2) == "--" then
            local eq = tok:find("=")
            if eq then
                local name,val = tok:sub(3,eq-1),tok:sub(eq+1)
                ast.flags[name] = val
            else
                local name = tok:sub(3)
                -- check if next is value
                if tokens[i+1] and tokens[i+1]:sub(1,2) ~= "--" then
                    ast.flags[name] = tokens[i+1]
                    i = i + 1
                else
                    ast.flags[name] = true
                end
            end
        elseif not ast.subcommand and not tok:find("=") then
            ast.subcommand = tok
        else
            table.insert(ast.args, tok)
        end
        i = i + 1
    end
    return ast
end

-- very basic fuzzy matcher (returns best-match+score)
local function fuzzyScore(input, option)
    local s, o = 1, 1
    while s<=#input and o<=#option do
        if input:sub(s,s):lower() == option:sub(o,o):lower() then
            s = s+1
        end
        o = o+1
    end
    return s-1
end

-- Get autocomplete suggestions
function CommandParser.Autocomplete(input, registry, explorerRoot)
    local tokens = splitArgs(input)
    if #tokens == 0 then
        -- suggest commands
        local all = {}
        for k in pairs(registry) do
            table.insert(all, {val=k,score=0})
        end
        table.sort(all, function(a,b) return a.val < b.val end)
        return all
    end
    if #tokens == 1 or (tokens[#tokens] == "") then
        -- first token (commands)
        local prefix = tokens[1]:lower()
        local options = {}
        for cmd in pairs(registry) do
            local score = fuzzyScore(prefix,cmd)
            if score > 0 or #prefix==0 then
                table.insert(options, {val=cmd,score=score})
            end
        end
        table.sort(options, function(a,b) return a.score>b.score end)
        return options
    end
    if tokens[#tokens]:sub(1,2) == "--" then
        -- flags (after command)
        local cmd = tokens[1]
        local def = registry[cmd]
        if def and type(def.flags)=="table" then
            local out = {}
            for flag in pairs(def.flags) do
                if flag:sub(1,#tokens[#tokens]-2):lower() == tokens[#tokens]:sub(3):lower() then
                    table.insert(out, {val="--"..flag,score=99})
                end
            end
            return out
        end
    end
    -- path suggestion if flag expects path (simulate simple explorer-style)
    for i=#tokens,1,-1 do
        if tokens[i]:lower():find("path") and explorerRoot then
            local path = tokens[#tokens]
            local function scan(node, prefix)
                local out = {}
                for _, child in ipairs(node:GetChildren()) do
                    local full = (prefix~="" and prefix.."/" or "")..child.Name
                    if full:lower():find(path:lower(),1,true) then
                        table.insert(out,{val=full,score=100})
                    end
                    for _,desc in ipairs(scan(child,full)) do
                        table.insert(out,desc)
                    end
                end
                return out
            end
            return scan(explorerRoot,"")
        end
    end
    return {}
end

return CommandParser