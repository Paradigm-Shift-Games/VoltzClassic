local GameDataService = require(game.ServerScriptService.Services.GameDataService)
local CommunicationsService = require(game.ServerScriptService.Services.CommunicationService)

local function Command(player, arguments)
	if not arguments.UserId then return "No target UserId specified!" end
	GameDataService.SetKeyData("BannedPlayers", arguments.UserId, math.floor(tick()) - 1) -- Set the date they are unbanned on to the past
end

return Command
