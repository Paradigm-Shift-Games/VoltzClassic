-- Author: 4812571 and n0pa

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local StructureUtility = require(ReplicatedStorage.StructureUtility)
local EffectService = require(ServerScriptService.Services.EffectService)
local GridInterface = require(ServerScriptService.Packages.Grid.Interface2)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)
local NetworkHook = require(ServerScriptService.Packages.Electricity.Classes.NetworkObjects.Hook)

--Roblox Services

--Imports
local Stats = require(ReplicatedStorage.Stats.Structure)["Turret"]
local Effect = require(ReplicatedStorage.Stats.Weapon).Effects["Physical_l"]

--Data
local TurretData = {}
local module = {}

local raycastParameters = RaycastParams.new()
raycastParameters.FilterType = Enum.RaycastFilterType.Blacklist
raycastParameters.IgnoreWater = true

--Helper Functions
local function updateOriginModel(cFrame, model)
	local pos = cFrame.Position
	cFrame += model.PrimaryPart.Position - cFrame.Position
	model:SetPrimaryPartCFrame(cFrame)
	cFrame += pos - cFrame.Position
end

local function getHumanoid(instance)
	return instance and instance.Parent and (instance.Parent:FindFirstChild("Humanoid") or instance.Parent.Parent:FindFirstChild("Humanoid"))
end

local function resultHasHumanoid(result)
	local instance = result.Instance
	local hitHumanoid = getHumanoid(instance)
	if hitHumanoid then return hitHumanoid end
end

local function raycast(position, ray, params, func)
	local blacklist = params.FilterDescendantsInstances
		
	while true do		
		local result = workspace:Raycast(
			position,
			ray,
			params
		)
		if not result then return end
		
		if func(result) then return result end
		
		local model = StructureUtility.GetModel(result.Instance)
		if not CollectionService:HasTag(model, "Blueprint") then return end
		
		table.insert(blacklist, model)
		params.FilterDescendantsInstances = blacklist
	end
end

local function getClosestCharacterInRange(turret, ignoreTeam)
	-- Get Characters
	local position = turret.PrimaryPart.Position
	local characters = GridInterface.GetPriorityInRadius("Characters", position, Stats.Range, function(_, elementPosition) return -(elementPosition - position).Magnitude end)
	if characters.Length == 0 then return end

	-- Build Raycast Parameters
	local barrelPos = turret.Barrel.Nozzle2.Position
	raycastParameters.FilterDescendantsInstances = {workspace.Effects, turret}

	while(characters.Length > 0) do
		local character = characters:Shift()
		local dir = (character.PrimaryPart.Position - barrelPos).Unit
		local result = raycast(barrelPos, dir * Stats.Range, raycastParameters, resultHasHumanoid)
		if result and Players:GetPlayerFromCharacter(character).Team ~= ignoreTeam then return character end
	end
end

local function weightedRandom(weight)
	return math.random()^weight
end

local function aim(turret, targetPos)
	local barrelPos = turret.Barrel.Nozzle2.Position
	local dirCF = CFrame.lookAt(barrelPos, targetPos)
	
	local baseCF = turret.Base.PrimaryPart.CFrame
	local hingePos = turret.Barrel.Hinge1.Position
	local motorCF = baseCF:ToObjectSpace(dirCF)
		
	local x, y, z = motorCF:ToEulerAnglesYXZ()
	turret.Head.HingeMotor.C1 = CFrame.Angles(0, y, 0)
	turret.Barrel.HingeMotor.C1 = CFrame.Angles(0, 0, -x)
end

function spreadCF(barrelPos, targetPos, maxSpread)
	local targetCF = CFrame.lookAt(barrelPos, targetPos)
	local rXY = CFrame.fromAxisAngle(targetCF.LookVector, 2*math.pi*math.random()) * targetCF
	local rYZ = CFrame.fromAxisAngle(rXY.RightVector, math.rad(maxSpread)*weightedRandom(Stats.SpreadWeight)) * rXY
	
	return rYZ
end

local function shoot(turret, targetPos)
	local attachment = turret.Barrel.Nozzle.Attachment
	local barrelPos = turret.Barrel.Nozzle2.Position
	local dirCF = spreadCF(barrelPos, targetPos, Stats.Spread)

	if not Electricity.Pull(turret, Stats.ShotCost) then return end
	TurretData[turret].Cooldown = Stats.ReloadTime
	
	raycastParameters.FilterDescendantsInstances = {workspace.Effects, turret}
	
	local resultSpread = workspace:Raycast(
		barrelPos,
		dirCF.LookVector * Stats.Range,
		raycastParameters
	)
	
	EffectService.FireEffect("Bullet",
		attachment,
		resultSpread and resultSpread.Position or dirCF.LookVector * Stats.Range,
		Effect
	)
	if not resultSpread then return end
	
	local humanoid = resultHasHumanoid(resultSpread)
	if humanoid then humanoid:TakeDamage(Stats.Damage) return end
	
	local model = StructureUtility.GetModel(resultSpread.Instance)
	Electricity.Pull(model, Stats.Damage, true)
end

--Exports
module.Run = function(delta)
	for turret, data in pairs(TurretData) do
		data.Cooldown -= delta
		
		local character = getClosestCharacterInRange(turret, turret.Team.Value)
		if not character or not character.PrimaryPart then continue end
		
		aim(turret, character.PrimaryPart.Position)
		if data.Cooldown > 0 then continue end
		
		shoot(turret, character.PrimaryPart.Position)
	end
end

--Event Connections
CollectionService:GetInstanceAddedSignal(script.Name):Connect(function(turret)
	TurretData[turret] = {
		["Cooldown"] = Stats.ReloadTime
	}
end)

CollectionService:GetInstanceRemovedSignal(script.Name):Connect(function(turret)
	TurretData[turret] = nil
end)

return module

