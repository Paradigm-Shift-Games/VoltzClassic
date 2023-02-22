-- Author: 4812571

local Hook = require(game.ServerScriptService.Packages.Electricity.Classes.NetworkObjects.Hook)
local Events = require(game.ServerScriptService.Packages.Electricity.Events)

-- TransferComponent Class
local TransferComponent = {}
TransferComponent.__index = TransferComponent

function TransferComponent:Run(delta)
	local storageComponent = self.network.storageComponent
	local transferLoad = 0
	for network, rate in pairs(self.transferring) do
		transferLoad += math.min(network:GetCapacity(), delta * rate)
	end
	if transferLoad == 0 then return end
	local drawnCharge = storageComponent:Pull(transferLoad)
	local satisfaction = drawnCharge / transferLoad
	local satisfactionFactor = satisfaction * delta
	
	for network, rate in pairs(self.transferring) do network.storageComponent:Push(satisfactionFactor * rate) end
end

local function hasContents(lookupTab)
	for _, _ in pairs(lookupTab) do return true end
	return false
end

function TransferComponent:Unattach(transferLine)
	if transferLine.clear then error("Double Unattach!") end
	transferLine.clear = true
	
	local targetNetwork = transferLine.targetNetwork
	local targetNode = transferLine.targetNode
	print("    TS Unattach", "Line:", transferLine.id, "Node:", targetNode.id, "Network", targetNetwork.id)
	-- Unbind Line
	transferLine.targetHook:Unbind()
	transferLine.targetHook = nil
	
	-- Clear line 
	self.lines[targetNode][transferLine] = nil
	if not hasContents(self.lines[targetNode]) then self.lines[targetNode] = nil end
	
	-- Clear transferring
	self.transferring[targetNetwork] -= transferLine.transferRate
	if self.transferring[targetNetwork] == 0 then self.transferring[targetNetwork] = nil end
end

function TransferComponent:Attach(transferLine)
	transferLine.clear = false	
	
	local targetNode = transferLine.targetNode
	local targetNetwork = targetNode.network
	
	-- Hook Network Rebuilds
	if transferLine.targetHook then transferLine.targetHook:Unbind() end
	local hook = Hook.New("NetworkSet")
	hook:Connect(function() self:Unattach(transferLine) self:Attach(transferLine) end)
	hook:BindNode(targetNode)
	transferLine.targetHook = hook
	
	transferLine.targetNetwork = targetNetwork
	
	-- Set Transfer Amount
	if not self.transferring[targetNetwork] then self.transferring[targetNetwork] = 0 end
	self.transferring[targetNetwork] += transferLine.transferRate
	
	-- Register
	if not self.lines[targetNode] then self.lines[targetNode] = {} end
	self.lines[targetNode][transferLine] = true
end

function TransferComponent:Remove()
	self.connection:Disconnect()
end

-- Service
local module = {}

function module.New(network)
	local object = {
		network = network;
		lines = {};
		transferring = {};
	}
	
	object.connection = Events.NodeRemoved:Connect(function(node)
		for transferLine, _ in pairs(object.lines[node] or {}) do
			transferLine:Unbind()
		end
		object.lines[node] = nil
	end)
	
	
	
	return setmetatable(object, TransferComponent)
end

return module