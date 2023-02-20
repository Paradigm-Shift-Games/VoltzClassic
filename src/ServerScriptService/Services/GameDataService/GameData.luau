-- Author: n0pa

local DataStoreService = game:GetService("DataStoreService")

local GameData = {}

local module = {}

function module.GetGameData(name)
	return GameData[name]
end

function module.SetGameData(name, iteration, defaultValue, allowedTypes, isOrdered)
	local types = {}
	for _, v in pairs(allowedTypes) do types[v] = true end

	GameData[name] = {
		["Iteration"] = iteration;
		["AllowedTypes"] = types;
		["DefaultValue"] = defaultValue;
	}
	if isOrdered then GameData[name]["DataStore"] = DataStoreService:GetOrderedDataStore(name..GameData[name]["Iteration"]) return end
	GameData[name]["DataStore"] = DataStoreService:GetDataStore(name..GameData[name]["Iteration"]) 
end

module.SetGameData("BannedPlayers", 0, 0, {"number", "string"})

module.SetGameData("PlayerRating", 1, 0, {"number"}, true)
module.SetGameData("PlayerWins", 0, 0, {"number"}, true)
module.SetGameData("PlayerLosses", 0, 0, {"number"}, true)

module.SetGameData("PlayerGames", 0, "", {"string"})

module.SetGameData("ActiveGames", 0, -1, {"number"}, true)
module.SetGameData("TerminatedGames", 0, -1, {"number"}, true)

return module