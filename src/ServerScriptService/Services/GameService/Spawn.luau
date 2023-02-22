local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Colorizer = require(ServerScriptService.Services.Colorizer)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)
local StarterIsland = require(ServerScriptService.ServerBootLoader.Map.StarterIsland)

local Spawn = {}
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
	Spawn.SpawnPlayer(player, spawnpad.Point.CFrame)
end

local function RequestTeleport(...)
	print(...)
end

local function OnPlayerAdded(player)
	if not RunService:IsStudio() and player:GetJoinData().TeleportData["Rejoin"] then return end
	local position = StarterIsland.GetSafePosition(player)
	Spawn.SpawnPlayer(player, CFrame.new(position))
end

function Spawn.SpawnPlayer(player, cframe)
	player:LoadCharacter()
	local character = player.Character or player.CharacterAdded:Wait()
	for _, v in ipairs(StarterTools) do v:Clone().Parent = player.Backpack end
	Colorizer.ColorCharacter(character)
	character:SetPrimaryPartCFrame(cframe * spawnOffset)
end

RespawnRemote.OnServerEvent:Connect(RequestSpawn)

task.spawn(function()
	for _, player in ipairs(Players:GetPlayers()) do
		OnPlayerAdded(player)
	end
end)
Players.PlayerAdded:Connect(OnPlayerAdded)

return Spawn
