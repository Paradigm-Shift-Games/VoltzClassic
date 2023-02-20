-- Author: n0pa

local DataStoreService = game:GetService("DataStoreService")

local GameData = require(script:WaitForChild("GameData"))

local GameDataService = {}

local function invalidDataOrKey(dataStoreName, key)
	if not dataStoreName then 
		warn("Attemping to access nil DataStore")
		return true
	end

	if not key then 
		warn("Attemping to access DataStore", dataStoreName, "with nil key")
		return true
	end

	local gameData = GameData.GetGameData(dataStoreName)
	if not gameData then
		warn("Attemping to access non-existant DataStore", dataStoreName)
		return true
	end

	return false, gameData
end

GameDataService.GetKeyData = function(dataStoreName, key)
	local isInvalid, gameData = invalidDataOrKey(dataStoreName, key)
	if isInvalid then return end

	key = (typeof(key) == "number" and key) or (key:IsA("Player") and key.UserId)

	local success, value = pcall(function()
		return gameData["DataStore"]:GetAsync(key)
	end)

	if success then
		print("Successfully retrieved value", value, "from key", key, "in DataStore", dataStoreName)
		return value
	else
		print("Unsuccessfully retrieved value", value, "from key", key, "in DataStore", dataStoreName)
		return
	end
end

GameDataService.AddKeyToDataStore = function(dataStoreName, key, value)
	local isInvalid, gameData = invalidDataOrKey(dataStoreName, key)
	if isInvalid then return end

	key = (typeof(key) == "number" and key) or (key:IsA("Player") and key.UserId)

	if not gameData["AllowedTypes"][typeof(value)] then
		local default = gameData["DefaultValue"]

		warn("Attempting to set unallowed value through key", key, "in DataStore", dataStoreName, "\n Setting value to default value", default)
		value = default
	end

	if GameDataService.GetKeyData(dataStoreName, key) ~= nil then
		warn("Attempting to add pre-existant key", key, "in DataStore", dataStoreName)
		return
	end

	local success, err = pcall(function()
		gameData["DataStore"]:SetAsync(key, value)
	end)

	if success then
		print("Successfully added key", key, "with value", value, "to DataStore", dataStoreName)
		return value
	else
		print("Unsuccessfully added key", key, "with value", value, "to DataStore", dataStoreName)
		return err
	end
end

GameDataService.SetKeyData = function(dataStoreName, key, value)
	local isInvalid, gameData = invalidDataOrKey(dataStoreName, key)
	if isInvalid then return end

	key = (typeof(key) == "number" and key) or (key:IsA("Player") and key.UserId)

	GameDataService.AddKeyToDataStore(dataStoreName, key, value)

	if not gameData["AllowedTypes"][typeof(value)] then
		warn("Attempting to set unallowed value", value, "to key", key, "in DataStore", dataStoreName)
		return
	end

	local success, newValue = pcall(function()
		return gameData["DataStore"]:SetAsync(key, value)
	end)

	if success then
		print("Successfully set value", value, "to key", key, "in DataStore", dataStoreName)
		return value
	else
		print("Unsuccessfully set value", value, "to key", key, "in DataStore", dataStoreName)
		return
	end
end

GameDataService.UpdateKeyData = function(dataStoreName, key, func)
	local isInvalid, gameData = invalidDataOrKey(dataStoreName, key)
	if isInvalid then return end

	key = (typeof(key) == "number" and key) or (key:IsA("Player") and key.UserId)

	local success, value = pcall(function()
		return gameData["DataStore"]:UpdateAsync(key, func)
	end)

	if success then
		print("Successfully updated value", value, "with key", key, "in DataStore", dataStoreName)
		return value
	else
		print("Unsuccessfully updated value", value, "with key", key, "in DataStore", dataStoreName)
		return
	end
end

GameDataService.IncremenKeyData = function(dataStoreName, key, delta)
	local isInvalid, gameData = invalidDataOrKey(dataStoreName, key)
	if isInvalid then return end

	key = (typeof(key) == "number" and key) or (key:IsA("Player") and key.UserId)

	local oldValue = GameDataService.GetKeyData(dataStoreName, key)
	if typeof(oldValue) ~= "number" or typeof(delta) ~= "number" then
		warn("Attempting to increment either non-number value", oldValue, "or by non-number delta", delta, "through key", key, "in DataStore", dataStoreName)
		return
	end

	local success, newValue = pcall(function()
		return gameData["DataStore"]:IncrementAsync(key, delta)
	end)

	if success then
		print("Successfully incremented value from", oldValue, "to", newValue, "by delta", delta, "from key", key, "in DataStore", dataStoreName)
		return newValue
	else
		print("Unsuccessfully incremented value from", oldValue, "to", newValue, "by delta", delta, "from key", key, "in DataStore", dataStoreName)
		return
	end
end

GameDataService.RemoveKeyFromDataStore = function(dataStoreName, key)
	local isInvalid, gameData = invalidDataOrKey(dataStoreName, key)
	if isInvalid then return end

	key = (typeof(key) == "number" and key) or (key:IsA("Player") and key.UserId)

	if not GameDataService.GetKeyData(dataStoreName, key) then
		warn("Attempting to remove non-existant key", key, "in DataStore", dataStoreName)
		return 
	end

	local success, value = pcall(function()
		return gameData["DataStore"]:RemoveAsync(key)
	end)

	if success then
		print("Successfully removed key", key, "from DataStore", dataStoreName)
		return value
	else
		print("Unsuccessfully removed key", key, "from DataStore", dataStoreName)
		return
	end
end

return GameDataService