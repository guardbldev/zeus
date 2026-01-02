-- UI/AssetDiffUI.lua
local AssetDiffUI = {}

function AssetDiffUI.ShowDiff(parent, assetA, assetB)
    -- Compare attributes, source, etc.
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,400,0,280)
    frame.Position = UDim2.new(0.5,-200,0.5,-140)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,28)
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,24)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Code
    label.Text = "Asset Diff: "..(assetA.Name or "?").." vs "..(assetB.Name or "?")
    label.Parent = frame

    local diffLabel = Instance.new("TextLabel")
    diffLabel.Position = UDim2.new(0,0,0,36)
    diffLabel.Size = UDim2.new(1,0,1,-36)
    diffLabel.BackgroundTransparency = 1
    diffLabel.Font = Enum.Font.Code
    diffLabel.TextXAlignment = Enum.TextXAlignment.Left
    diffLabel.TextYAlignment = Enum.TextYAlignment.Top
    diffLabel.TextColor3 = Color3.fromRGB(240,210,140)
    diffLabel.Text = ""

    local diff = ""
    if assetA:IsA("ModuleScript") and assetB:IsA("ModuleScript") then
        local srcA,srcB = assetA.Source,assetB.Source
        if srcA ~= srcB then
            local linesA, linesB = {}, {}
            for l in srcA:gmatch("[^\r\n]+") do table.insert(linesA,l) end
            for l in srcB:gmatch("[^\r\n]+") do table.insert(linesB,l) end
            for i = 1, math.max(#linesA, #linesB) do
                local a, b = linesA[i] or "", linesB[i] or ""
                if a ~= b then
                    diff ..= ("- %s\n+ %s\n"):format(a,b)
                end
            end
        else
            diff = "[No difference in source.]"
        end
    end
    diffLabel.Text = diff
    diffLabel.Parent = frame

    return frame
end

return AssetDiffUI