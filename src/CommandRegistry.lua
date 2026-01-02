-- CommandRegistry.lua (core)
local Commands = {}
local Parser = require(script.Parent.CommandParser)
local OutputStream = require(script.Parent.OutputStream)
local ContextProvider = require(script.Parent.ContextProvider)

-- Register commands
function Commands.Register(command, def)
	Commands[command] = def
end

function Commands.Route(input, outputFrame)
	local ast = Parser.Parse(input)
	if not ast then return end
	local handler = ast and ast.command and Commands[ast.command]
	if handler then
		local context = ContextProvider:GetContext()
		handler.run(ast, outputFrame, context)
	else
		OutputStream.Append(outputFrame, "Unknown command: "..(ast.command or ""), Color3.fromRGB(250,80,80))
	end
end

-- Example of registering a context-aware command feature:
local FeatureRefactorRename = require(script.Parent.Features.RefactorRename)
Commands.Register(FeatureRefactorRename.command, FeatureRefactorRename)

return Commands