local GameDataService = require(game.ServerScriptService.Services.GameDataService)
local CommunicationsService = require(game.ServerScriptService.Services.CommunicationService)

local GroupId = 5444195
local AdminRank = 253

local function Command(player, arguments)
	if not arguments.Player and not arguments.UserId then return "No target player or UserId specified!" end
	local userId = arguments.UserId
	
	if arguments.Player then
		if not (arguments.Player:GetRankInGroup(GroupId) < 253) then return "Cannot ban admin!" end
		userId = arguments.Player.UserId
		arguments.Player:Kick("You have been banned for 1 year: " .. arguments.Reason)
	else
		CommunicationsService.Communicate(CommunicationsService.MessageChannels.Moderation, "kick:" .. userId)
	end
	--31469766, a year
	GameDataService.SetKeyData("BannedPlayers", userId, math.floor(tick()) + math.huge()) -- Set the date they are unbanned on to 1 year from now
end

return Command
