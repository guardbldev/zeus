-- Features/Profiler.lua
local OutputStream = require(script.Parent.Parent.OutputStream)
local RunService = game:GetService("RunService")

local Profiler = {}
Profiler.command = "profile.scripts"
Profiler.flags = {
	["selection"] = true -- only selected
}
Profiler.description = "Profiles scripts for perf hotspots. In Play mode collects event connection counts."

-- Helper: Count loops, function definitions, connections, etc.
local function analyzePerf(src)
	local lines, fnCount, loops, yields = 0,0,0,0
	for line in src:gmatch("[^\r\n]+") do
		lines = lines + 1
		if line:find("function") then fnCount = fnCount+1 end
		if line:find("while") or line:find("for%s") then loops = loops+1 end
		if line:find("yield") then yields = yields+1 end
	end
	local score = loops + yields + math.floor(lines/100)
	return {lines=lines, fnCount=fnCount, loops=loops, yields=yields, score=score}
end

local function connectionCount(inst)
	local c = 0
	pcall(function()
		for _,sig in ipairs(inst:GetDescendants()) do
			if sig.ClassName:find("Connection") then
				c = c+1
			end
		end
	end)
	return c
end

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

function Profiler.run(ast, frame, context)
	local roots = {game:GetService("ReplicatedStorage")}
	pcall(function() table.insert(roots, game:GetService("ServerScriptService")) end)
	pcall(function() table.insert(roots, game:GetService("StarterPlayer")) end)
	local scripts = findScripts(roots)
	if ast.flags["selection"] and context and context.Selection then
		scripts = context.Selection
	end

	OutputStream.Stream(frame, coroutine.wrap(function()
		local hotspots = {}
		local i = 0
		for _,script in ipairs(scripts) do
			i = i + 1
			pcall(function()
				local src = script.Source or ""
				local r = analyzePerf(src)
				if r.score > 3 then -- Arbitrary threshold
					table.insert(hotspots, {script=script, score=r.score, detail=r})
				end
			end)
			if i % 50 == 0 then
				coroutine.yield({text = ("[Profiled %d scripts...]"):format(i), color=Color3.fromRGB(100,180,255)})
			end
		end
		table.sort(hotspots, function(a,b) return a.score > b.score end)
		if #hotspots == 0 then
			coroutine.yield({text = "[Profiler] No major hotspots found.", color=Color3.fromRGB(120,230,120)})
			return
		end
		coroutine.yield({text = "[Hotspots]", color=Color3.fromRGB(255,210,100)})
		for _,h in ipairs(hotspots) do
			coroutine.yield({text = string.format("[Score %d] %s (Lines:%d Fns:%d Loops:%d Yields:%d)",
				h.score, h.script:GetFullName(), h.detail.lines, h.detail.fnCount, h.detail.loops, h.detail.yields),
				color=Color3.fromRGB(255,220,130)})
		end
		if RunService:IsRunning() then
			for _,script in ipairs(scripts) do
				local cc = connectionCount(script)
				if cc > 2 then
					coroutine.yield({text = string.format("[Run] %s has %d event connections (potential perf problem)", script:GetFullName(), cc),
						color=Color3.fromRGB(255,140,80)})
				end
			end
		end
	end))
end

return Profiler