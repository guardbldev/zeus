-- ContextProvider.lua
-- Collects current Studio context for command handlers.

local ContextProvider = {}

function ContextProvider:GetContext()
	local selection = {}
	local Selection = game:GetService("Selection")
	for _, obj in ipairs(Selection:Get()) do
		table.insert(selection, obj)
	end

	-- Find active script in ScriptEditorService, if exists
	local ScriptEditorService = nil
	local activeScript = nil
	pcall(function()
		ScriptEditorService = game:GetService("ScriptEditorService")
	end)
	if ScriptEditorService and ScriptEditorService:GetActiveScript() then
		activeScript = ScriptEditorService:GetActiveScript()
	end

	local RunService = game:GetService("RunService")

	local context = {
		Selection = selection,
		ActiveScript = activeScript,
		EditMode = not RunService:IsRunning(),
		PlayMode = RunService:IsRunning(),
		PlaceId = game.GameId or 0,
		-- Add more info as needed
	}

	return context
end

return ContextProvider