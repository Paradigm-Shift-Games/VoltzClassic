--Author: Styx

local CleanupService = require(game.ServerScriptService.Services.CleanupService)
local WeldService = require(game.ServerScriptService.Services.WeldService)
local jetpackModel = script:WaitForChild("Backpack")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Electricity = require(game.ServerScriptService.Packages.Electricity.Interface)
local ElectricNode = require(game.ServerScriptService.Packages.Electricity.Classes.Node)
local ChargeAnimator = 	require(game.ServerScriptService.Packages.Electricity.Classes.NetworkObjects.ChargeAnimator)
local ValueReplicator = require(game.ServerScriptService.Packages.Electricity.Classes.NetworkObjects.ValueReplicator)
local Events = ReplicatedStorage:WaitForChild("Events")
local ThrusterEvent = Events:WaitForChild("thruster")
local Players = game:GetService("Players")
local jetpacks = {}
local module = {}

local function RemoveJetpack(player)
	local jetpack = jetpacks[player]
	if not jetpack then return end
	CleanupService.Clean(jetpack)
	jetpacks[player] = nil
end

local function AddJetpack(player)
	if jetpacks[player] then RemoveJetpack(player) end

	--Data
	local newJetpack = jetpackModel:Clone()
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local upperTorso = character:FindFirstChild("UpperTorso")

	--Build Jetpack
	newJetpack.TeamColorPart.BrickColor = player.Team.TeamColor
	WeldService.WeldModel(newJetpack)
	local newWeldConstraint = Instance.new("WeldConstraint")
	newWeldConstraint.Parent = newJetpack.PrimaryPart
	newJetpack:SetPrimaryPartCFrame(upperTorso.CFrame - Vector3.new(0, 0.3, 0))
	newWeldConstraint.Part0 = newJetpack.PrimaryPart
	newWeldConstraint.Part1 = upperTorso

	--Electrical
	local node = ElectricNode.New()
	node.charge = 0
	node.storage = 100
	ChargeAnimator.New(newJetpack.ChargeBar, newJetpack.PrimaryPart):BindNode(node)
	Electricity.BindStructure(newJetpack, node)

	--Finalize
	jetpacks[player] = newJetpack
	ValueReplicator.New():BindNode(node)
	humanoid.died:Connect(function() RemoveJetpack(player) end)
	newJetpack.Parent = character
	CollectionService:AddTag(newJetpack, "Backpack")
end

local function onRemoteEvent(player, enabled)
	--Jetpack
	local jetpack = jetpacks[player]
	if not jetpack then return end

	--Emitter
	local emitter = jetpack:FindFirstChild("Emitter")
	if not emitter then return end

	--Set Emitter State
	for _, v in ipairs(emitter:GetChildren()) do v.ParticleEmitter.Enabled = enabled end
end

local function onPlayerAdded(player)
	if player.Character then AddJetpack(player) end
	player.CharacterAdded:Connect(function() AddJetpack(player) end)
end


module.GetBackpack = function(player)
	return jetpacks[player]
end

ThrusterEvent.OnServerEvent:connect(onRemoteEvent)
Players.PlayerAdded:Connect(onPlayerAdded)

return module