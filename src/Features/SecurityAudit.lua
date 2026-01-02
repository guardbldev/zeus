-- Features/SecurityAudit.lua
local OutputStream = require(script.Parent.Parent.OutputStream)

local SecurityAudit = {}
SecurityAudit.command = "audit.remotes"
SecurityAudit.description = "Audits for remotely exploitable endpoints and server validation gaps."

-- Find RemoteEvents and RemoteFunctions in possible services
local function findRemotes()
	local remotes = {}
	for _,service in ipairs({game:GetService("ReplicatedStorage"),game:GetService("Workspace")}) do
		for _,desc in ipairs(service:GetDescendants()) do
			if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
				table.insert(remotes, desc)
			end
		end
	end
	return remotes
end

-- Look for clients trusting remote data, no debounce/sanity
local function scanScript(src, remoteName)
	local issues = {}

	-- No server-side validation (very simple check: server Script using :OnServerEvent with no checks)
	if src:find("function%s+[%w_]+:OnServer") and remoteName then
		if not src:find("if%s+%w+%.UserId") and not src:find("assert") and not src:find("type%(") then
			table.insert(issues,"No user validation in OnServer event: " .. remoteName)
		end
	end
	-- HttpService misuse
	if src:find("HttpService:") and not src:find("game:GetService") then
		table.insert(issues, "Use of HttpService API - check privacy policy compliance")
	end

	return issues
end

local function scriptsUsingRemote(remote)
	local all = {}
	for _,svc in ipairs({game:GetService("ReplicatedStorage"),game:GetService("ServerScriptService")}) do
		for _,desc in ipairs(svc:GetDescendants()) do
			if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
				local src = ""
				pcall(function() src = desc.Source end)
				if src and src:find(remote.Name) then -- basic contain
					table.insert(all, {script = desc, source = src})
				end
			end
		end
	end
	return all
end

function SecurityAudit.run(ast, frame, context)
	local remotes = findRemotes()
	OutputStream.Stream(frame, coroutine.wrap(function()
		if #remotes == 0 then
			coroutine.yield({text = "[OK] No remote endpoints found.", color = Color3.fromRGB(120,220,120)})
			return
		end
		for _,remote in ipairs(remotes) do
			coroutine.yield({text = "[Remote] " .. remote:GetFullName(), color=Color3.fromRGB(180,210,220)})
			local refs = scriptsUsingRemote(remote)
			for _,ref in ipairs(refs) do
				local findings = scanScript(ref.source, remote.Name)
				for _,issue in ipairs(findings) do
					coroutine.yield({text = string.format("[Severity:HIGH] %s in %s", issue, ref.script:GetFullName()), color=Color3.fromRGB(255,110,80)})
				end
			end
			wait(0.03)
		end
	end))
end

return SecurityAudit