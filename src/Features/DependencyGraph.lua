-- Features/DependencyGraph.lua
local OutputStream = require(script.Parent.Parent.OutputStream)
local HttpService = game:GetService("HttpService")

local DependencyGraph = {}
DependencyGraph.command = "dep.graph"
DependencyGraph.flags = {
	["export"] = true, -- optional: if set, exports JSON
}
DependencyGraph.description = "Maps all require() dependencies among module scripts."

-- Utility: Recursively find all ModuleScripts under root
local function findAllModules(root)
	local found = {}
	for _, child in ipairs(root:GetChildren()) do
		if child:IsA("ModuleScript") then
			table.insert(found, child)
		end
		for _, result in ipairs(findAllModules(child)) do
			table.insert(found, result)
		end
	end
	return found
end

-- Very simple static require() parsing (works for most Luau, not all edge cases)
local function scanRequires(source)
	local reqs = {}
	for match in source:gmatch("require%s*%(([%w_%.:]+)%)") do
		table.insert(reqs, match)
	end
	return reqs
end

function DependencyGraph.run(ast, frame, context)
	-- Start from ReplicatedStorage and ServerScriptService
	local roots = {game:GetService("ReplicatedStorage")}
	pcall(function() table.insert(roots, game:GetService("ServerScriptService")) end)
	pcall(function() table.insert(roots, game:GetService("StarterPlayer")) end)
	local modules = {}
	for _,root in ipairs(roots) do
		for _,mod in ipairs(findAllModules(root)) do
			table.insert(modules, mod)
		end
	end

	-- Build lookup by full path
	local pathToObj, objToPath = {}, {}
	for _,mod in ipairs(modules) do
		local path = mod:GetFullName()
		pathToObj[path] = mod
		objToPath[mod] = path
	end

	-- Build graph. Node = module:GetFullName(), edge = require
	local graph = {} -- [modPath] = {requiredModPaths}
	for _,mod in ipairs(modules) do
		local src = mod.Source
		local reqs = scanRequires(src)
		graph[objToPath[mod]] = {}
		for _,req in ipairs(reqs) do
			-- Try to resolve require path to a module inside scanned set
			for targetPath,obj in pairs(pathToObj) do
				if obj.Name == req then
					table.insert(graph[objToPath[mod]], targetPath)
				end
			end
		end
	end

	-- Detect cycles with colored DFS
	local function dfs(node, color, visiting, output)
		color[node] = "gray"
		visiting = visiting or {}
		table.insert(visiting, node)
		for _,nbr in ipairs(graph[node]) do
			if color[nbr]=="gray" then
				-- cycle found!
				table.insert(output, {cycle = table.concat(visiting," → ").." → "..nbr})
			elseif color[nbr]==nil then
				dfs(nbr, color, {unpack(visiting)}, output)
			end
		end
		color[node] = "black"
	end

	OutputStream.Append(frame, string.format("Found %d modules. Building dependency graph...", #modules), Color3.fromRGB(200,235,255))
	wait(0.2)
	OutputStream.Stream(frame, coroutine.wrap(function()
		-- Streams "mod requires mod1, mod2 ..."
		for mod, links in pairs(graph) do
			coroutine.yield({
				text = ("[Node] %s requires: %s"):format(mod, #links>0 and table.concat(links, ", ") or "(none)"),
				color = Color3.fromRGB(130,230,255)
			})
			wait(0.025)
		end
		-- Detect and output cycles
		local color = {}
		local output = {}
		for mod,_ in pairs(graph) do
			if not color[mod] then dfs(mod, color, nil, output) end
		end
		for _,v in ipairs(output) do
			coroutine.yield({
				text = "[Cycle] " .. v.cycle,
				color = Color3.fromRGB(255,90,110)
			})
		end
	end))

	-- If --export requested, print entire graph as JSON
	if ast.flags["export"] then
		local graphJson = HttpService:JSONEncode(graph)
		wait(0.5)
		OutputStream.Append(frame, "[Export] JSON (copy from log):", Color3.fromRGB(190,255,160))
		OutputStream.Append(frame, graphJson, Color3.fromRGB(200,255,200))
	end
end

return DependencyGraph