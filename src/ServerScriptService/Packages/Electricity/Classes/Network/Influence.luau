-- Author: 4812571

-- InfluenceComponent Class
local InfluenceComponent = {}
InfluenceComponent.__index = InfluenceComponent

function InfluenceComponent:Run(delta)
	local influences = self.influences
	local storageComponent = self.network.storageComponent
	for _, i in ipairs(self.indecies) do
		local influence = (influences[i] * delta)
		if influence > 0 then storageComponent:Push(influence) end
		if influence < 0 then storageComponent:Pull(-influence) end
	end
end

function InfluenceComponent:UpdateActivity()
	local network = self.network
	local influences = self.influences
	local eventComponent = network.eventComponent
	local producing = false
	
	-- Update
	for _, i in ipairs(self.indecies) do
		local influence = math.sign(influences[i])
		if influence == 1 then producing = true end
	end
	network.producing = producing
end

function InfluenceComponent:Attach(influencer)
	if not self.indecies[influencer.priority] then
		table.insert(self.indecies, influencer.priority)
		self.influences[influencer.priority] = 0
		table.sort(self.indecies)
	end
	self.influences[influencer.priority] += influencer.influence
end

function InfluenceComponent:Modify(priority, delta)
	self.influences[priority] += delta
end

-- Service
local module = {}

function module.New(network)
	local object = {
		network = network;
		indecies = {};
		influences = {};
	}
	setmetatable(object, InfluenceComponent)
	object:UpdateActivity()
	
	return object
end

return module