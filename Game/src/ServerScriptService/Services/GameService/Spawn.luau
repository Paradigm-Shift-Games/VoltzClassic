local module = {}
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Electricity = require(game.ServerScriptService.Packages.Electricity.Interface)
local StarterIsland = require(game.ServerScriptService.ServerBootLoader.Map.StarterIsland)
local SpawnStats = require(game.ReplicatedStorage.Stats.Structure).Spawn
local Colorizer = require(game.ServerScriptService.Services.Colorizer)
local RespawnRemote = game.ReplicatedStorage.Events.RequestSpawn

--Variables
local spawnOffset = CFrame.new(0, 2.5, 0)

local StarterTools = {
	game.ReplicatedStorage.Guns.Builder;
	game.ReplicatedStorage.Guns["Pistol"];
}

local function RequestSpawn(player, spawnpad)
	if spawnpad:FindFirstChild("Team") and spawnpad.Team.Value ~= player.Team then warn("Player attempted to spawn at another team's pad!") return end
	if not Electricity.Pull(spawnpad, SpawnStats.SpawnConsumption) then return end
	module.SpawnPlayer(player, spawnpad.Point.CFrame)
end

local function RequestTeleport(...)
	print(...)
end

local function OnPlayerAdded(player)
	if not RunService:IsStudio() and player:GetJoinData().TeleportData["Rejoin"] then return end
	local position = StarterIsland.GetSafePosition(player)
	module.SpawnPlayer(player, CFrame.new(position))
end

module.SpawnPlayer = function(player, cframe)
	player:LoadCharacter()
	local character = player.Character or player.CharacterAdded:Wait()
	for _, v in ipairs(StarterTools) do v:Clone().Parent = player.Backpack end
	Colorizer.ColorCharacter(character)
	character:SetPrimaryPartCFrame(cframe * spawnOffset)
end

RespawnRemote.OnServerEvent:Connect(RequestSpawn)

coroutine.wrap(function() for _, player in ipairs(game.Players:GetPlayers()) do OnPlayerAdded(player) end end)()
game.Players.PlayerAdded:Connect(OnPlayerAdded)

return module
