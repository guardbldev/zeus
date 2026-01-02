-- Features/AssetPin.lua
local OutputStream = require(script.Parent.Parent.OutputStream)

local AssetPin = {}
AssetPin.command = "asset.pin"
AssetPin.flags = {
    version = true,
}
AssetPin.description = "Pin an asset (by id/name) to a version; flag on drift."

local ASSET_TAG = "GuardBL_Version"

function AssetPin.run(ast, frame, context)
    local assetId = tonumber(ast.args[1]) or tonumber(ast.flags.version)
    if not assetId then
        OutputStream.Append(frame, "asset.pin [assetId]", Color3.fromRGB(255,110,80)) return
    end

    -- Find asset in game by AssetId (via attribute or Name)
    local found = {}
    for _,obj in ipairs(game:GetDescendants()) do
        if tonumber(obj:GetAttribute("AssetId")) == assetId or obj.Name == tostring(assetId) then
            table.insert(found, obj)
        end
    end

    if #found == 0 then
        OutputStream.Append(frame, "No matching assets found.", Color3.fromRGB(250,170,60)) return
    end

    for _,obj in ipairs(found) do
        local ver = obj:GetAttribute(ASSET_TAG)
        -- Drift check (simulate, real versioning is custom)
        local drift = (ver and ver ~= "v1.0.0")
        obj:SetAttribute(ASSET_TAG, "v1.0.0")
        if drift then
            OutputStream.Append(frame, ("[DRIFT] %s was not at v1.0.0. Pin reset."):format(obj:GetFullName()), Color3.fromRGB(255,130,80))
        else
            OutputStream.Append(frame, ("[PIN] %s pinned to v1.0.0"):format(obj:GetFullName()), Color3.fromRGB(120,220,110))
        end
    end
end

return AssetPin