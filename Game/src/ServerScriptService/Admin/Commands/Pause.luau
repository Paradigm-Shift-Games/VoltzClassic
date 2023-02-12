local ServerScriptService = game:GetService("ServerScriptService")

local TickManager = require(ServerScriptService.Services.TickManager)

local function Command(player, parameter)
	TickManager.Toggle()
end

return Command
