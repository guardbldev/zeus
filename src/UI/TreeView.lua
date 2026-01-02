-- UI/TreeView.lua
-- Minimalist, expandable TreeView for dependency graphs/asset graphs
-- Call TreeView.RenderTree(rootData, parentFrame, onClick)

local TreeView = {}

function TreeView.RenderTree(treeData, parent, onClick, indent)
    indent = indent or 0
    local y = 0
    for i, node in ipairs(treeData) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,22)
        btn.Position = UDim2.new(0, indent*18, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(40+indent*10,40,60)
        btn.TextColor3 = Color3.fromRGB(210,210,245-indent*8)
        btn.Font = Enum.Font.Code
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Text = (("  "):rep(indent))..(node.text or node.name)
        btn.Parent = parent
        if onClick and node.payload then
            btn.MouseButton1Click:Connect(function() onClick(node) end)
        end
        y = y + 24
        if node.children and #node.children > 0 then
            y = y + TreeView.RenderTree(node.children, parent, onClick, indent+1)
        end
    end
    return y
end

return TreeView