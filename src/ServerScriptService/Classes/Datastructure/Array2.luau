-- Author: n0pa

-- Tested: true

local module = {}
module.__index = module
function module.__add(left, right)
	local result = {}
	table.move(left, 1, #left.Data, 1, result)
	table.move(right, 1, #right.Data, #result, result)

	return module.New(result)
end
setmetatable(module, {__call = function(t, data) return module.Frommodule(data or {}) end})

function module.New(data)
	data = data or {}
	local self = setmetatable({}, module)

	self.Data = data

	self.Length = #data
	self.StartPointer = 0
	self.EndPointer = self.Length + 1

	return self
end

function module.Push(self, element)
	self.Data[self.EndPointer] = element
	self.EndPointer += 1
	self.Length += 1
end

function module.Unshift(self, element)
	self.Data[self.StartPointer] = element
	self.StartPointer -= 1
	self.Length += 1
end

function module.Shift(self)
	if self.Lenth == 0 then return end

	self.StartPointer += 1
	local shifted = self.Data[self.StartPointer]
	self.Data[self.StartPointer] = nil
	self.Length -= 1

	return shifted
end

function module.Pop(self)
	if self.Lenth == 0 then return end

	self.EndPointer -= 1
	local popped = self.Data[self.EndPointer]
	self.Data[self.EndPointer] = nil
	self.Length -= 1

	return popped
end

function module.Get(self, index)
	return self.Data[self.StartPointer + index]
end

function module.ForEach(self, func)
	local index = 0
	for i = self.StartPointer + 1, self.EndPointer - 1 do
		index += 1
		func(index, self.Data[i])
	end
end

function module.Reset(self)
	self.StartPointer = 0
	self.EndPointer = 1
end

function module.Clear(self)
	self.Data = {}

	self:Reset()
	self.Length = 0
end

function module.FromTable(tab)
	-- 5x to 10x faster - Sheikh
	local self = module.New()

	local length = #tab
	table.move(tab, 1, length, self.EndPointer, self.Data)

	self.EndPointer += length
	self.Length += length

	print(self.Length)

	return self
end

return module