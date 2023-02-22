-- Author: 4812571

local IdStream = require(game.ServerScriptService.Classes.Datastructure.IdStream)
local idStream = IdStream.New()

-- Template Class
local Template = {type = script.Name}
Template.__index = Template

function Template:BindNode(node)
	if self.node then error("Attempt to overwrite node binding!") end
	node.boundObjects[self] = true
	self.node = node
	if node.network then self:BindNetwork(node.network) end
	-- Binding Code
end

function Template:BindNetwork(network)
	print("BindNetwork")
	network.transferComponent:Attach(self)
	self.network = network
end

function Template:Unbind()
	print("TL Unbind", self.network and self.network.id)
	if self.node then self.node.boundObjects[self] = nil end
	if self.network then print("Unbinding") self.network.transferComponent:Unattach(self) end
	self.node = nil
	self.network = nil
end

-- Service
local module = {}

function module.New(targetNode, transferRate)
	if not targetNode then error("TransferLine must have target!") end
	local object = {
		id = idStream:Next();
		targetNode = targetNode;
		transferRate = transferRate;
	}
	
	return setmetatable(object, Template)
end

return module