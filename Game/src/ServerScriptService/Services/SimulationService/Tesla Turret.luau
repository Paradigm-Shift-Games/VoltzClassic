--Author: 4812571 and n0pa

--Roblox Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

--Imports
local Electricity = require(game.ServerScriptService.Packages.Electricity.Interface)
local NetworkHook = require(game.ServerScriptService.Packages.Electricity.Classes.NetworkObjects.Hook)
local EffectService = require(game.ServerScriptService.Services.EffectService)
local GridInterface = require(game.ServerScriptService.Packages.Grid.Interface2)
local Stats = require(game.ReplicatedStorage.Stats.Structure)["Tesla Turret"]

--Data
local TurretData = {}
local module = {}

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

--Exports
module.Run = function(delta)
	for turret, data in pairs(TurretData) do	
		--data.Cooldown -= delta
		--if data.Cooldown > 0 then continue end

		local characters = getCharactersInRange(turret.PrimaryPart.Position, turret.Team.Value)
		--if character then shoot(turret, character) end
		track(delta, turret, characters)
	end
end

--Event Connections
CollectionService:GetInstanceAddedSignal(script.Name):Connect(function(turret)
	TurretData[turret] = {
		--["Cooldown"] = Stats.ReloadTime;
		["Targets"] = {};
	}
end)

CollectionService:GetInstanceRemovedSignal(script.Name):Connect(function(turret)
	TurretData[turret] = nil
end)


return module