-- OutputStream.lua
-- Live output buffering, streaming, color, click-to-source for plugin terminal

local OutputStream = {}

-- Append a log message (plain or colored)
function OutputStream.Append(frame, text, color, opts)
	color = color or Color3.fromRGB(220,220,220)
	local Y = 0
	for _, c in ipairs(frame:GetChildren()) do
		if c:IsA("TextButton") or c:IsA("TextLabel") then
			Y = math.max(Y, c.Position.Y.Offset + c.Size.Y.Offset)
		end
	end
	local lbl
	if opts and opts.onClick then
		lbl = Instance.new("TextButton")
		lbl.TextWrapped = false
		lbl.AutoButtonColor = false
		lbl.MouseButton1Click:Connect(opts.onClick)
	else
		lbl = Instance.new("TextLabel")
	end
	lbl.Size = UDim2.new(1, 0, 0, 22)
	lbl.Position = UDim2.new(0, 0, 0, Y)
	lbl.Text = text
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = color
	lbl.Font = Enum.Font.Code
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextYAlignment = Enum.TextYAlignment.Center
	lbl.TextSize = 17
	lbl.Parent = frame
	frame.CanvasSize = UDim2.new(0, 0, 0, Y + 24)
end

-- Stream coroutine-based logs out to terminal, supports yield/flush/progress
function OutputStream.Stream(frame, streamFunc)
	coroutine.wrap(function()
		for entry in streamFunc do
			OutputStream.Append(frame, entry.text, entry.color, entry.opts)
			wait(entry.wait or 0)
		end
	end)()
end

-- Export current output to TXT file (returns string)
function OutputStream.Export(frame)
	local buf = {}
	for _, c in ipairs(frame:GetChildren()) do
		if (c:IsA("TextButton") or c:IsA("TextLabel")) then
			table.insert(buf, c.Text)
		end
	end
	return table.concat(buf, "\n")
end

return OutputStream