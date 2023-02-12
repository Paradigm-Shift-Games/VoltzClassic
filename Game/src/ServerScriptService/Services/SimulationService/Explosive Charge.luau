--Author: 4812571

local module = {}
local CollectionService = game:GetService("CollectionService")
local ExplosionService = require(game.ServerScriptService.Services.ExplosionService)
local DamageService = require(game.ServerScriptService.Services.DamageService)
local Stats = require(game.ReplicatedStorage.Stats.Structure)
local objectStats = Stats[script.Name]
objectData = {}

function onAdded(object)
	objectData[object] = {timePlaced = tick()}	
end

function onRemoved(object)
	objectData[object] = nil
end

function runObject(object, delta)
	local timeSincePlace = tick() - objectData[object].timePlaced
	if timeSincePlace > 0 and timeSincePlace < 1 then object.Bomb.BrickColor = BrickColor.new("Lime green") end
	if timeSincePlace > 1 and timeSincePlace < 2 then object.Bomb.BrickColor = BrickColor.new("Br. yellowish orange") end
	if timeSincePlace > 2 and timeSincePlace < 3 then object.Bomb.BrickColor = BrickColor.new("Bright red") end	
	if timeSincePlace > 3 and timeSincePlace < 4 then
		print("Exploding")
		ExplosionService.Explode(object.Bomb.Position, 5, 350)
		DamageService.Destroy(object)
		objectData[object] = nil
		print("Exploded")
	end
end

module.Run = function(delta)
	for v, s in pairs(objectData) do
		runObject(v, delta)
	end
end

CollectionService:GetInstanceAddedSignal(script.Name):Connect(onAdded)
CollectionService:GetInstanceRemovedSignal(script.Name):Connect(onRemoved)

return module
