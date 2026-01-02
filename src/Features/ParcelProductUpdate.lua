local OutputStream = require(script.Parent.Parent.OutputStream)
local HttpService = game:GetService("HttpService")

local ParcelProductUpdate = {}
ParcelProductUpdate.command = "parcel.update"
ParcelProductUpdate.flags = {
    product = true,
    reconfigure = true
}
ParcelProductUpdate.description = "Securely update/reconfigure a Parcel product in-place via backend, with license protection."

-- Config: URL of your backend server (not Parcel's!)
local BACKEND_URL = "https://your-backend.example.com/parcelUpdate"

-- Helper: Find scripts/assets tagged with product ID
local function findProductAssets(productId)
    local found = {}
    for _,obj in ipairs(game:GetDescendants()) do
        -- You decide how to tag products, here using an attribute 'ParcelProductId'
        if tostring(obj:GetAttribute("ParcelProductId")) == tostring(productId) then
            table.insert(found, obj)
        end
    end
    return found
end

function ParcelProductUpdate.run(ast, frame, context)
    local productId = ast.flags.product or ast.args[1]
    local userId = game.CreatorId or ""
    if not productId then
        OutputStream.Append(frame, "parcel.update --product=[ID]", Color3.fromRGB(255,110,80)) return
    end

    OutputStream.Stream(frame, coroutine.wrap(function()
        coroutine.yield({text = "[Product] Requesting update for Parcel product "..productId.." ...", color=Color3.fromRGB(130,210,255)})
        local payload = {
            userId = tostring(userId),
            productId = tostring(productId),
            command = "update",
        }
        -- Secure backend call! Never expose keys/client secrets!
        local ok, response = pcall(function()
            return HttpService:PostAsync(BACKEND_URL, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
        end)
        if not ok or not response then
            coroutine.yield({text = "[ERROR] Backend unreachable (network or license check failure)", color=Color3.fromRGB(255,110,80)})
            return
        end
        local res = {}
        local decodeOk = pcall(function()
            res = HttpService:JSONDecode(response)
        end)
        if not decodeOk or not res.licensed then
            coroutine.yield({text = "[DENIED] License verification failed, or product not found.", color=Color3.fromRGB(255,80,80)})
            return
        end
        coroutine.yield({text = "[OK] License verified. Fetching update ...", color=Color3.fromRGB(110,255,180)})

        -- If 'metadata' contains new config/script source:
        local assets = findProductAssets(productId)
        if #assets == 0 then
            coroutine.yield({text="[WARN] No assets tagged for product "..productId, color=Color3.fromRGB(240,180,80)})
        else
            for _,obj in ipairs(assets) do
                if res.metadata and obj:IsA("ModuleScript") and res.metadata.newSource then
                    obj.Source = res.metadata.newSource
                    coroutine.yield({text=("[Updated] "%s" reconfigured with latest Parcel data."):format(obj.Name), color=Color3.fromRGB(110,210,255)})
                end
                if res.metadata and res.metadata.version then
                    obj:SetAttribute("ParcelProductVersion", res.metadata.version)
                end
            end
        end
        coroutine.yield({text=("[parcel.update] Product %s update applied. No movement; all edits done in place."):format(productId), color=Color3.fromRGB(130,255,186)})
    end))
end

return ParcelProductUpdate