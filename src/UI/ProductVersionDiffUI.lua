local ProductVersionDiffUI = {}

function ProductVersionDiffUI.ShowDiff(parent, versionHistory)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,430,0,320)
    frame.Position = UDim2.new(0.5,-215,0.5,-160)
    frame.BackgroundColor3 = Color3.fromRGB(26,26,36)
    frame.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,26)
    lbl.Text = "Product Version History"
    lbl.Font = Enum.Font.Code
    lbl.TextColor3 = Color3.fromRGB(238,208,176)
    lbl.BackgroundTransparency = 1
    lbl.Parent = frame

    local y = 30
    for i,branch in ipairs(versionHistory or {}) do
        local vinfo = Instance.new("TextLabel")
        vinfo.Position = UDim2.new(0,10,0,y)
        vinfo.Size = UDim2.new(0,410,0,22)
        vinfo.Text = string.format("v%s | %s | Changed: %s", branch.version or "?", branch.date or "", branch.changes or "")
        vinfo.Font = Enum.Font.Code
        vinfo.TextColor3 = branch.isCurrent and Color3.fromRGB(60,250,130) or Color3.fromRGB(210,210,210)
        vinfo.BackgroundTransparency = 1
        vinfo.TextXAlignment = Enum.TextXAlignment.Left
        vinfo.Parent = frame
        y = y + 22
    end
    return frame
end

return ProductVersionDiffUI