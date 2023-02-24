-- Author: 4812571

local Queue = require(game.ServerScriptService.Classes.Datastructure.Queue)

-- Helper functions
local function hasContents(tab)
	for _, _ in pairs(tab) do return true end
	return false
end

-- Graph Class
local Graph = {}
Graph.__index = Graph

function Graph:Connect(node1, node2, connectionData)
	if not connectionData then connectionData = true end
	if not self.connections[node1] then self.connections[node1] = {} end
	if not self.connections[node2] then self.connections[node2] = {} end
	self.connections[node1][node2] = connectionData
	self.connections[node2][node1] = connectionData	
end

function Graph:DirectionalConnect(node1, node2, connectionData)
	if not connectionData then connectionData = true end
	if not self.connections[node1] then self.connections[node1] = {} end
	self.connections[node1][node2] = connectionData
end

function Graph:Disconnect(node1, node2)
	self.connections[node1][node2] = nil
	self.connections[node2][node1] = nil
end

function Graph:RemoveNode(node)
	for connectedNode, _ in pairs(self:GetConnections(node)) do
		self.connections[connectedNode][node] = nil
	end
	self.connections[node] = nil
end

function Graph:GetConnections(node)
	return self.connections[node] or {}
end

function Graph:GetConnectionData(node1, node2)
	return self.connections[node1][node2]
end

function Graph:GetComponent(startingNodes)
	local connections = self.connections
	local visited, component = {}, {}
	local queue = Queue.New()
	local hasConnections = false
	
	-- Initialize startingNodes
	if type(startingNodes) ~= "table" or getmetatable(startingNodes) then startingNodes = {startingNodes} end	
	for _, node in ipairs(startingNodes) do
		table.insert(component, node)
		visited[node] = true
		queue:Push(node)
	end
	
	local color = BrickColor.Random()
	while queue.Length > 0 do
		local s = queue:Shift()
		-- if s.structure then Colorizer.DebugColor(s.structure, color) wait(0.06) end
		for i, _ in pairs(connections[s] or {}) do
			if not visited[i] then
				table.insert(component, i)
				visited[i] = true
				queue:Push(i)
			end
		end
	end
	
	return component
end

function Graph:IsConnected(startingNode, searchingNode)
	local connections = self.connections
	local visited = {}
	local queue = Queue.New()
	visited[startingNode] = true
	queue:Push(startingNode)
	while queue.Length > 0 do
		local s = queue:Shift()
		for i, _ in pairs(connections[s]) do
			if not visited[i] then
				if i == searchingNode then return true end
				visited[i] = true
				queue:Push(i)
			end
		end
	end

	return false
end

-- Service
local module = {}

function module.New()
	local object = {
		connections = {}
	}

	return setmetatable(object, Graph)
end

return module