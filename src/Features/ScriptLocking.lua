-- Features/ScriptLocking.lua
local OutputStream = require(script.Parent.Parent.OutputStream)

local ScriptLocking = {}
ScriptLocking.command = "lock.script"
ScriptLocking.flags = { ["unlock"]=true }
ScriptLocking.description = "Lock or unlock scripts for team-safe editing. Uses attributes for local or shared locks."

local function isLocked(script)
    return script:GetAttribute("GuardBL_LockedBy")
end

function ScriptLocking.run(ast, frame, context)
    local selection = context.Selection or {}
    if #selection == 0 then
        OutputStream.Append(frame, "Select script(s) to lock/unlock.", Color3.fromRGB(255,120,90))
        return
    end
    local locked, unlocked, failed = 0,0,0
    local user = tostring(game.CreatorId or "")
    for _,obj in ipairs(selection) do
        if obj:IsA("Script") or obj:IsA("ModuleScript") then
            if ast.flags.unlock then
                if isLocked(obj) then
                    obj:SetAttribute("GuardBL_LockedBy", nil)
                    unlocked = unlocked+1
                end
            else
                if isLocked(obj) then
                    OutputStream.Append(frame, ("Already locked by %s: %s"):format(tostring(obj:GetAttribute("GuardBL_LockedBy")), obj.Name), Color3.fromRGB(255,210,120))
                else
                    obj:SetAttribute("GuardBL_LockedBy", user)
                    locked = locked+1
                end
            end
        else
            failed = failed+1
        end
    end
    OutputStream.Append(frame, ("Locked:%d Unlocked:%d Failed:%d"):format(locked,unlocked,failed), Color3.fromRGB(110,255,180))
end
return ScriptLocking