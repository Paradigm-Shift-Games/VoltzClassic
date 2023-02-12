local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local RatingService = require(ServerScriptService.Services.RatingService)




local function Command(player, parameters, target)
	if not target then print("Cannot set rating: No target player specified!") return end
	local targetPlayer = Players:WaitForChild(tostring(target))
	if not targetPlayer then print("Cannot set rating: Target player specified not present!") return end

	local quantizedParameter = tonumber(parameters[1])
	if not quantizedParameter then return print("Invalid rating parameter", parameters[1], quantizedParameter) end

	RatingService.SetRating(targetPlayer.UserId, quantizedParameter)
	print("Successfully set rating to "..quantizedParameter)
end

return Command
