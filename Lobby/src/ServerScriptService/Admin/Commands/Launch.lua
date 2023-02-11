local LaunchManager = require(game.ServerScriptService.Lobby.Launch)
local ChatMessage = game.ReplicatedStorage.Remotes.ChatMessage

local function Command(player, arguments)
	warn(player.Name .. " launched all pods.")
	LaunchManager.Launch()
	ChatMessage:FireAllClients("[Server] " .. player.Name .. " manually launched all pods.", Color3.fromRGB(255, 136, 0), Enum.Font.RobotoCondensed)
end

return Command
