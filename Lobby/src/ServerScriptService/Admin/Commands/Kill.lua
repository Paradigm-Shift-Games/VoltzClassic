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
	if not parameters[1] then return print("No target specified to kill!") end
	local target = findPlayerFromPartialName(parameters[1])
	if not target then return print("Cannot Kill Player: No target found with matching name!") end
	if target.Character then target.Character:BreakJoints() end	
end

return Command
