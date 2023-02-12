local TickManager = require(game.ServerScriptService.Services.TickManager)

local function Command(player, parameter)
	TickManager.Toggle()
end

return Command
