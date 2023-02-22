-- Author: 4812571

-- ValueReplicator Class
local ValueReplicator = {type = script.Name}
ValueReplicator.__index = ValueReplicator

function ValueReplicator:BindNode(node)
	if self.node then error("Attempt to overwrite node binding!") end
	if not node.structure then error("node must have structure") end
	
	-- Create Value
	local value = script.Charge:Clone()
	value.Parent = node.structure	
	
	node.boundObjects[self] = true
	self.node = node
	self.value = value
	self:BindNetwork(node.network)
end

function ValueReplicator:BindNetwork(network)
	network.storageComponent:AttachReplicator(self)
end

function ValueReplicator:SetValue(value)
	self.value.Value = value
end

-- Service
local module = {}

function module.New()
	local object = {
		
	}
	
	return setmetatable(object, ValueReplicator)
end

return module