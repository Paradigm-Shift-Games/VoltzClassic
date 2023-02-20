-- Author: n0pa

local ServerScriptService = game:GetService("ServerScriptService")

local RatingService = require(ServerScriptService.Services.RatingService)

local WeightData = {}
local WinningWeightFunctions = {}
local LosingWeightFunctions = {}

local RatingConstant = 10

local module = {}

local M_1_1_PI = 1/math.pi

--default sigmoid curve
local function s(x)
	return M_1_1_PI*math.atan(x) + 0.5
end

--[[
a = minimum value (-inf, b], 0
b = maximum value [a, inf), 1
c = rate of change (-inf, inf), 1
d = horizontal shift (-inf, inf), 0
]]--
local function S(x, a, b, c, d)
	a, d = a or 0, d or 0
	b, c = b or 1, c or 1
	
	return (b - a)*s(c*(x - d)) + a
end

--[[
a = rate of change (-inf, inf), 1
b = horizontal translation (-inf, inf), 0
c = vertical translation (-inf, inf), 0
]]
local function log(x, a, b, c)
	a = a or 1
	b, c = b or 0, c or 0
	
	return a*math.log(x - b) + c
end

local function logD(x1, x2, a, b, c)
	a = a or 0
	b, c = b or 1, c or 1

	return log((x1 + 1)/(x2 + 1), a, b, c)
end

local function length(tab)
	local accumulator = 0
	for _, _ in pairs(tab) do accumulator += 1 end

	return accumulator
end

local function max(tab)
	local max = -math.huge
	for _, v in pairs(tab) do
		if typeof(v) ~= "number" then continue end
		if max < v then max = v end
	end

	return (max == -math.huge and nil) or max
end

local function sum(tab)
	local accumulator = 0
	for _, v in ipairs(tab) do accumulator += v end
	
	return accumulator
end

--[[Time Weight]]--
WinningWeightFunctions[1] = function(dataTable)
	local minPossible = 0 -- [0, max]
	local maxPossible = 1 -- [min, 1]
	
	local times = dataTable["WinningTimes"]
	local maxTime = max(times)
	for stringUserID, playerTime in pairs(times) do
		local weight = (maxPossible - minPossible)*(playerTime/maxTime) + minPossible or 1
		
		WeightData[stringUserID] = weight
	end
end

--[[Distribution Weight]]--
WinningWeightFunctions[2] = function(dataTable)
	local D1 = 100*RatingConstant -- (-inf, inf), 1
	local D2 = 0 -- (-inf, inf), 0
	local D3 = 0 -- (-inf, inf), 0
	
	local minPossible = 0 -- [0, maxPossible], 0
	local maxPossible = 1 -- [minPossible, 1], 1
	local S1 = 1 -- (-inf, inf), 1
	local S2 = 0 -- (-inf, inf), 0
	
	local ratings = dataTable["WinningRatings"]
	local maxRating = max(ratings)
	for stringUserID, rating in pairs(ratings) do
		local difference = logD(rating, maxRating, D1, D2, D3)
		WeightData[stringUserID] *= S(difference, minPossible, maxPossible, S1, S2)
	end
end

--[[Difference Weight]]--
WinningWeightFunctions[3] = function(dataTable)	
	local D1 = 10*RatingConstant -- (-inf, inf), 1
	local D2 = 0 -- (-inf, inf), 0
	local D3 = 0 -- (-inf, inf), 0
	
	local S11 = 0.25 -- [0, S12], 0
	local S12 = 1 -- [S11, 1], 1
	local S13 = 1 -- (-inf, inf), 1
	local S14 = 0 -- (-inf, inf), 0
	
	local minPossible = 0.75 -- [0, maxPossible], 0
	local maxPossible = 1 -- [minPossible, 1], 1
	local S21 = 1 -- (-inf, inf), 1
	local S22 = 0 -- (-inf, inf), 0
	
	local losingRatings = {}
	for team, stringUserIDs in pairs(dataTable["LosingRatings"]) do
		for stringUserID, rating in pairs(stringUserIDs) do
			table.insert(losingRatings, rating)
		end
	end
	
	for stringUserID, winningRating in pairs(dataTable["WinningRatings"]) do
		local differences = {}
		for i, losingRating in ipairs(losingRatings) do differences[i] = logD(losingRating, winningRating, D1, D2, D3) end
		
		local weightedDiffs = {}
		for i, difference in ipairs(differences) do weightedDiffs[i] = S(difference, S11, S12, S13, S14)*losingRatings[i] end
		
		WeightData[stringUserID] *= S(sum(differences), minPossible, maxPossible, S21, S22)
	end
end

--[[Size Weight]]--
WinningWeightFunctions[4] = function(dataTable)
	--Desmos' Regression came up with these, f(1) = 1, f(2) = 2, f(3) = 2.8 [f(2) <= f(3) <= 3]
	--local D1 = 2.78406 -- (-inf, inf), 1
	--local D2 = -2.54728 -- (-inf, inf), 0
	--local D3 = -4.07435 -- (-inf, inf), 0
	
	local minPossible = 0.5 -- [0, max]
	local maxPossible = 1 -- [min, 1]
	
	local ratings = dataTable["WinningRatings"]
	local playerCount = length(ratings)
	local weight = (maxPossible - minPossible)*(1/playerCount) + minPossible
	for stringUserID, playerRating in pairs(ratings) do WeightData[stringUserID] *= weight end
end

--[[Losing Value Weight]]--
LosingWeightFunctions[1] = function(dataTable)
	local minPossible = 0.5 -- [0, 1]

	local teams = dataTable["LosingTimes"]
	for team, stringUserIDs in pairs(teams) do
		for stringUserID, playerTime in pairs(stringUserIDs) do
			local weight = minPossible

			WeightData[stringUserID] = weight
		end
	end
end

local function calculateWeights(dataTable)
	for _, weightFunction in ipairs(WinningWeightFunctions) do weightFunction(dataTable) end
	for _, weightFunction in ipairs(LosingWeightFunctions) do weightFunction(dataTable) end
end

local function formatData(inputTable, timeTable) --returns DataTable
	local winningRatings = {}
	local winningTimes = {}
	for index, userID in pairs(inputTable["WinningTeam"].userIDs) do
		local stringUserID = tostring(userID)
		winningRatings[stringUserID] = RatingService.GetRating(userID)
		winningTimes[stringUserID] = timeTable[stringUserID]["TotalTime"]
	end
	
	local losingRatings = {}
	local losingTimes = {}
	for team, teamData in pairs(inputTable["LosingTeams"]) do
		local ratings = {}
		local times = {}
		for index, userID in pairs(teamData.userIDs) do
			local stringUserID = tostring(userID)
			ratings[stringUserID] = RatingService.GetRating(userID)
			times[stringUserID] = timeTable[stringUserID]["TotalTime"]
		end
		losingRatings[team] = ratings
		losingTimes[team] = times
	end
	
	local DataTable = {
		["WinningRatings"] = winningRatings;
		["WinningTimes"] = winningTimes;
		["LosingRatings"] = losingRatings;
		["LosingTimes"] = losingTimes;
	}
	
	return DataTable
end

local function calculateWinningDeltas(dataTable)	
	local winningDeltas = {}
	for stringUserID, rating in pairs(dataTable["WinningRatings"]) do
		winningDeltas[stringUserID] = RatingConstant*WeightData[stringUserID]
	end
	
	return winningDeltas
end

local function calculateLosingDeltas(dataTable)
	local losingTeams = {}
	for team, stringUserIDs in pairs(dataTable["LosingRatings"]) do
		local losingDeltas = {}
		for stringUserID, rating in pairs(stringUserIDs) do
			losingDeltas[stringUserID] = RatingConstant*WeightData[stringUserID]
		end
		losingTeams[team] = losingDeltas
	end
	
	return losingTeams
end

function calculateRatingDeltas(dataTable)
	calculateWeights(dataTable)
	
	local ReturnTable = {
		["WinningRatingDeltas"] = calculateWinningDeltas(dataTable);
		["LosingRatingDeltas"] = calculateLosingDeltas(dataTable);
	}
	
	return ReturnTable
end

function module.GetRatingDeltas(inputTable, timeTable)
	local DataTable = formatData(inputTable, timeTable)
	local ReturnTable = calculateRatingDeltas(DataTable)
	
	return DataTable, ReturnTable
end

function module.ApplyRatings(dataTable, returnTable)
	warn("ApplyRatings", dataTable, returnTable)
	
	for stringUserID, ratingDelta in pairs(returnTable["WinningRatingDeltas"]) do
		local userID = tonumber(stringUserID)
		RatingService.AddRating(userID, ratingDelta)
	end
	
	local losingTeams = dataTable["LosingRatings"]
	for team, stringUserIDs in pairs(returnTable["LosingRatingDeltas"]) do
		local losingStringUserIDs = losingTeams[team]
		for stringUserID, ratingDelta in pairs(stringUserIDs) do
			local userID = tonumber(stringUserID)
			local rating = losingStringUserIDs[stringUserID]
			if rating < ratingDelta then RatingService.SetRating(userID, 0) return end
			
			RatingService.AddRating(userID, -ratingDelta)
		end
	end
end

return module

--[[
TeamData Template = {
	[teams: Team] = {
		userIDs = {
			[index: number] = userID: number
		};
		eliminationTimer: string = timer: number;
	}
}

TimeData Template = {
	[userIDs: string] = {
		DateTime: DateTime | nil
		TotalTime: number --Milliseconds
	}
}

InputTable Template = {
	WinningTeam = TeamData[teams];
	LosingTeams = {
		[teams: Team] = TeamData[teams]
	};
}

DataTable Template = {
	WinningRatings = {
		[userIDs: string] = ratings: number
	};
	WinningTimes = {
		[userIDs: string] = times: number
	};
	LosingRatings = {
		[teams: Team] = {
			[userIDs: string] = ratings: number
		}
	};
	LosingTimes = {
		[teams: Team] = {
			[userIDs: string] = times: number
		}
	};
}

ReturnTable Template = {
	WinningRatingDeltas = {
		[userIDs: string] = ratingDeltas: number
	};
	LosingRatingDeltas = {
		[teams: Team] = {
			[userIDs: string] = ratingDeltas: number
		}
	};
}
]]