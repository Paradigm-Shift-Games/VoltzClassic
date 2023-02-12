-- Author: 4812571

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Stats = require(ReplicatedStorage.Stats.Structure)





local module = {}

local objectStats = Stats[script.Name]
local objectData = {}

function onAdded(object)
	objectData[object] = {}	
end

function onRemoved(object)
	objectData[object] = nil
end

function runObject(object, delta)
	
end

module.Run = function(delta)
	for _, v in pairs(CollectionService:GetTagged(script.Name)) do
		runObject(v, delta)
	end
end

CollectionService:GetInstanceAddedSignal(script.Name):Connect(onAdded)
CollectionService:GetInstanceRemovedSignal(script.Name):Connect(onRemoved)

return module
