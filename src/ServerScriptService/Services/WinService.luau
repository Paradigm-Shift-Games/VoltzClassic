-- Author: n0pa, Styx

local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")

local RatingService = require(ServerScriptService.Services.RatingService)
local DiscordService = require(ServerScriptService.Services.DiscordService)

local Enabled = true --Just for future stuff.
local Debounce = false

local teamSpawnCounts = {}

local function sizeOf(t)
	local size = 0
	for _, v in pairs(t) do
		size += 1
	end
	return size
end

local WinService = {}

local function getTeamLifeCounts() --Finds all teams and stores them and how many players are still alive in teams
	local teams = {}
	for _, team in ipairs(Teams:GetTeams()) do
		teams[team] = 0 --0 initial players

		for _, player in ipairs(team:GetPlayers()) do --Adds 1 to teams[team] per living player
			if not player.Character then continue end

			local Humanoid = player.Character:FindFirstChild("Humanoid")
			if Humanoid and Humanoid.Health > 0 then teams[team] += 1 end
		end
	end

	return teams
end

local function onSpawnTagAdded(spawnpad)
	local team = spawnpad:WaitForChild("Team")
	if not teamSpawnCounts[team.Value] then teamSpawnCounts[team.Value] = 0 end
	
	teamSpawnCounts[team.Value] += 1
end

local function onSpawnTagRemoved(spawnpad)
	local team = spawnpad:WaitForChild("Team")
	teamSpawnCounts[team.Value] -= 1

	WinService.scan()
end

local function writePlayerTexts(team, ratings, intendedSign, text)
	if not text then text = "" end
	
	for _, player in pairs(team:GetPlayers()) do
		local ratingEarned = ratings[player]
		local currentRating = RatingService.getRating(player)
		if not currentRating then currentRating = "NaN" continue end
		
		text ..= "\n"..player.Name..":   **"..currentRating.."** "..intendedSign..math.floor(math.abs(ratingEarned) + 0.5)
	end

	return text
end

function WinService.sendMatchResultAndUpdateRatings(livingTeamCount, lastTeam, remainingTeams)
	--if #Players:GetPlayers() <= 1 and #Teams:GetTeams() <= 1 then return end

	remainingTeams[lastTeam] = true
	
	if livingTeamCount > 1 then return end
	print("~~~~~!Winner Winner!~~~~~")

	local dataTable = {
		["WinningTeam"] = lastTeam;
		["RemainingTeams"] = remainingTeams;
		["PlayerTimes"] = {};
	}

	local weightTable = {
		["ConstantMultiplier"] = 10;
		["DifferenceWeights"] = {--(100*ConstantMultiplier, 0.75, 0.2, 60) works well
			[1] = 1000;
			[2] = 0.75;
			[3] = 0.2;
			[4] = 60;
		};
	}

	local newMessage = DiscordService.Content.New() --everything is broken, will fix tomorrow.
	local newEmbed = DiscordService.Embed.New()

	newEmbed:SetTitle("Match Results")

	local winningRatings, winningTeam = RatingService.calculateWinningRatings(dataTable, weightTable)
	local text = ":trophy: **"..winningTeam.Name.."** :trophy:"
	text = writePlayerTexts(winningTeam, winningRatings, "+ ", text)
	text ..= "\n"

	local remainingRatings, remainingTeams = RatingService.calculateLosingRatings(dataTable, weightTable)
	for team, _ in pairs(remainingTeams) do --k = team, v = true
		local ratings = remainingRatings[team]

		text = writePlayerTexts(team, ratings, "- ", text)
	end

	newEmbed:SetDescription(text)
	newMessage:AddEmbed(newEmbed)

	if RunService:IsStudio() then return end
	
	DiscordService.SendContent("winHook", newMessage)
	RatingService.updateRatings(dataTable, weightTable)

	return
end

function WinService.scan()
	if not Enabled or Debounce then return end
	
	Debounce = true

	local teamLifeCounts = getTeamLifeCounts()
	local livingTeams = {}
	local remainingTeams = {}

	for team, lifeCount in pairs(teamLifeCounts) do --Adds all living teams to livingTeams
		if lifeCount < 1 then
			remainingTeams[team] = true
			return
		end
		
		livingTeams[team] = true
	end

	for team, spawnCount in pairs(teamSpawnCounts) do
		if spawnCount < 1 then
			remainingTeams[team] = true
			return
		end

		livingTeams[team] = true
	end

	local livingTeamCount = 0
	local lastTeam = nil
	for team, isAlive in pairs(livingTeams) do
		livingTeamCount += 1
		lastTeam = team
	end

	WinService.sendMatchResultAndUpdateRatings(livingTeamCount, lastTeam, remainingTeams)
	
	Debounce = false
end

local function onCharacterAdded(character)
	WinService.scan()
	
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Changed:Connect(function()
		if humanoid.Health <= 0 then WinService.scan() end
	end)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(onCharacterAdded)
	
	if not player.Character then return end

	onCharacterAdded(player.Character)
end

Players.PlayerAdded:Connect(onPlayerAdded)

for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

CollectionService:GetInstanceAddedSignal("Spawn"):Connect(onSpawnTagAdded)
CollectionService:GetInstanceRemovedSignal("Spawn"):Connect(onSpawnTagRemoved)

for _, spawnpad in pairs(CollectionService:GetTagged("Spawn")) do
	onSpawnTagAdded(spawnpad)
end

return WinService