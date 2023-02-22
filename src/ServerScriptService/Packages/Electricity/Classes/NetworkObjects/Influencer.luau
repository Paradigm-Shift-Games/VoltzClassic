-- Author: 4812571

-- Influencer Class
local Influencer = {type = script.Name}
Influencer.__index = Influencer

function Influencer:SetInfluence(influence)
	if self.network then
		local influenceDelta = influence - self.influence
		self.network.influenceComponent:Modify(self.priority, influenceDelta)		
	end
	
	self.influence = influence
end

function Influencer:BindNode(node)
	if self.node then error("Attempt to overwrite node binding!") end
	node.boundObjects[self] = true
	self.node = node
	if node.network then self:BindNetwork(node.network) end
	-- Binding Code
end

function Influencer:BindNetwork(network)
	network.influenceComponent:Attach(self)
	self.network = network
end

-- Service
local module = {}

function module.New(influence, priority)
	local object = {
		influence = influence or 0;
		priority = priority or 1;
	}
	
	return setmetatable(object, Influencer)
end

return module