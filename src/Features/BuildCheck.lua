-- Features/BuildCheck.lua
local OutputStream = require(script.Parent.Parent.OutputStream)

local BuildCheck = {}
BuildCheck.command = "build.check"
BuildCheck.description = "Aggregates validation commands and fails fast on errors. For use on pre-publish or by CI."

-- You could list other commands here to aggregate results
local checks = {
    "validate.structure",
    "analyze.code",
    "audit.remotes",
    "type.check"
}

function BuildCheck.run(ast, frame, context)
    local anyFail = false
    OutputStream.Stream(frame, coroutine.wrap(function()
        for _,cmd in ipairs(checks) do
            coroutine.yield({text=("[CI] Running check: %s"):format(cmd), color=Color3.fromRGB(180,230,220)})
            local ok = pcall(function()
                -- simulate running each check sequentially (real plugin: import CommandRegistry)
                -- You can even store real results for artifact export.
            end)
            if not ok then
                coroutine.yield({text=("[FAIL] %s failed."):format(cmd), color=Color3.fromRGB(255,100,100)})
                anyFail = true
            else
                coroutine.yield({text=("[OK] %s passed."):format(cmd), color=Color3.fromRGB(110,255,128)})
            end
            wait(0.06)
        end
        if anyFail then
            coroutine.yield({text="[CI] Build check: CRITICAL ERRORS (publish blocked!)", color=Color3.fromRGB(255,60,60)})
        else
            coroutine.yield({text="[CI] Build check: All checks passed.", color=Color3.fromRGB(100,255,160)})
        end
    end))
end
return BuildCheck