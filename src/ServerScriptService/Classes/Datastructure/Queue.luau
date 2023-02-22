-- Author: n0pa

-- Queues are array like structures that optimize getting elements from either end

local module = {}
module.__index = module

function module.New()
	local self = setmetatable({}, module)

	self.Data = {}

	self.StartPointer = 0
	self.EndPointer = 1
	self.Length = 0

	return self
end

function module.Push(self, element)
	self.Data[self.EndPointer] = element
	self.EndPointer += 1
	self.Length += 1
end

function module.Shift(self)
	self.StartPointer += 1
	local shifted = self.Data[self.StartPointer]
	self.Data[self.StartPointer] = nil
	self.Length -= 1

	return shifted
end

function module.Pop(self)
	self.EndPointer -= 1
	local popped = self.Data[self.EndPointer]
	self.Data[self.EndPointer] = nil
	self.Length -= 1

	return popped
end

function module.Clear(self)
	self.Data = {}

	self.StartPointer = 0
	self.EndPointer = 1
	self.Length = 0
end

return module