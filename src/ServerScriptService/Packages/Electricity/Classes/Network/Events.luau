-- Author: 4812571

-- EventComponent Class
local EventComponent = {}
EventComponent.__index = EventComponent

local function hasContents(lookupTab)
	for _, _ in pairs(lookupTab) do return true end
	return false
end

function EventComponent:Fire(name, ...)
	self.iterating = true;
	for hook, _ in pairs(self.hooks[name] or {}) do hook:Fire(...) end
	for v, _ in pairs(self.deferred) do self:AttachHook(v) print("Handled it!") end
	self.deferred = {}
	self.iterating = false
end

function EventComponent:AttachHook(hook)
	if not self.hooks[hook.name] then self.hooks[hook.name] = {} end
	if self.iterating then self.deferred[hook] = true print("Caught it!") return end
	self.hooks[hook.name][hook] = true
end

function EventComponent:UnattachHook(hook)
	self.hooks[hook.name][hook] = nil
	if not hasContents(self.hooks[hook.name]) then self.hooks[hook.name] = nil end
end



-- Service
local module = {}

function module.New(network)
	local object = {
		network = network;
		hooks = {};
		deferred = {};
		iterating = false;
	}
	
	return setmetatable(object, EventComponent)
end

return module