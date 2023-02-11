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
	local target 
	if parameters[1] then target = player
	else target = findPlayerFromPartialName(parameters[1]) end
	
	if not target then print("Cannot create Force Field: No target specified!") return end
	
	if target.Character:FindFirstChild("ForceField") then
		target.Character.ForceField:Destroy()
	else
		Instance.new("ForceField", target.Character)
	end	
end

return Command
