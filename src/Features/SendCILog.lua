local HttpService = game:GetService("HttpService")
local OutputStream = require(script.Parent.Parent.OutputStream)

local SendCILog = {}
SendCILog.command = "ci.sendlog"
SendCILog.flags = { status=true }
SendCILog.description = "Send build scan logs to remote CI endpoint for automated analysis and alerts."

function SendCILog.run(ast, frame, context)
    local status = ast.flags.status or ast.args[1] or "SUCCESS"
    local logLines = {}
    for _, c in ipairs(frame:GetChildren()) do
        if c:IsA("TextLabel") or c:IsA("TextButton") then
            table.insert(logLines, c.Text)
        end
    end
    local payload = {
        buildStatus = status,
        log = table.concat(logLines, "\n"),
        gameId = game.GameId
    }

    local ok, resp = pcall(function()
        return HttpService:PostAsync("https://your-backend.example.com/buildWebhook", HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
    end)
    if ok then
        OutputStream.Append(frame, "[CI] Log sent!", Color3.fromRGB(100,255,160))
    else
        OutputStream.Append(frame, "[CI] Log send failed.", Color3.fromRGB(255,96,65))
    end
end

return SendCILog