	-- Author: 4812571

-- Simple Array Class. Has Size Lookup and insert/remove functions

-- This object is not pairs safe. Remember to use ipairs

-- Array Class
local Array = {}
Array.__index = Array

function Array:Insert(index, value)
	table.insert(self, index, value)
	self.size += 1
end

function Array:Remove(index)
	table.remove(self, index)
	self.size -= 1
end

function Array:FindValue(value)
	return table.find(self, value)
end

function Array:RemoveValue(value)
	local index = self:FindValue(value)
	if index then self:Remove(index) end
end

function Array:GetSize(value)
	return self.size
end

-- Service
local module = {}

function module.New()
	local object = {size = 0}
	
	return setmetatable(object, Array)
end

return module