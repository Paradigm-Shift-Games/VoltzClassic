local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Colorizer = require(ServerScriptService.Services.Colorizer)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)
local StarterIsland = require(ServerScriptService.ServerBootLoader.Map.StarterIsland)

local SpawnService = {}
local SpawnStats = require(ReplicatedStorage.Stats.Structure).Spawn
local RespawnRemote = ReplicatedStorage.Events.RequestSpawn

-- Variables
local spawnOffset = CFrame.new(0, 2.5, 0)

local StarterTools = {
	ReplicatedStorage.Guns.Builder;
	ReplicatedStorage.Guns["Pistol"];
}

local function RequestSpawn(player, spawnpad)
	if spawnpad:FindFirstChild("Team") and spawnpad.Team.Value ~= player.Team then warn("Player attempted to spawn at another team's pad!") return end
	if not Electricity.Pull(spawnpad, SpawnStats.SpawnConsumption) then return end
	SpawnService.SpawnPlayer(player, spawnpad.Point.CFrame)
end

function SpawnService.SpawnPlayer(player, cframe)
	player:LoadCharacter()
	local character = player.Character or player.CharacterAdded:Wait()
	for _, v in ipairs(StarterTools) do
		v:Clone().Parent = player.Backpack
	end
	Colorizer.ColorCharacter(character)
	character:SetPrimaryPartCFrame(cframe * spawnOffset)
end

local function OnPlayerAdded(player)
	local position = StarterIsland.GetSafePosition(player)

	if RunService:IsStudio() then
		SpawnService.SpawnPlayer(player, CFrame.new(position))
		return
	end

	if player:GetJoinData().TeleportData.Rejoin then
		SpawnService.SpawnPlayer(player, CFrame.new(position))
		return
	end
end

RespawnRemote.OnServerEvent:Connect(RequestSpawn)

task.spawn(function()
	for _, player in Players:GetPlayers() do
		OnPlayerAdded(player)
	end
end)
Players.PlayerAdded:Connect(OnPlayerAdded)

return SpawnService