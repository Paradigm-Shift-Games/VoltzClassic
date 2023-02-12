local TimerService = require(game.ServerScriptService.Services.TimerService)

local function Command(player, parameter)
	TimerService.Post()
end

return Command
