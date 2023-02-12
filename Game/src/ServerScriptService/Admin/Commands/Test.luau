local function Command(player, parameter)
	for _, v in pairs(game.Teams:GetChildren()) do
		print(v)
	end
end

return Command
