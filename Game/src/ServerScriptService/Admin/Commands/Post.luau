local ServerScriptService = game:GetService("ServerScriptService")

local TimerService = require(ServerScriptService.Services.TimerService)


local function Command(player, parameter)
	TimerService.Post()
end

return Command
