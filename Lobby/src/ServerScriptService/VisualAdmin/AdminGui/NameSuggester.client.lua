local function FindPlayerFromPartialName(partial)
	if game.Players:FindFirstChild(partial) then return game.Players[partial] end
	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:sub(1, partial:len()) == partial then return player end
	end
	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:lower():sub(1, partial:len()) == partial:lower() then return player end
	end
	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:lower():gmatch(partial)() then return player end
	end
end

function SuggestPlayerNamesOnInput(Entry, Target)
	
end