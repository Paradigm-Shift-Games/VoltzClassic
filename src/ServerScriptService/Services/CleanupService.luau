-- Author: 4812571

local CleanupService = {}
local Reserved = {}

local CleanupFunctions = {}

function CleanupService.Bind(key, func)
	CleanupFunctions[key] = func
end

function CleanupService.Reserve(Object, key)
	if not Reserved[Object] then Reserved[Object] = {} end
	Reserved[Object][key] = true
end

function CleanupService.Unreserve(Object, key)
	Reserved[Object][key] = nil
end

function CleanupService.Free(Object)
	Reserved[Object] = nil
end

function CleanupService.Clean(Object)
	-- print("Cleaning!")
	if not Reserved[Object] then return end
	for key, _ in pairs(Reserved[Object]) do
		CleanupFunctions[key](Object)
	end
	CleanupService.Free(Object)
end

return CleanupService

