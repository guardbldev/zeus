-- Features/StaticAnalysis.lua
local OutputStream = require(script.Parent.Parent.OutputStream)

local StaticAnalysis = {}
StaticAnalysis.command = "analyze.code"
StaticAnalysis.flags = {
	["selection"] = true, -- limit scan to selected objects
}
StaticAnalysis.description = "Scans scripts for yields, infinite loops, global state misuse"

-- Helper: scan for patterns
local function analyzeSource(src)
	local warnings = {}

	-- 1. Detect yield in RemoteEvents
	for l in src:gmatch("[^\r\n]+") do
		if l:find(":FireServer") and l:find("yield") then
			table.insert(warnings, "[WARN] yield inside :FireServer " .. l)
		elseif l:find(":FireAllClients") and l:find("yield") then
			table.insert(warnings, "[WARN] yield inside :FireAllClients " .. l)
		end
	end

	-- 2. Detect infinite loops
	if src:find("while true do") or src:find("while%s-1%s-do") then
		table.insert(warnings, "[WARN] Possible infinite loop 'while true do'")
	end

	-- 3. Global state misuse
	if src:find("_G%.") or src:find("shared%.") then
		table.insert(warnings, "[WARN] Use of _G/shared global state.")
	end

	return warnings
end

-- Find all scripts in list of DataModel roots
local function findScripts(roots)
	local all = {}
	for _,root in ipairs(roots) do
		for _,desc in ipairs(root:GetDescendants()) do
			if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
				table.insert(all, desc)
			end
		end
	end
	return all
end

function StaticAnalysis.run(ast, frame, context)
	local roots = {game:GetService("ReplicatedStorage")}
	pcall(function() table.insert(roots, game:GetService("ServerScriptService")) end)
	pcall(function() table.insert(roots, game:GetService("StarterPlayer")) end)
	local scripts = findScripts(roots)
	if ast.flags["selection"] and context and context.Selection then
		scripts = context.Selection
	end

	OutputStream.Stream(frame, coroutine.wrap(function()
		local totalWarn, scanned = 0, 0
		for i,script in ipairs(scripts) do
			local src = ""
			pcall(function() src = script.Source end)
			local warns = src and analyzeSource(src) or {}
			scanned = scanned + 1
			if #warns > 0 then
				for _,w in ipairs(warns) do
					coroutine.yield({text = ("[%s] %s"):format(script:GetFullName(), w), color=Color3.fromRGB(255,200,100)})
					wait(0.01)
				end
				totalWarn = totalWarn + #warns
			end
			if scanned % 50 == 0 then
				coroutine.yield({text = ("[Scanned %d scripts...]"):format(scanned), color=Color3.fromRGB(100,180,255)})
			end
		end
		coroutine.yield({text=("[Analysis complete: %d script(s), %d warning(s)]"):format(scanned, totalWarn), color = totalWarn==0 and Color3.fromRGB(110,255,140) or Color3.fromRGB(255,90,100)})
	end))
end

return StaticAnalysis