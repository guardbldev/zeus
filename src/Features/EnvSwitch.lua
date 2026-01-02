-- Features/EnvSwitch.lua
local OutputStream = require(script.Parent.Parent.OutputStream)
local HttpService = game:GetService("HttpService")

local EnvSwitch = {}
EnvSwitch.command = "env.set"
EnvSwitch.flags = { name=true }
EnvSwitch.description = "Switch project runtime environment using config files/variables."

-- Example config loader
local function getEnvConfig(envName)
    local configMod = game:GetService("ReplicatedStorage"):FindFirstChild("GuardBL_Env_" .. envName)
    if configMod and configMod:IsA("ModuleScript") then
        local ok, decoded = pcall(function()
            return HttpService:JSONDecode(configMod.Source)
        end)
        if ok and type(decoded)=="table" then return decoded end
    end
    return nil
end

function EnvSwitch.run(ast, frame, context)
    local envName = ast.args[1] or (ast.flags.name or "default")
    local cfg = getEnvConfig(envName)
    if not cfg then
        OutputStream.Append(frame, "No config for '"..envName.."'. (ReplicatedStorage/GuardBL_Env_"..envName..")", Color3.fromRGB(255,120,90))
        return
    end

    -- Apply config (simulate: set game attributes or variables as needed)
    for k,v in pairs(cfg) do
        game:SetAttribute(k, v)
    end
    OutputStream.Append(frame, ("[env.set] Applied environment '%s' with %d vars."):format(envName, #cfg), Color3.fromRGB(120,255,190))
end
return EnvSwitch