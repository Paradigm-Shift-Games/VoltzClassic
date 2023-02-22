-- Author: 4812571

-- ArrayGraph Class
local HashList = require(game.ServerScriptService.Classes.Datastructure.HashList)
local Array = require(game.ServerScriptService.Classes.Datastructure.Array)

local ArrayGraph = {}
ArrayGraph.__index = ArrayGraph


function ArrayGraph:Connect(node1, node2)
	if not self.connections[node1] then self.connections[node1] = HashList.New() end
	if not self.connections[node2] then self.connections[node2] = HashList.New() end
	self.connections[node1]:Insert(node2)
	self.connections[node2]:Insert(node1)
end

function ArrayGraph:Disconnect(node1, node2)
	self.connections[node1]:Remove(node2)
	self.connections[node2]:Remove(node1)
end

function ArrayGraph:RemoveNode(node)
	local connected = self:GetConnections(node)
	for i = connected:GetSize(), 1, -1 do self:Disconnect(node, connected[i]) end
	self.connections[node] = nil
end

function ArrayGraph:GetConnectionData(node1, node2)
	return self.connectionData[node1][node2]
end

function ArrayGraph:GetConnections(node)
	return self.connections[node] and self.connections[node].array or Array.New()
end

-- Service
local module = {}

function module.New()
	local object = {
		connections = {}
	}
	
	return setmetatable(object, ArrayGraph)
end

return module