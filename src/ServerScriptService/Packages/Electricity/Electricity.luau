local Graph = require(game.ServerScriptService.Classes.Datastructure.Graph)
local LeakEffect = require(game.ServerScriptService.Packages.Electricity.LeakEffect)
local Events = require(game.ServerScriptService.Packages.Electricity.Events)
local Network = require(game.ServerScriptService.Packages.Electricity.Classes.Network)


local module = {}

-- Data
local nodeGraph = Graph.New()

-- Node Actions
function module.AddNode(node)
	LeakEffect.UpdateLeaks(node)
	Network.New(node, nodeGraph)
end

function module.ConnectNodes(node1, node2)
	nodeGraph:Connect(node1, node2)
	LeakEffect.UpdateLeaks(node1)
	LeakEffect.UpdateLeaks(node2)
	local network1, network2 = node1.network, node2.network
	if network1 ~= network2 then
		network1:Remove()
		network2:Remove()
		Network.New(node1, nodeGraph)
	end
end

function module.RemoveNode(node)
	Events.NodeRemoved:Fire(node)
	for connectedNode, _ in pairs(nodeGraph:GetConnections(node)) do
		nodeGraph:Disconnect(node, connectedNode)
		LeakEffect.UpdateLeaks(connectedNode)
		if not nodeGraph:IsConnected(node, connectedNode) then Network.New(connectedNode, nodeGraph) end
	end
	LeakEffect.Clean(node)
	node.network:Remove()
	node:Remove()
	nodeGraph:RemoveNode(node)
end

return module
