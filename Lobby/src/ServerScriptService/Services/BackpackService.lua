--Author: Styx

local jetpackModel = script:WaitForChild("Backpack")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Events = ReplicatedStorage:WaitForChild("Remotes")
local ThrusterEvent = Events:WaitForChild("thruster")
local Players = game:GetService("Players")
local jetpacks = {}
local BackpackService = {}

local function onCharacterAdded(char)
	while not char:IsDescendantOf(workspace) do
		char.AncestryChanged:Wait()
	end
	local player = Players:GetPlayerFromCharacter(char)
	local humanoid = char:WaitForChild("Humanoid")
	local humanoidRootPart = char.PrimaryPart
	local lowerTorso = char:WaitForChild("LowerTorso")
	local upperTorso = char:WaitForChild("UpperTorso")
	local newJetpack = jetpackModel:Clone()
	CollectionService:AddTag(newJetpack, "Backpack")
	newJetpack.TeamColorPart.BrickColor = player.Team.TeamColor
	local jetpackRoot = newJetpack.PrimaryPart
	local centerPoint = upperTorso.Position/2 + lowerTorso.Position/2
	jetpackRoot.CFrame = CFrame.new(centerPoint, centerPoint + upperTorso.CFrame.LookVector) * CFrame.new(0,0.5,0)
	local newWeldConstraint = Instance.new("WeldConstraint")
	newWeldConstraint.Part0 = jetpackRoot
	newWeldConstraint.Part1 = upperTorso
	newWeldConstraint.Parent = newWeldConstraint.Part0
	newJetpack.Parent = char
	local function onDeath()
		jetpacks[player] = nil
	end
	humanoid.Died:Connect(onDeath)	
	jetpacks[player] = {
		model = newJetpack
	}
end

local function onRemoteEvent(player, enabled)
	local jetPack = jetpacks[player]
	if jetPack then
		local Emitter = jetPack.model:FindFirstChild("Emitter")
		if Emitter then
			for _, v in ipairs(Emitter:GetChildren()) do
				v.ParticleEmitter.Enabled = enabled
			end
		end
	end
end

local function onPlayerAdded(Player)
	if Player.Character ~= nil then
		onCharacterAdded(Player.Character)
	end
	Player.CharacterAdded:Connect(onCharacterAdded)
end
ThrusterEvent.OnServerEvent:connect(onRemoteEvent)
Players.PlayerAdded:Connect(onPlayerAdded)

return BackpackService