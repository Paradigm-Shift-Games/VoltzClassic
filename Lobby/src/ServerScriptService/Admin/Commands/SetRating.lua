local RatingService = require(game.ServerScriptService.Services.RatingService)

local function findPlayerFromPartialName(partial)
	if game.Players:FindFirstChild(partial) then return game.Players[partial] end

	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:match("^" .. partial) then return player end
	end

	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:lower():match("^" .. partial:lower()) then return player end
	end

	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:lower():gmatch(partial:lower()) then return player end
	end
end

local function Command(player, parameters)
	if not parameters[2] and not tostring(parameters[1]):match("%D") then
		RatingService.SetRating(player.UserId, tonumber(parameters[1]))
	else
		local target = findPlayerFromPartialName(parameters[1])
		if not target then return print("Cannot set rating: No target player specified!") end
		if tostring(parameters[2]):match("%D") then return print("SetRating - rating must be a number!") end
		RatingService.SetRating(target.UserId, tonumber(parameters[2]))
	end
end

return Command
