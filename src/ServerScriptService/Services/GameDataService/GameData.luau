-- Author: n0pa

local DataStoreService = game:GetService("DataStoreService")

local GameData = {}

local GameData = {}

function GameData.GetGameData(name)
	return GameData[name]
end

function GameData.SetGameData(name, iteration, defaultValue, allowedTypes, isOrdered)
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

GameData.SetGameData("BannedPlayers", 0, 0, {"number", "string"})

GameData.SetGameData("PlayerRating", 1, 0, {"number"}, true)
GameData.SetGameData("PlayerWins", 0, 0, {"number"}, true)
GameData.SetGameData("PlayerLosses", 0, 0, {"number"}, true)

GameData.SetGameData("PlayerGames", 0, "", {"string"})

GameData.SetGameData("ActiveGames", 0, -1, {"number"}, true)
GameData.SetGameData("TerminatedGames", 0, -1, {"number"}, true)

return GameData