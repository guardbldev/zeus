-- Features/RefactorRename.lua
-- Implements: refactor.rename --snake
-- Demonstrates context-aware command and live streaming with clickable errors

local OutputStream = require(script.Parent.Parent.OutputStream)

local function toSnakeCase(str)
	return (str:gsub("(%l)(%u)", "%1_%2"):lower())
end

local RefactorRename = {}

RefactorRename.command = "refactor.rename"
RefactorRename.flags = {
	snake = true,
	-- You can add more flags: camel, pascal, etc
}
RefactorRename.description = "Renames selected objects with a specified case."

function RefactorRename.run(ast, frame, context)
	if not context.Selection or #context.Selection == 0 then
		OutputStream.Append(frame, "No objects selected.", Color3.fromRGB(255, 140, 110))
		return
	end
	local mode = ast.flags.snake and "snake" or nil
	if not mode then
		OutputStream.Append(frame, "No rename mode given (try --snake)", Color3.fromRGB(255,200,68))
		return
	end

	OutputStream.Stream(frame, coroutine.wrap(function()
		local ChangeHistoryService = game:GetService("ChangeHistoryService")
		ChangeHistoryService:SetWaypoint("RefactorRenameStart")
		for i, inst in ipairs(context.Selection) do
			if typeof(inst) == "Instance" and inst.Name then
				local old = inst.Name
				local new = nil
				if mode == "snake" then
					new = toSnakeCase(old)
				end
				if new and new ~= old then
					local ok, err = pcall(function()
						inst.Name = new
					end)
					if ok then
						coroutine.yield({
							text = string.format("[Renamed] %s → %s", old, new),
							color = Color3.fromRGB(120,220,120),
						})
					else
						coroutine.yield({
							text = string.format("[Error] %s: %s", old, err),
							color = Color3.fromRGB(250, 80, 80),
							opts = {
								onClick = function()
									if context.ActiveScript then
										-- Jump to first line of script (example) 
										local ScriptEditorService = game:GetService("ScriptEditorService")
										ScriptEditorService:OpenScript(context.ActiveScript, 1)
									end
								end,
							}
						})
					end
				else
					coroutine.yield({
						text = string.format("[Skipped] %s (no change)", old),
						color = Color3.fromRGB(180,180,180),
					})
				end
				wait(0.12)
			end
		end
		ChangeHistoryService:SetWaypoint("RefactorRenameEnd")
	end))
end

return RefactorRename