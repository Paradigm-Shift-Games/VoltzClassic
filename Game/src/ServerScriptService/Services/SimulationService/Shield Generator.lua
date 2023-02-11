--Author: 4812571

local module = {}
local CollectionService = game:GetService("CollectionService")
local buttonService = require(game.ServerScriptService.Services.ButtonService)
local StructureUtility = require(game.ReplicatedStorage.StructureUtility)
local Destruction = require(game.ServerScriptService.Services.DamageService)
local AssemblyService = require(game.ServerScriptService.Services.AssemblyService)
local Electricity = require(game.ServerScriptService.Packages.Electricity.Interface)
local CleanupService = require(game.ServerScriptService.Services.CleanupService)
local Stats = require(game.ReplicatedStorage.Stats.Structure)
local objectData = {}
local objectStats = Stats[script.Name]

function onAdded(object)
	objectData[object] = {enableTime = tick(), enabled = false}
	objectData[object].Size = objectStats["Sizes"]["Medium"]
	objectData[object].Setting = "Medium"
	buttonService.Bind(object, object.EnableButton, function(_, state) ChangeShieldState(object, state)   end)
	buttonService.Bind(object, object.SmallButton,  function(_, state) ChangeShieldSize(object, "Small")  end)
	buttonService.Bind(object, object.MediumButton, function(_, state) ChangeShieldSize(object, "Medium") end)
	buttonService.Bind(object, object.LargeButton,  function(_, state) ChangeShieldSize(object, "Large")  end)
end

function onRemoved(object)
	objectData[object] = nil
end

function AddCooldown(object, cooldown)
	objectData[object].enableTime = tick() + cooldown	
end

function ChangeShieldSize(object, setting)
	if objectData[object].Setting == setting then return end
	local state = not not object.Shield.Value
	ChangeShieldState(object, false)
	objectData[object].Setting = setting
	objectData[object].Size = objectStats["Sizes"][setting]
	ChangeShieldState(object, state)
end

function ChangeShieldState(object, state)
	objectData[object].Enabled = state
	if state == false and object.Shield.Value then	
		object.Shield.Value:Destroy() 
		CleanupService.Free(object.Shield.Value)
	end
end

function GenerateShield(object)
	local shield = game.ReplicatedStorage.Extras.Shield:Clone()
	local size = objectData[object].Size
	shield.Team.Value = object.Team.Value
	shield.ShieldDome.Size = Vector3.new(size, size, size)
	object.Shield.Value = shield
	shield.PrimaryPart.Position = object.Generator.Position
	shield.ShieldWeld.Part0 = shield.PrimaryPart
	shield.ShieldWeld.Part1 = object.PrimaryPart
	shield.Generator.Value = object
	shield.Parent = workspace.Structures
	AssemblyService.Attach(shield, object, "Attach")
	CleanupService.Reserve(shield, "Shield")
	return shield
end

function runObject(object, delta)
	local data = objectData[object]
	
	--Cooldown
	if tick() < data.enableTime or not data.Enabled then return end
	
	--Generate Shield
	local shield = object.Shield.Value
	if (not shield) or (not shield.Parent) then
		if not Electricity.Pull(object, 2) then return end
		GenerateShield(object)
		shield = object.Shield.Value
		print("Making shield")
	end
	
	
	--Drain
	local shieldPower = shield:WaitForChild("ShieldPower")
	if not Electricity.Pull(object, delta * objectStats.Drain) then 
		object.Shield.Value:Destroy() 
		CleanupService.Free(object.Shield.Value) 
		return
	end
	
	--Charge Shield
	if shieldPower.Value == objectStats.MaxCharge then return end
	if Electricity.Pull(object, delta * objectStats.Consumption) then
		shieldPower.Value = math.min(shieldPower.Value + (delta * objectStats.ChargeRate), objectStats.MaxCharge)
	end
end

function ShieldDestroyed(shield)
	AddCooldown(shield.Generator.Value, 3)
end

module.Run = function(delta)
	for _, v in pairs(CollectionService:GetTagged(script.Name)) do
		runObject(v, delta)
	end
end

CollectionService:GetInstanceAddedSignal(script.Name):Connect(onAdded)
CollectionService:GetInstanceRemovedSignal(script.Name):Connect(onRemoved)

CleanupService.Bind("Shield", ShieldDestroyed)

return module

