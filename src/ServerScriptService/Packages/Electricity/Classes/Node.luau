-- Author: 4812571
local Event = require(game.ServerScriptService.Classes.Event.Event)
local IdStream = require(game.ServerScriptService.Classes.Datastructure.IdStream)

-- Node Class
local Node = {}
Node.__index = Node

function Node:Push(amount, allowPartial)
	return self.network:Push(amount, allowPartial)
end

function Node:Pull(amount, allowPartial)
	return self.network:Pull(amount, allowPartial)
end

function Node:GetCharge()
	return self.network:GetCharge()
end

function Node:GetStorage()
	return self.network:GetStorage()
end

function Node:GetCapacity()
	return self.network:GetCapacity()
end

function Node:GetActivity()
	return self.network:GetActivity()
end

function Node:BindNetwork(network)
	self.network = network
	for object, _ in pairs(self.boundObjects) do object:BindNetwork(network) end
end


function Node:Remove()
	for object, _ in pairs(self.boundObjects) do
		if object.Unbind then object:Unbind() end
	end
end

-- Service
local module = {}

local idStream = IdStream.New()

function module.New()
	local object = {
		id = idStream:Next();
		boundObjects = {};
		events = {};
	}
	
	return setmetatable(object, Node)
end

return module