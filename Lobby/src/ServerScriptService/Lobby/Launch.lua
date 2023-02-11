--Author: n0pa

local TeleportService = game:GetService("TeleportService")
local GameDataService = require(game.ServerScriptService.Services.GameDataService)
local DoorManager = require(game.ServerScriptService.Lobby.Doors)
local Teams = game.Teams
local NeutralTeam = Teams["No Team"]
local GameID = 4566800668

local TeleportEvent = game.ReplicatedStorage.Remotes.Teleport

local launching = false

local module = {}
module.Bound = {}

module.IsLaunching = function()
	return launching
end

module.BindToLaunch = function(name, callback)
	module.Bound[name] = callback
end

module.UnbindFromLaunch = function(name)
	module.Bound[name] = nil
end

module.Launch = function()
	print("Launching pods!")
	launching = true
	
	for _, bound in pairs(module.Bound) do bound() end

	local teleportData = {}
	local launchingPlayers = {}
	local reservedServer = TeleportService:ReserveServer(GameID)
	for _, team in pairs(Teams:GetChildren()) do
		if team == NeutralTeam or #team:GetPlayers() == 0 then continue end

		local color = team.TeamColor.Color
		teleportData[team.Name] = {
			players = {};
			teamColor = {R = color.R; G = color.G; B = color.B;};
			pos = tonumber(team:FindFirstChild("Pod").Value.Name)
		}

		for _, player in pairs(team:GetPlayers()) do
			table.insert(teleportData[team.Name].players, player.UserId)
			table.insert(launchingPlayers, player)
			
			coroutine.wrap(function() GameDataService.SetKeyData("PlayerGames", player.UserId, reservedServer) end)()
			TeleportEvent:FireClient(player)
		end
	end
	TeleportService:TeleportToPrivateServer(GameID, reservedServer, launchingPlayers, nil, teleportData)
	--coroutine.wrap(function() GameDataService.SetKeyData("ActiveGames", reservedServer, DateTime.now().UnixTimestamp) end)()
	delay(8, function() for i = 1, 5 do DoorManager.OpenDoor(i) end launching = false end)
end

return module
