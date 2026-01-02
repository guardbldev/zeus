-- Features/DeadCodeAssetDetect.lua
local OutputStream = require(script.Parent.Parent.OutputStream)

local DeadCode = {}
DeadCode.command = "dead.detect"
DeadCode.flags = {
	["mark"] = true,
	["restore"] = true,
}
DeadCode.description = "Detect unused modules/assets and mark for deletion/restoration queue."

-- Find all modules, reference-tracking for dependencies
local function findAllModules(root)
	local found = {}
	for _, child in ipairs(root:GetChildren()) do
		if child:IsA("ModuleScript") then
			table.insert(found, child)
		end
		for _,v in ipairs(findAllModules(child)) do table.insert(found, v) end
	end
	return found
end

-- Build reverse-dependency map to find unreferenced nodes
function DeadCode.run(ast, frame, context)
	local roots = {game:GetService("ReplicatedStorage")}
	pcall(function() table.insert(roots, game:GetService("ServerScriptService")) end)
	local allMods = {}
	for _,root in ipairs(roots) do
		for _,mod in ipairs(findAllModules(root)) do
			table.insert(allMods, mod)
		end
	end
	local reqMap = {}
	local nameToMod = {}
	for _,mod in ipairs(allMods) do
		nameToMod[mod.Name] = mod
		reqMap[mod] = {}
		for m in mod.Source:gmatch("require%s*%(([%w_%.:]+)%)") do
			for _,target in ipairs(allMods) do
				if target.Name == m then
					reqMap[mod][target] = true
				end
			end
		end
	end

	-- Find roots (modules not required by anyone)
	local required = {}
	for _, links in pairs(reqMap) do
		for tgt in pairs(links) do
			required[tgt] = true
		end
	end

	local unused = {}
	for _, mod in ipairs(allMods) do
		if not required[mod] then
			table.insert(unused, mod)
		end
	end

	OutputStream.Stream(frame, coroutine.wrap(function()
		if #unused == 0 then
			coroutine.yield({text="[Clean] All modules referenced!", color=Color3.fromRGB(120,220,120)})
			return
		end
		coroutine.yield({text = ("[Unused] %d modules detected:"):format(#unused), color=Color3.fromRGB(255,200,60)})
		for _,mod in ipairs(unused) do
			coroutine.yield({text = ("  %s"):format(mod:GetFullName()), color=Color3.fromRGB(255,220,90)})
			wait(0.03)
			if ast.flags["mark"] then
				-- Mark with "DeadCode_Marked" attribute
				pcall(function() mod:SetAttribute("DeadCode_Marked", true) end)
			end
		end
		if ast.flags["mark"] then
			coroutine.yield({text = "[Mark] Unused modules flagged with DeadCode_Marked.", color=Color3.fromRGB(230,200,200)})
		end
		if ast.flags["restore"] then
			for _,mod in ipairs(allMods) do
				if mod:GetAttribute("DeadCode_Marked") then
					mod:SetAttribute("DeadCode_Marked", false)
				end
			end
			coroutine.yield({text = "[Restore] Cleared DeadCode_Marked attribute for all.", color=Color3.fromRGB(170,255,180)})
		end
	end))
end

return DeadCode