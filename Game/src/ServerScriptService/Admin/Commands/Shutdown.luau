local Players = game:GetService("Players")

local function Command(player, arguments)
	warn(player.Name .. " shut down the server.")
	for _, p in ipairs(Players:GetPlayers()) do
		p:Kick("Server has been shut down.")
	end
	Players.PlayerAdded:Connect(function(p) p:Kick("The server has been shut down.") end)
end

return Command
