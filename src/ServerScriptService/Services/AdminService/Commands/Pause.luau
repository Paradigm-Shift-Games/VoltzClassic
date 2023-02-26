local ServerScriptService = game:GetService("ServerScriptService")

local TickManagerService = require(ServerScriptService.Services.TickManagerService)

local function Command(player, parameter)
	TickManagerService.Toggle()
end

return Command
