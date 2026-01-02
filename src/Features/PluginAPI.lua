-- Features/PluginAPI.lua
local OutputStream = require(script.Parent.Parent.OutputStream)

local PluginAPI = {}
PluginAPI.command = "pluginapi.register"
PluginAPI.flags = { command=true, perm=true }
PluginAPI.description = [[Register a new third-party command {cmd,modulePath} (permitted by GuardBL admin).]]

local CommandRegistry = require(script.Parent.Parent.CommandRegistry)
local allowed = {}  -- Add access logic here, or use attribute/role

function PluginAPI.run(ast, frame, context)
    local cmdName = ast.flags.command or ast.args[1]
    local modulePath = ast.args[2]
    if not cmdName or not modulePath then
        OutputStream.Append(frame, "Usage: pluginapi.register mycmd path.to.ModuleScript", Color3.fromRGB(255,120,90))
        return
    end
    if not allowed[context.UserId or 0] and not ast.flags.perm then
        OutputStream.Append(frame, "You do not have permission to register commands.", Color3.fromRGB(240,120,120))
        return
    end
    -- Try to load and register 3rd-party command dynamically
    local mod = nil
    local success, err = pcall(function()
        local at = script.Parent.Parent
        for seg in modulePath:gmatch("[^%.]+") do
            at = at:FindFirstChild(seg)
            if not at then break end
        end
        if at then mod = require(at) end
    end)
    if not mod or not mod.command then
        OutputStream.Append(frame, "Module not found or invalid!", Color3.fromRGB(255,110,60))
        return
    end
    CommandRegistry.Register(mod.command, mod)
    OutputStream.Append(frame, ("Third-party command '%s' registered!"):format(mod.command), Color3.fromRGB(120,255,180))
end
return PluginAPI