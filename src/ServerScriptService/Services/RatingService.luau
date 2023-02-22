-- Author: n0pa

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local GameDataService = require(ServerScriptService.Services.GameDataService)

local RatingService = {}

local Mag = 6
local Precision = 10^Mag
local Reciprocal = 10^-Mag

function RatingService.GetRating(userID)
	local rating = GameDataService.GetKeyData("PlayerRating", userID)
	return rating and rating * Reciprocal
end

function RatingService.SetRating(userID, rating)
	local newRating = GameDataService.SetKeyData("PlayerRating", userID, math.floor(rating * Precision))

	local player = Players:GetPlayerByUserId(userID)
	if not player then return newRating end

	local leaderStats = Players:WaitForChild(player.Name):WaitForChild("leaderstats")
	if not leaderStats then return newRating end

	local ratingStat = leaderStats:WaitForChild("Rating")
	ratingStat.Value = newRating * Reciprocal

	return newRating
end

function RatingService.AddRating(userID, ratingDelta) -- USE THIS AS OFTEN AS POSSIBLE
	local newRating = GameDataService.UpdateKeyData("PlayerRating", userID, function (rating) return rating + math.floor(ratingDelta * Precision) end)

	local player = Players:GetPlayerByUserId(userID)
	if not player then return newRating end

	local leaderStats = Players:WaitForChild(player.Name):WaitForChild("leaderstats")
	if not leaderStats then return newRating end

	local ratingStat = leaderStats:WaitForChild("Rating")
	ratingStat.Value = newRating * Reciprocal

	return newRating
end

Players.PlayerAdded:Connect(function(player)
	local leaderStats = Instance.new("Folder")
	leaderStats.Name = "leaderstats"
	leaderStats.Parent = player

	local ratingStat = Instance.new("IntValue")
	ratingStat.Name = "Rating"
	ratingStat.Parent = leaderStats

	local rating = RatingService.GetRating(player.UserId) or RatingService.SetRating(player.UserId, 0)
	ratingStat.Value = rating
end)

return RatingService