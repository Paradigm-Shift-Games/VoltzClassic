--Author: 4812571

local module = {}
local Electricity = require(game.ServerScriptService.Packages.Electricity.Interface)
local ValueReplicator = require(game.ServerScriptService.Packages.Electricity.Classes.NetworkObjects.ValueReplicator)
local CollectionService = game:GetService("CollectionService")

local SpawnNumbers = {}

function onAdded(object)
	local team = object.Team.Value
	if not SpawnNumbers[team] then SpawnNumbers[team] = 0 end
	SpawnNumbers[team] += 1
	object.Number.Value = SpawnNumbers[team]
	local node = Electricity.GetNode(object)
	ValueReplicator.New():BindNode(node)
end

CollectionService:GetInstanceAddedSignal(script.Name):Connect(onAdded)

return module
