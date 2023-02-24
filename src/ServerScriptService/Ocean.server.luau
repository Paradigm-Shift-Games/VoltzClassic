-- Author: NPA

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local StructureUtil = require(ReplicatedStorage.StructureUtility)
local Destruction = require(ServerScriptService.Services.DamageService)

local oceanHeight = -118.185 -- workspace.Ocean.OceanPart.Position.Y
local gradientHeight = 20
local baseDamage = 7
local gradient = 1.6
local maxHeight = oceanHeight + gradientHeight

function onTouch(part)
	local model = StructureUtil.GetModel(part)
	if model then Destruction.Destroy(model) end
end

function onHeartBeat(delta)
	if RunService:IsStudio() then return end
	for _, player in Players:GetPlayers() do
		if not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then continue end
		local posY = player.Character.HumanoidRootPart.Position.Y
		if (posY > maxHeight) then continue end
		local depth = maxHeight - posY
		local damage = baseDamage * (math.max(depth, 0) / gradientHeight)^gradient
		player.Character.Humanoid:TakeDamage(delta * damage)
	end
end

for _, v in pairs(workspace.Ocean:GetChildren()) do
	v.Touched:Connect(onTouch)
end

RunService.Heartbeat:Connect(onHeartBeat)