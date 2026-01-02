-- Features/StructureValidator.lua
local OutputStream = require(script.Parent.Parent.OutputStream)
local HttpService = game:GetService("HttpService")

local StructureValidator = {}
StructureValidator.command = "validate.structure"
StructureValidator.flags = {
	["preset"] = true
}
StructureValidator.description = "Validate project structure consistency by config/rules."

-- Example config for enforcing folders & files:
local defaultConfig = {
	mustExist = {
		"ReplicatedStorage/Core",
		"ReplicatedStorage/Modules",
		"ServerScriptService/Services",
	},
	mustNotExist = {
		"Workspace/Modules"
	},
	teamPresets = {
		["teamA"] = {
			mustExist = {"ReplicatedStorage/Core", "ServerScriptService/Common"},
			mustNotExist = {}
		}
	}
}

-- parse JSON string to config (user can place their config at ReplicatedStorage/ProjectStructureValidator.json)
local function getProjectConfig()
	local configMod = game:GetService("ReplicatedStorage"):FindFirstChild("ProjectStructureValidator")
	if configMod and configMod:IsA("ModuleScript") then
		local src = configMod.Source
		local ok, cfg = pcall(function()
			return HttpService:JSONDecode(src)
		end)
		if ok and type(cfg)=="table" then
			return cfg
		end
	end
	return defaultConfig
end

-- Simple path traverser
local function pathExists(root, path)
	local segments = {}
	for seg in path:gmatch("[^/]+") do table.insert(segments, seg) end
	local ptr = root
	for _, seg in ipairs(segments) do
		local nxt = ptr:FindFirstChild(seg)
		if not nxt or (not nxt:IsA("Folder") and not nxt:IsA("ModuleScript") and not nxt:IsA("Script")) then return false end
		ptr = nxt
	end
	return true
end

function StructureValidator.run(ast, frame, context)
	local config = getProjectConfig()
	if ast.flags["preset"] and config.teamPresets and config.teamPresets[ast.flags["preset"]] then
		config = config.teamPresets[ast.flags["preset"]]
	end

	OutputStream.Stream(frame, coroutine.wrap(function()
		local fails = 0
		for _, path in ipairs(config.mustExist or {}) do
			if not pathExists(game, path) then
				coroutine.yield({text = "[ERROR] Missing: "..path, color=Color3.fromRGB(255,80,60)})
				fails = fails + 1
			else
				coroutine.yield({text = "[OK] Found: "..path, color=Color3.fromRGB(150,255,120)})
			end
			wait(0.08)
		end
		for _, path in ipairs(config.mustNotExist or {}) do
			if pathExists(game, path) then
				coroutine.yield({text = "[WARN] Forbidden path exists: "..path, color=Color3.fromRGB(255,180,60)})
			else
				coroutine.yield({text = "[OK] Not found: "..path, color=Color3.fromRGB(150,255,120)})
			end
			wait(0.08)
		end
		coroutine.yield({text = ("Validation complete. %d error(s)."):format(fails), color= fails==0 and Color3.fromRGB(110,255,110) or Color3.fromRGB(255,120,120)})
	end))
end

return StructureValidator