-- Author: 4812571

local module = {}
local Reserved = {}

local CleanupFunctions = {}

function module.Bind(key, func)
	CleanupFunctions[key] = func
end

function module.Reserve(Object, key)
	if not Reserved[Object] then Reserved[Object] = {} end
	Reserved[Object][key] = true
end

function module.Unreserve(Object, key)
	Reserved[Object][key] = nil
end

function module.Free(Object)
	Reserved[Object] = nil
end

function module.Clean(Object)
	--print("Cleaning!")
	if not Reserved[Object] then return end
	for key, _ in pairs(Reserved[Object]) do
		CleanupFunctions[key](Object)
	end
	module.Free(Object)
end

return module

