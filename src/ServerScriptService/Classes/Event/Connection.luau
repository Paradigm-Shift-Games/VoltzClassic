-- Author: 4812571

-- Connection Class
local Connection = {}
Connection.__index = Connection

function Connection:Fire(...)
	self.func(...)
end

function Connection:Disconnect()
	local index = table.find(self.event.connections, self)
	table.remove(self.event.connections, index)
end

-- Service
local module = {}

function module.New(event, func)
	local object = {
		event = event;
		func = func;
	}

	return setmetatable(object, Connection)
end

return module