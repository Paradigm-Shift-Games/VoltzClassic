local RunService = game:GetService("RunService")

local LaunchManager = require(game.ServerScriptService.Lobby.Launch)
local ChatMessage = game.ReplicatedStorage.Remotes.ChatMessage

local function Command(player, arguments)
	warn(player.Name .. " launched all pods.")
	if not RunService:IsStudio() then LaunchManager.Launch() end
	ChatMessage:FireAllClients("[Server] " .. player.Name .. " manually launched all pods.", Color3.fromRGB(255, 136, 0), Enum.Font.Gotham )
end

return Command
