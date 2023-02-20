-- Author: 4812571 and n0pa

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local EffectService = require(ServerScriptService.Services.EffectService)
local GridInterface = require(ServerScriptService.Packages.Grid.Interface2)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)

--Imports
local Stats = require(ReplicatedStorage.Stats.Structure)["Tesla Turret"]

--Data
local TurretData = {}

--Helper Functions
local function getCharactersInRange(position, teamToIgnore)
	local characters = GridInterface.GetPriorityInRadius(
		"Characters",
		position,
		Stats.Range,
		function(character, distance)
			if not character then return end
			
			local player = Players:GetPlayerFromCharacter(character)
			if not player or player.Team == teamToIgnore then return end
			
			return -distance
		end
	)
	
	return characters
end

local function track(delta, turret, targets)
	local data = TurretData[turret]
	local attachment = turret.ZappyPart.Attachment
	
	local newTargets = {}
	
	for i = 1, targets.Length do
		local target = targets:Shift()
		local beam = data.Targets[target]

		if not Electricity.Pull(turret, Stats.ShotCost*delta) then
			if beam then EffectService.EndEffect(beam) end
			data.Targets[target] = nil
			continue
		end
		
		data.Targets[target] = nil
				
		target.Humanoid:TakeDamage(Stats.Damage*delta)
		newTargets[target] = beam or EffectService.CreateEffect("TeslaBeam", attachment, target.PrimaryPart)
	end
	
	for outdatedTarget, outdatedBeam in pairs(data.Targets) do
		warn(outdatedTarget, outdatedBeam)
		if outdatedBeam then EffectService.EndEffect(outdatedBeam) end
	end
	
	data.Targets = newTargets
end

local function onAdded(turret)
	TurretData[turret] = {
		--["Cooldown"] = Stats.ReloadTime;
		["Targets"] = {};
	}
end

local function onRemoved(turret)
	TurretData[turret] = nil
end

local function runObject(turret, deltaTime)
	--data.Cooldown -= delta
	--if data.Cooldown > 0 then continue end

	local characters = getCharactersInRange(turret.PrimaryPart.Position, turret.Team.Value)
	--if character then shoot(turret, character) end
	track(deltaTime, turret, characters)
end

local TeslaTurretServer = {}
TeslaTurretServer.__index = TeslaTurretServer

function TeslaTurretServer.new(instance)
	local self = setmetatable({}, TeslaTurretServer)
	self.instance = instance

	-- Shim
	onAdded(instance)

	return self
end

function TeslaTurretServer:Update(deltaTime)
	-- Shim
	runObject(self.instance, deltaTime)
end

function TeslaTurretServer:Destroy()
	-- Shim
	onRemoved(self.instance)
end

return TeslaTurretServer