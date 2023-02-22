-- Author: 4812571

-- LeakComponent Class
local LeakComponent = {}
LeakComponent.__index = LeakComponent

function LeakComponent:Run(delta)
	local storageComponent = self.network.storageComponent
	storageComponent:Pull(delta * self.leakCount * 5)	
end

-- Service
local module = {}

function module.New(network, nodes)
	local leakCount = 0
	for _, node in ipairs(nodes) do leakCount += (node.leaks or 0) end
	local object = {
		network = network;
		leakCount = leakCount;
	}
	return setmetatable(object, LeakComponent)
end


return module