-- Author: 4812571

local ServerScriptService = game:GetService("ServerScriptService")

local Electricity = require(ServerScriptService.Packages.Electricity.Interface)
local ValueReplicator = require(ServerScriptService.Packages.Electricity.Classes.NetworkObjects.ValueReplicator)

local SpawnNumbers = {}

function onAdded(object)
	local team = object.Team.Value
	if not SpawnNumbers[team] then SpawnNumbers[team] = 0 end
	SpawnNumbers[team] += 1
	object.Number.Value = SpawnNumbers[team]
	local node = Electricity.GetNode(object)
	ValueReplicator.New():BindNode(node)
end

local SpawnServer = {}
SpawnServer.__index = SpawnServer

function SpawnServer.new(instance)
	local self = setmetatable({}, SpawnServer)
	self.Instance = instance

	-- Shim
	onAdded(instance)

	return self
end

function SpawnServer:Destroy()
	
end

return SpawnServer