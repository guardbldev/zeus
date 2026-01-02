-- Features/BulkRefactor.lua
-- Bulk refactoring: rename via regex (supports dry-run + diff)

local OutputStream = require(script.Parent.Parent.OutputStream)
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local BulkRefactor = {}

BulkRefactor.command = "refactor.rename"
BulkRefactor.flags = {
	regex = true,
	replace = true,
	["dry-run"] = true
}
BulkRefactor.description = "Bulk rename objects matching regex, with undo & dry run"

local function safeFindReplace(str, pattern, rep)
	local ok, result = pcall(function()
		return string.gsub(str, pattern, rep)
	end)
	if ok then return result else return nil end
end

function BulkRefactor.run(ast, frame, context)
	local regex = ast.flags.regex
	local replace = ast.flags.replace or ""
	local dryRun = ast.flags["dry-run"]

	if not regex or regex == true then
		OutputStream.Append(frame, "Error: --regex required", Color3.fromRGB(250,80,80))
		return
	end
	if #context.Selection == 0 then
		OutputStream.Append(frame, "Select instances to refactor.", Color3.fromRGB(255,120,90))
		return
	end

	local toChange = {}
	for _,obj in ipairs(context.Selection) do
		if typeof(obj) == "Instance" and obj.Name then
			local new = safeFindReplace(obj.Name, regex, replace)
			if new and new ~= obj.Name then
				table.insert(toChange, {instance=obj, old=obj.Name, new=new})
			end
		end
	end

	if #toChange == 0 then
		OutputStream.Append(frame, "No matches for "..tostring(regex), Color3.fromRGB(210,210,90))
		return
	end

	if dryRun then
		OutputStream.Stream(frame, coroutine.wrap(function()
			for i,v in ipairs(toChange) do
				coroutine.yield({text = string.format("[Dry-run] %s ➡ %s", v.old, v.new), color=Color3.fromRGB(130,190,250)})
				wait(0.08)
			end
			coroutine.yield({text = string.format("Dry run: %d objects would be renamed.", #toChange), color=Color3.fromRGB(180,255,180)})
		end))
		return
	end

	-- Full refactor—use ChangeHistory, set undo point
	ChangeHistoryService:SetWaypoint("BulkRefactorStart")
	OutputStream.Stream(frame, coroutine.wrap(function()
		local backup = {}
		for _,v in ipairs(toChange) do
			table.insert(backup, {instance=v.instance, oldName=v.old})
		end
		for i,v in ipairs(toChange) do
			local ok, err = pcall(function()
				v.instance.Name = v.new
			end)
			if ok then
				coroutine.yield({text = string.format("[Renamed] %s ➡ %s", v.old, v.new), color=Color3.fromRGB(100,255,120)})
			else
				coroutine.yield({text = string.format("[Failed] %s: %s", v.old, err), color=Color3.fromRGB(255,80,80)})
			end
			wait(0.10)
		end
		coroutine.yield({
			text = "Rename batch complete. Use Undo (Ctrl+Z) to revert.",
			color = Color3.fromRGB(195,255,120)
		})
		ChangeHistoryService:SetWaypoint("BulkRefactorEnd")
	end))
end

return BulkRefactor