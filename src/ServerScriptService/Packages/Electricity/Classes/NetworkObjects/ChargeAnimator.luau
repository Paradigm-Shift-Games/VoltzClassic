-- Author: 4812571

local BarAnimator = require(game.ServerScriptService.Classes.BarAnimator)

-- ChargeAnimator Class
local ChargeAnimator = {type = script.Name}
ChargeAnimator.__index = ChargeAnimator

function ChargeAnimator:BindNode(node)
	if self.node then error("Attempt to overwrite node binding!") end
	node.boundObjects[self] = true
	self:SetFill((node.storage and node.storage > 0) and node.charge / node.storage or 0)
	self.node = node
	if node.network then self:BindNetwork(node.network) end
	-- Binding Code
end

function ChargeAnimator:BindNetwork(network)
	network.storageComponent:AttachAnimator(self)
	self.network = network
end

function ChargeAnimator:SetFill(percentage)
	self.barAnimator:SetFill(percentage)
end
	
function ChargeAnimator:AnimateFill(percentage)
	self.barAnimator:AnimateFill(percentage)
end


-- Service
local module = {}

function module.New(bar, weldedTo)
	local object = {
		barAnimator = BarAnimator.New(bar, weldedTo)
	}
	
	return setmetatable(object, ChargeAnimator)
end

return module