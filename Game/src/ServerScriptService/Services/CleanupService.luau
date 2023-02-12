-- Author: 4812571

local module = {}
local Reserved = {}

local CleanupFunctions = {}

module.Bind = function(key, func)
	CleanupFunctions[key] = func
end

module.Reserve = function(Object, key)
	if not Reserved[Object] then Reserved[Object] = {} end
	Reserved[Object][key] = true
end

module.Unreserve = function(Object, key)
	Reserved[Object][key] = nil
end

module.Free = function(Object)
	Reserved[Object] = nil
end

module.Clean = function(Object)
	--print("Cleaning!")
	if not Reserved[Object] then return end
	for key, _ in pairs(Reserved[Object]) do
		CleanupFunctions[key](Object)
	end
	module.Free(Object)
end

return module

