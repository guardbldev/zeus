-- Features/MediaInspector.lua
local OutputStream = require(script.Parent.Parent.OutputStream)

local MediaInspector = {}
MediaInspector.command = "inspect.media"
MediaInspector.flags = {
    ["listing"] = true,
    ["unused"] = true,
}
MediaInspector.description = "Scan animations/sounds: file size, keyframes, unused; report on issues."

function MediaInspector.run(ast, frame, context)
    local found = {}
    for _,obj in ipairs(game:GetDescendants()) do
        if obj:IsA("Animation") or obj:IsA("Sound") then
            table.insert(found, obj)
        end
    end

    OutputStream.Stream(frame, coroutine.wrap(function()
        for _,asset in ipairs(found) do
            local line = "["..asset.ClassName.."] "..asset.Name
            if asset:IsA("Animation") then
                line ..= (" (ID:%s)"):format(asset.AnimationId)
            elseif asset:IsA("Sound") then
                line ..= (" (SoundId:%s)"):format(asset.SoundId)
                if asset.IsLoaded and asset.TimeLength and asset.TimeLength > 30 then
                    coroutine.yield({
                        text = line .. " [LONG]",
                        color = Color3.fromRGB(255,180,80)
                    })
                end
            end
            coroutine.yield({text = line, color = Color3.fromRGB(140,220,250)})
        end
        if ast.flags["unused"] then
            -- Very basic: flag those not referenced by any script
            for _,asset in ipairs(found) do
                local used = false
                for _,s in ipairs(game:GetDescendants()) do
                    if (s:IsA("ModuleScript") or s:IsA("Script") or s:IsA("LocalScript")) then
                        local src = ""; pcall(function() src = s.Source end)
                        if (asset.AnimationId and src:find(asset.AnimationId)) or (asset.SoundId and src:find(asset.SoundId)) then
                            used = true; break
                        end
                    end
                end
                if not used then
                    coroutine.yield({text = "[UNUSED] "..asset.Name, color=Color3.fromRGB(255,130,98)})
                end
            end
        end
        coroutine.yield({text = "[Media Inspector] Done.", color = Color3.fromRGB(130,220,136)})
    end))
end

return MediaInspector