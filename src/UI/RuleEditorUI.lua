-- UI/RuleEditorUI.lua
local RuleEditorUI = {}

-- Simple in-plugin editor for static/security rules (see RuleConfig.lua)
function RuleEditorUI.Show(parent, rulesTable, onSave)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,360,0,260)
    frame.Position = UDim2.new(0.5,-180,0.5,-130)
    frame.BackgroundColor3 = Color3.fromRGB(28,28,38)
    frame.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,24)
    lbl.Text = "Rule Editor"
    lbl.Font = Enum.Font.Code
    lbl.TextColor3 = Color3.fromRGB(238,210,170)
    lbl.BackgroundTransparency = 1
    lbl.Parent = frame

    local y = 32
    for k,v in pairs(rulesTable) do
        local l = Instance.new("TextLabel")
        l.Position = UDim2.new(0,6,0,y)
        l.Size = UDim2.new(0,120,0,20)
        l.Text = tostring(k)
        l.Font = Enum.Font.Code
        l.TextSize = 16
        l.TextColor3 = Color3.fromRGB(210,210,210)
        l.BackgroundTransparency = 1
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = frame

        local e = Instance.new("TextBox")
        e.Position = UDim2.new(0,128,0,y)
        e.Size = UDim2.new(0,220,0,20)
        e.Text = tostring(v)
        e.Font = Enum.Font.Code
        e.TextSize = 16
        e.BackgroundColor3 = Color3.fromRGB(40,40,52)
        e.TextColor3 = Color3.fromRGB(222,230,240)
        e.TextXAlignment = Enum.TextXAlignment.Left
        e.Parent = frame

        e.FocusLost:Connect(function(enter)
            if enter then rulesTable[k] = e.Text end
        end)
        y = y + 28
    end

    local saveBtn = Instance.new("TextButton")
    saveBtn.Text = "Save"
    saveBtn.Position = UDim2.new(0.5,-40,1,-38)
    saveBtn.Size = UDim2.new(0,80,0,28)
    saveBtn.BackgroundColor3 = Color3.fromRGB(100,255,128)
    saveBtn.TextColor3 = Color3.fromRGB(0,60,0)
    saveBtn.Parent = frame

    saveBtn.MouseButton1Click:Connect(function()
        if onSave then onSave(rulesTable) end
        frame:Destroy()
    end)
    return frame
end
return RuleEditorUI