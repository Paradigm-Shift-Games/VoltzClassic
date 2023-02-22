-- Author: 4812571

local IdStream = require(game.ServerScriptService.Classes.Datastructure.IdStream)
local StorageComponent = require(script.Storage)
local TransferComponent = require(script.Transfer)
local EventComponent = require(script.Events)
local LeakComponent = require(script.Leak)
local InfluenceComponent = require(script.Influence)

local idStream = IdStream.New()
local networks = {}


-- Network Class
local Network = {}
Network.__index = Network

function Network:GetStorage()
	return self.storageComponent.storage
end

function Network:GetCharge()
	return self.storageComponent.charge
end

function Network:GetCapacity()
	return self:GetStorage() - self:GetCharge()
end

function Network:GetActivity()
	return self.activity
end

function Network:Push(amount, allowPartial)
	if not allowPartial then if self:GetCapacity() < amount then return false end end
	self.storageComponent:Push(amount)
	return true
end

function Network:Pull(amount, allowPartial)
	if not allowPartial then if self:GetCharge() < amount then return false end end
	self.storageComponent:Pull(amount)
	return true
end

function Network:Remove()
	self.storageComponent:Apply()
	self.transferComponent:Remove()
	networks[self] = nil
end

function Network:UpdateActivity()
	self.storageComponent:UpdateActivity()
	self.influenceComponent:UpdateActivity()
	local activity = (self.charged or self.producing)
	if activity ~= self.activity then
		self.eventComponent:Fire("ActivityChanged", activity)
		if activity then self.eventComponent:Fire("Activated") else self.eventComponent:Fire("Deactivated") end
		self.activity = activity
	end
end

-- Service
local module = {}

function module.New(node, graph)
	local object = setmetatable({id = idStream:Next()}, Network)
	
	-- Handle Nodes
	local connectedNodes = graph:GetComponent(node)
	local producersArray = {}
	local storagesOrdered = {}
	for _, node in ipairs(connectedNodes) do if node.isProducer then table.insert(producersArray, node) end end
	local nodesOrdered = producersArray[1] and graph:GetComponent(producersArray) or connectedNodes -- If there are no producers, we still need an ordered set of nodes
	for _, node in ipairs(nodesOrdered) do if node.storage then table.insert(storagesOrdered, node) end end
	
	-- Components
	object.storageComponent = 	StorageComponent.	New(object, storagesOrdered)
	object.leakComponent =    	LeakComponent.		New(object, connectedNodes)
	object.influenceComponent = InfluenceComponent.	New(object)
	object.transferComponent = 	TransferComponent.	New(object)
	object.eventComponent =		EventComponent.		New(object)
	
	-- Bind Nodes
	for _, node in ipairs(connectedNodes) do
		node:BindNetwork(object)
	end
	
	-- Update Activity
	object:UpdateActivity()
	object.eventComponent:Fire("NetworkSet")
	
	networks[object] = true
	return object
end

function module.Run(delta)
	for v, _ in pairs(networks) do v:UpdateActivity() end
	for v, _ in pairs(networks) do v.leakComponent    	:Run(delta) end
	for v, _ in pairs(networks) do v.influenceComponent	:Run(delta) end
	for v, _ in pairs(networks) do v.transferComponent	:Run(delta) end
	for v, _ in pairs(networks) do v.storageComponent	:Apply() end
end

return module
