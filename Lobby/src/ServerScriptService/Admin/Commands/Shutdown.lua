local LaunchManager = require(game.ServerScriptService.Lobby.Launch)
local ChatMessage = game.ReplicatedStorage.Remotes.ChatMessage

local function Command(player, arguments)
	warn(player.Name .. " shut down the server.")
	for _, p in ipairs(game.Players:GetPlayers()) do
		p:Kick("Server has been shut down.")
	end
	game.Players.PlayerAdded:Connect(function(p) p:Kick("The server has been shut down.") end)
end

return Command
