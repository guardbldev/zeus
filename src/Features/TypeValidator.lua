-- Features/TypeValidator.lua
local OutputStream = require(script.Parent.Parent.OutputStream)

local TypeValidator = {}
TypeValidator.command = "type.check"
TypeValidator.description = "Analyze Luau function signatures and return types for consistency."

-- Rudimentary source scan for type annotations & returns
local function checkLuaTypes(src)
    local warns = {}
    for l in src:gmatch("[^\r\n]+") do
        if l:find("function[%s%w_]*%(") and l:find(":") then
            -- Probably a typed function
            local fn, ret = l:match("function%s*(%w+)%b():%s*([%w_]+)")
            if fn and not ret then
                table.insert(warns, "[WARN] Function '"..fn.."' missing return annotation.")
            end
        end
        if l:find("return%s*function") then
            table.insert(warns, "[WARN] Returning a closure directly; beware scoping issues.")
        end
    end
    if src:find("return%s*{") then
        -- Looks for return table but not type-annotated module
        table.insert(warns, "[INFO] Module returns a table (vs function/instance/class).")
    end
    return warns
end

local function findAllModules()
    local found = {}
    for _,root in ipairs({game:GetService("ReplicatedStorage"), game:GetService("ServerScriptService")}) do
        for _,desc in ipairs(root:GetDescendants()) do
            if desc:IsA("ModuleScript") then table.insert(found, desc) end
        end
    end
    return found
end

function TypeValidator.run(ast, frame, context)
    local modules = findAllModules()
    OutputStream.Stream(frame, coroutine.wrap(function()
        for _,mod in ipairs(modules) do
            local src = ""
            pcall(function() src = mod.Source end)
            for _,warn in ipairs(checkLuaTypes(src)) do
                coroutine.yield({text = ("%s: %s"):format(mod.Name, warn), color=Color3.fromRGB(255,180,80)})
                wait(0.02)
            end
        end
        coroutine.yield({text="[TypeCheck] Done.", color=Color3.fromRGB(120,255,128)})
    end))
end

return TypeValidator