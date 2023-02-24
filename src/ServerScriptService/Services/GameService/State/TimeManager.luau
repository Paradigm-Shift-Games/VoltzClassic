-- Author: n0pa

local Players = game:GetService("Players")

local DeathTimeData = {}
local TotalTimeData = {}
local GameDate = DateTime.now()
local GameTime = 0

local TimeManager = {}

local function onPlayerDeath(player)
	print("GameService.State.TimeManager - onPlayerDeath", player, player.UserId)
	local stringUserID = tostring(player.UserId)
	TimeManager.UpdateDeathTimeData(stringUserID)
end

local function onCharacterAdded(player)
	print("GameService.State.TimeManager - onCharacterAdded", player)
	local humanoid = player.Character:WaitForChild("Humanoid")
	humanoid.Died:Connect(function() onPlayerDeath(player) end)
end

local function onPlayerAdded(player)
	print("GameService.State.TimeManager - onPlayerAdded", player)
	player.CharacterAdded:Connect(function() onCharacterAdded(player) end)
end

local function connectTracking()
	print("GameService.State.TimeManager - connectTracking")
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do onPlayerAdded(player) end
end

local function timeDifferenceMillis(dateTime1, dateTime2)	
	print("GameService.State.TimeManager - timeDifferenceMillis", dateTime1.UnixTimestampMillis, dateTime2.UnixTimestampMillis)
	return dateTime1.UnixTimestampMillis - dateTime2.UnixTimestampMillis
end

function TimeManager.UpdateTotalTimeData(stringUserID)
	local timeNow = DateTime.now()

	if not TotalTimeData[stringUserID] then
		TotalTimeData[stringUserID] = {
			["TotalTime"] = math.max(0, timeDifferenceMillis(timeNow, GameDate));
			["DateTime"] = nil;
		}
		warn(TotalTimeData)
	end

	local dateTime = TotalTimeData[stringUserID]["DateTime"]
	if not dateTime then TotalTimeData[stringUserID]["DateTime"] = timeNow return end

	TotalTimeData[stringUserID]["TotalTime"] += timeDifferenceMillis(timeNow, dateTime)
	TotalTimeData[stringUserID]["DateTime"] = nil
	warn(TotalTimeData)
	
	print("GameService.State.TimeManager - UpdateTotalTimeData", timeNow, GameDate, TotalTimeData[stringUserID])
end

function TimeManager.UpdateDeathTimeData(stringUserID, optionalTime)
	DeathTimeData[stringUserID] = optionalTime or timeDifferenceMillis(DateTime.now(), GameDate)
	print("GameService.State.TimeManager - UpdateDeathTimeData", optionalTime, DeathTimeData[stringUserID])
end

function TimeManager.ActivateTracking()
	GameDate = DateTime.now()
	print("GameService.State.TimeManager - ActivateTracking", GameDate, GameTime)
	
	connectTracking()
	for _, player in Players:GetPlayers() do TimeManager.UpdateTotalTimeData(tostring(player.UserId)) end
	
	DeathTimeData = {}
	TotalTimeData = {}
	print("GameService.State.TimeManager - ActivateTracking", TotalTimeData, DeathTimeData)
end

function TimeManager.TerminateTracking()
	GameTime = timeDifferenceMillis(DateTime.now(), GameDate)
	print("GameService.State.TimeManager - TerminateTracking", GameDate, GameTime)
	for _, player in Players:GetPlayers() do
		local stringUserID = tostring(player.UserId)
		TimeManager.UpdateTotalTimeData(stringUserID)
		TimeManager.UpdateDeathTimeData(stringUserID, GameTime)
	end
	
	print("GameService.State.TimeManager - TerminateTracking", TotalTimeData, DeathTimeData)
end

function TimeManager.GetTimeData()
	print("GameService.State.TimeManager - GetTimeData", TotalTimeData, DeathTimeData, GameTime)
	return TotalTimeData, DeathTimeData, GameTime
end

return TimeManager
