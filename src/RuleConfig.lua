-- RuleConfig.lua
-- Place in your plugin ModuleScripts; contains customizable rules for static/code/sec

return {
    static = {
        prohibitGlobals = true,
        maxYieldPerScript = 3,
        allowedServices = {"ReplicatedStorage", "ServerScriptService"},
        customPatterns = {
            {pattern="warn%s*%(", desc="No warn() allowed in production!"},
        }
    },
    security = {
        forbidServerTrustsClient = true,
        requireDebounce = true,
        requireUserId = true
    },
    attributeSchema = {
        Health = "number",
        Team = "string",
        IsEnemy = "boolean"
    }
}