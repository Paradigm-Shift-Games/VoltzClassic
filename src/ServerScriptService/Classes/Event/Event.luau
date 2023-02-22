-- Author: 4812571
local Connection = require(game.ServerScriptService.Classes.Event.Connection)

-- Event Class
local Event = {}
Event.__index = Event

function Event:Fire(...)
	for _, connection in ipairs(self.connections) do connection:Fire(...) end
end

function Event:Connect(func)
	local connection = Connection.New(self, func)
	table.insert(self.connections, connection)
	return connection
end

-- Service
local module = {}

function module.New()
	local object = {
		connections = {}
	}

	return setmetatable(object, Event)
end

return module