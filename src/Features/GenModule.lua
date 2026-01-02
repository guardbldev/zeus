-- Features/GenModule.lua
-- Instantiates a Module or Service from a template, enforcing naming conventions

local OutputStream = require(script.Parent.Parent.OutputStream)
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local GenModule = {}

GenModule.command = "gen.module"
GenModule.flags = {
	name = true, -- or positional
	["type"] = true, -- e.g. "Service", default "Module"
	["path"] = true -- parent location in DataModel
}
GenModule.description = "Generate a standardized Module/Service from template"

-- Basic example templates; extend with your org's style
local TEMPLATES = {
	Module = [[
-- $NAME.lua (Auto-generated)
local $NAME = {}

function $NAME.new()
	local self = setmetatable({}, {__index = $NAME})
	return self
end

return $NAME
]],
	Service = [[
-- $NAME.lua (Service, Auto-generated)
local $NAME = {}
$NAME.__index = $NAME

function $NAME:Init()
	-- Service startup logic
end

return setmetatable({}, $NAME)
]]
}

local function enforceClassName(str)
	str = str:gsub("[%s_]+", "") -- remove spaces and underscores
	return str:sub(1,1):upper() .. str:sub(2)
end

function GenModule.run(ast, frame, context)
	local name = ast.args[1] or ast.flags.name
	if not name then
		OutputStream.Append(frame, "You must provide a module/service name. Try: gen.module InventoryService", Color3.fromRGB(255,100,60))
		return
	end
	local typeName = ast.flags["type"] or (name:find("Service") and "Service") or "Module"
	if not TEMPLATES[typeName] then
		OutputStream.Append(frame, "Type must be Module or Service.", Color3.fromRGB(255,120,60))
		return
	end
	local className = enforceClassName(name)
	local code = TEMPLATES[typeName]
	code = code:gsub("$NAME", className)

	local dest = game:GetService("ReplicatedStorage")
	if ast.flags["path"] then
		-- Find path in DataModel (simulate explorer path parsing)
		local path = ast.flags["path"]
		local segs = {}
		for seg in path:gmatch("[^/]+") do table.insert(segs, seg) end
		local ptr = game
		for _, seg in ipairs(segs) do
			local found = ptr:FindFirstChild(seg)
			if found then ptr = found end
		end
		dest = ptr
	end

	-- Prevent overwrite
	if dest:FindFirstChild(className) then
		OutputStream.Append(frame, className.." already exists at destination.", Color3.fromRGB(255,200,100))
		return
	end

	ChangeHistoryService:SetWaypoint("GenModuleStart")
	local moduleScript = Instance.new("ModuleScript")
	moduleScript.Name = className
	moduleScript.Source = code
	moduleScript.Parent = dest

	OutputStream.Append(frame, string.format("Generated %s '%s' at %s", typeName, className, dest:GetFullName()), Color3.fromRGB(110,255,190))
	ChangeHistoryService:SetWaypoint("GenModuleEnd")
end

return GenModule