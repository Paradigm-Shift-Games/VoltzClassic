-- Author: 4812571

local Event = require(game.ServerScriptService.Classes.Event.Event)

-- Hook Class
local Hook = {type = script.Name}
Hook.__index = Hook

function Hook:BindNode(node)
	if self.node then error("Attempt to overwrite node binding!") end
	node.boundObjects[self] = true
	self.node = node
	if node.network then self:BindNetwork(node.network) end
end

function Hook:BindNetwork(network)
	network.eventComponent:AttachHook(self)
	self.network = network
end

function Hook:Unbind()
	if self.node then self.node.boundObjects[self] = nil end
	if self.network then self.network.eventComponent:UnattachHook(self) end
	self.node = nil
	self.network = nil
end

function Hook:Connect(func)
	if self.connected then error("Already Connected!") end
	self.connected = true
	return self.event:Connect(func)
end

function Hook:Fire(...)
	self.event:Fire(self.node, ...)
end

-- Service
local module = {}

function module.New(name)
	local object = {
		connected = false;
		name = name;
		event = Event.New();
	}

	return setmetatable(object, Hook)
end

return module