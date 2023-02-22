-- Author: 4812571

-- Hashlists are ordered, array based datastructures with the ability to insert/remove in the same manner as a hashtable

local Array = require(game.ServerScriptService.Classes.Datastructure.Array)

-- HashList Class
local HashList = {}
HashList.__index = HashList

function HashList:Insert(value)
	if self.hash[value] then return end
	local index = self.array:GetSize() + 1
	self.hash[value] = true
	self.array:Insert(index, value)
end

function HashList:Remove(value)
	if not self.hash[value] then return end
	self.hash[value] = nil
	self.array:RemoveValue(value)
end

-- Service
local module = {}

function module.New()
	local object = {
		hash = {};
		array = Array.New()
	}
	
	return setmetatable(object, HashList)
end

return module