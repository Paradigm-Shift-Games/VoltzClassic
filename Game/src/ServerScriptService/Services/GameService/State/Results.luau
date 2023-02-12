--Author: n0pa

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local DiscordService = require(game.ServerScriptService.Services.DiscordService)
local ChatService = require(game.ServerScriptService.Services.ChatService)

local module = {}

local function maxElement(tab)
	local max = -math.huge
	for _, v in pairs(tab) do
		if typeof(v) ~= "number" then continue end
		if max < v then max = v end
	end

	return (max == -math.huge and nil) or max
end

local function formatTime(totalMilliseconds)
	local days = totalMilliseconds/(1000*60*60*24)
	local hours = 24*(days % 1)
	local minutes = 60*(hours % 1)
	local seconds = 60*(minutes % 1)
	local milliseconds = 1000*(seconds % 1)

	local timeText = ""
	local units = {"d ", "h ", "m ", "s ", "ms"}
	for k, v in ipairs({days, hours, minutes, seconds, milliseconds}) do
		local flooredValue = math.floor(v)
		local unit = units[k]
		if flooredValue == 0 and unit ~= "ms" then continue end

		timeText ..= flooredValue..unit
	end

	return timeText
end

local function formatColor(color)
	--16^6 - 1 = 16711680, 16^4 - 1 = 65280, 16^2 - 1 = 255
	return 16711680*color.r + 65280*color.g + 255*color.b
end

local function addPlayerResult(stringUserID, ratingStringUserIDs, ratingDelta, deathTimeData, sign)
	local name = Players:GetNameFromUserIdAsync(tonumber(stringUserID))
	local rating = math.floor(ratingStringUserIDs[stringUserID]) or "unavailable"
	local playerTime = deathTimeData[stringUserID] or 0

	return "\n"..name.." [ "..formatTime(playerTime).." ]: "..rating..sign..math.floor(ratingDelta)
end

module.SendWinMessage = function(winningTeam, ratingDeltas)	
	local color = winningTeam.TeamColor.Color--Color3.fromRGB(9, 137, 207)
	local font = Enum.Font.Sarpanch
	local textSize = 25
	
	ChatService.SetDefaultConfig(color, font, textSize);

	ChatService.SendGlobalMessage("Congratulations Team: "..winningTeam.Name);
	
	for userID, ratingDelta in pairs(ratingDeltas["WinningRatingDeltas"]) do
		local name = Players:GetNameFromUserIdAsync(userID)
		local ratingDelta = ratingDeltas["WinningRatingDeltas"][userID]
		
		ChatService.SendGlobalMessage("Well done, "..name.."! Rating earned: "..math.floor(ratingDelta).."\n");
	end
end

module.SendMatchResult = function(winningTeam, dataTable, returnTable, deathTimeData, totalTime)
	local newMessage = DiscordService.Content.New()
	local newEmbed = DiscordService.Embed.New()
	newEmbed:SetTitle("Match Results")

	local text = ":trophy: **"..winningTeam.Name.."** :trophy:"
	local ratingWinningStringUserIDs = dataTable["WinningRatings"]
	for stringUserID, ratingDelta in pairs(returnTable["WinningRatingDeltas"]) do
		text ..= addPlayerResult(stringUserID, ratingWinningStringUserIDs, ratingDelta, deathTimeData, " + ")
	end

	local ratingLosingTeams = dataTable["LosingRatings"]
	for team, stringUserIDs in pairs(returnTable["LosingRatingDeltas"]) do
		text ..= "\n\n**"..team.Name.."**"
		
		local ratingLosingStringUserIDs = ratingLosingTeams[team]
		for stringUserID, ratingDelta in pairs(stringUserIDs) do
			text ..= addPlayerResult(stringUserID, ratingLosingStringUserIDs, ratingDelta, deathTimeData, " - ")
		end
	end

	text ..= "\n\n**Match Length**\n"..formatTime(totalTime)

	newEmbed:SetDescription(text)
	newEmbed:SetColor(formatColor(winningTeam.TeamColor))
	newMessage:AddEmbed(newEmbed)

	DiscordService.SendContent("winHook", newMessage)
end

return module
