-- Author: n0pa

local module = {}
module.__index = module

local function getParent(index)
	return math.floor(0.5*index - 0.5)
end

local function getChild1(index)
	return 2*index + 1
end

local function getChild2(index)
	return 2*index + 2
end

local function getChildren(index)
	local child1 = 2*index + 1
	return {child1, child1 + 1}
end

local function swap(self, index1, index2)
	if index1 == index2 then return end

	local bundle1 = self.Bundles[index1]
	local bundle2 = self.Bundles[index2]

	self.Bundles[index1] = bundle2
	self.LookUp[bundle1.Data] = index2

	self.Bundles[index2] = bundle1
	self.LookUp[bundle2.Data] = index1
end

local function shiftUp(self, index)
	local parent = getParent(index)
	if parent < 0 then return end
	
	if self.Bundles[parent].Priority >= self.Bundles[index].Priority then return end

	swap(self, index, parent)
	shiftUp(self, parent)
end

local function shiftDown(self, index)
	local last = self.Length - 1
	for _, child in ipairs(getChildren(index)) do		
		if child > last then return end
		
		if self.Bundles[index].Priority >= self.Bundles[child].Priority then continue end

		swap(self, index, child)
		shiftDown(self, child)
		return
	end
end

function module.New(priorityFunc)
	local self = setmetatable({}, module)

	self.Bundles = {}
	self.LookUp = {}
	self.PriorityFunc = priorityFunc

	self.Length = 0;

	return self
end

module.Insert = function(self, element, ...)
	local priority = self.PriorityFunc(element, ...)
	if not priority then --[[warn(element, ..., "Has no priority")]] return end
	
	local index = self.Length
	self.Bundles[index] = {
		["Data"] = element;
		["Priority"] = priority;
	}
	self.LookUp[element] = index
	self.Length += 1
	
	shiftUp(self, index)
end

function module.Remove(self, element)
	local index = self.LookUp[element]
	local last = self.Length - 1
	swap(self, index, last)

	self.Bundles[last] = nil
	self.LookUp[last] = nil
	self.Length -= 1
	
	shiftUp(self, index)
	shiftDown(self, index)
end

function module.Shift(self)
	local shifted = self.Bundles[0].Data

	local last = self.Length - 1
	swap(self, 0, last)

	self.Bundles[last] = nil
	self.LookUp[shifted] = nil
	self.Length -= 1

	shiftDown(self, 0)
	
	return shifted
end

function module.GetMax(self)
	return (self.Bundles[0] or {}).Data
end

function module.ChangePriority(self, index, priority)
	self.Bundles[index].Priority = priority

	shiftUp(self, index)
	shiftDown(self, index)
end

function module.IndexOf(self, element)
	return self.LookUp[element]
end

function module.Clear(self)
	self.Bundles = {}
	self.LookUp = {}
	self.Length = 0;
end

return module