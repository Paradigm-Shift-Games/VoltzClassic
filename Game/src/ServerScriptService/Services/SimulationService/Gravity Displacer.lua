--Author: 4812571

local module = {}
local Electricity = require(game.ServerScriptService.Packages.Electricity.Interface)
local buttonService = require(game.ServerScriptService.Services.ButtonService)
local CollectionService = game:GetService("CollectionService")
local Stats = require(game.ReplicatedStorage.Stats.Structure)
local objectData = {}
local objectStats = Stats[script.Name]

function onAdded(object)
	objectData[object] = {}
	buttonService.Bind(object, object.Button, function(_, state) objectData[object].State = state end)
end

function onRemoved(object)
	objectData[object] = {state = false}
end

function runObject(object, delta)
	local enabled = objectData[object].State and Electricity.Pull(object, delta * objectStats.Consumption)
	if enabled then
		object.Anchor.Anchored = true
		object.Core.Transparency = 0
	else
		object.Anchor.Anchored = false
		object.Core.Transparency = 1
	end
end

module.Run = function(delta)
	for _, v in pairs(CollectionService:GetTagged(script.Name)) do
		runObject(v, delta)
	end
end

CollectionService:GetInstanceAddedSignal(script.Name):Connect(onAdded)
CollectionService:GetInstanceRemovedSignal(script.Name):Connect(onRemoved)

return module
