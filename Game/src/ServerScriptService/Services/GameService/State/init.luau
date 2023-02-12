--Author: n0pa

local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local PlayersService = game:GetService("Players")
local GameDataService = require(game.ServerScriptService.Services.GameDataService)
local RatingService = require(game.ServerScriptService.Services.RatingService)
local RatingProcessor = require(script.RatingProcessor)
local TimeManager = require(script.TimeManager)
local Results = require(script.Results)

local State = "Booting"
local EliminationTime = 3 * 60 --seconds

local TeamData = {}
local Spawns = {}
local AliveTeams = {}
local CountingTeams = {}
local DeadTeams = {}

local Connection

local module = {}

local function hasElements(tab)
	for _, _ in pairs(tab) do return true end
	
	return false
end

local function length(tab)
	local accumulator = 0
	for _, _ in pairs(tab) do accumulator += 1 end

	return accumulator
end

local function hasLivePlayers(playerList)
	for _, player in pairs(playerList) do
		if not player then warn("NO Player") end
		if not player.Character then warn("NO Player Character") end
		if player.Character.Parent and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then return true end
	end
		
	return false
end

local function isTeamDead(team)	
	print("GameService.State - isTeamDead", team, team:GetPlayers(), Spawns[team], DeadTeams[team], hasElements(Spawns[team]), hasLivePlayers(team:GetPlayers()), team:GetPlayers())
	if DeadTeams[team] then return true end
	
	if hasElements(Spawns[team]) or hasLivePlayers(team:GetPlayers()) then return false end
		
	return true
end

local function isTeamCounting(team)
	print("GameService.State - isTeamCounting", team, team:GetPlayers(), Spawns[team], CountingTeams[team])
	if CountingTeams[team] then return true end
	
	if hasLivePlayers(team:GetPlayers()) then return false end
	
	return true
end

local function setTeamState(team, state)
	print("GameService.State - setTeamState", team, state)
	if state == "Dead" then
		AliveTeams[team] = nil
		CountingTeams[team] = nil
		DeadTeams[team] = true
		print("GameService.State - setTeamState - Dead", AliveTeams[team], CountingTeams[team], DeadTeams[team], length(AliveTeams), State)
		
		if length(AliveTeams) == 1 and State ~= "Terminated" then module.TerminateGame() end
		--if State ~= "Terminated" then module.TerminateGame() end
		
	elseif state == "Counting" then
		AliveTeams[team] = nil
		CountingTeams[team] = true
		DeadTeams[team] = nil
		print("GameService.State - setTeamState - Counting", AliveTeams[team], CountingTeams[team], DeadTeams[team])
		
	elseif state == "Alive" then
		AliveTeams[team] = true
		CountingTeams[team] = nil
		DeadTeams[team] = nil
		print("GameService.State - setTeamState - Alive", AliveTeams[team], CountingTeams[team], DeadTeams[team], TeamData[team].eliminationTimer)
		
		TeamData[team].eliminationTimer = EliminationTime
	end
end

local function onHeartbeat(delta)
	for team, _ in pairs(CountingTeams) do
		local teamData = TeamData[team]
		teamData.eliminationTimer -= delta
		if teamData.eliminationTimer > 0 then continue end
		print("GameService.State - onHeartBeat", team, teamData.eliminationTimer)
		
		setTeamState(team, "Dead")
	end
end

local function onSpawnRemoved(spawnObject)
	local team = spawnObject.Team.Value
	print("GameService.State - onSpawnRemoved", spawnObject, team, Spawns[team])
	if not Spawns[team] then Spawns[team] = {} end
	
	Spawns[team][spawnObject] = nil

	if isTeamDead(team) then setTeamState(team, "Dead") end
end

local function onSpawnAdded(spawnObject)
	local team = spawnObject.Team.Value
	print("GameService.State - onSpawnAdded", spawnObject, team, Spawns[team])
	if not Spawns[team] then Spawns[team] = {} end

	Spawns[team][spawnObject] = true
end

local function onPlayerRemoved(player)
	local team = player.Team
	print("GameService.State - onPlayerRemoved", player, team, isTeamDead(team), isTeamCounting(team))
	if isTeamDead(team) then setTeamState(team, "Dead") end
	if isTeamCounting(team) then setTeamState(team, "Counting") end
	
	TimeManager.UpdateTotalTimeData(tostring(player.UserId))
end

local function onPlayerDeath(player)
	local team = player.Team
	print("GameService.State - onPlayerDeath", player, team, isTeamDead(team))

	if isTeamDead(team) then setTeamState(team, "Dead") end
	if isTeamCounting(team) then setTeamState(team, "Counting") end
end

local function onCharacterAdded(player)
	local humanoid = player.Character:WaitForChild("Humanoid")
	print("GameService.State - onCharacterAdded", player, humanoid)
	humanoid.Died:Connect(function() onPlayerDeath(player) end)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function() onCharacterAdded(player) end)
	
	while not player.Team do wait() end
	print("GameService.State - onPlayerAdded", player, player.Team)
	
	setTeamState(player.Team, "Alive")
	
	TimeManager.UpdateTotalTimeData(tostring(player.UserId))
end

local function connectTracking()
	Connection = RunService.Heartbeat:Connect(onHeartbeat)
	
	game.Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in ipairs(game.Players:GetPlayers()) do onPlayerAdded(player) end

	game.Players.PlayerRemoving:Connect(onPlayerRemoved)
end

local function disconnectTracking()
	Connection:Disconnect()
end

local function initializeTeamData(teamData)
	for _, v in pairs(teamData) do
		AliveTeams[v.Team] = true

		TeamData[v.Team] = {
			userIDs = v.UserIds;
			eliminationTimer = EliminationTime;
		}
	end
end

module.StartGame = function(teamData)	
	if length(teamData) <= 1 then return end
	
	warn("The game has been activated")
	State = "Active"
	
	initializeTeamData(teamData)
	
	TimeManager.ActivateTracking()
	connectTracking()
	
	if not RunService:IsStudio() then coroutine.wrap(function() GameDataService.SetKeyData("ActiveGames", game.PrivateServerId, DateTime.now().UnixTimestamp) end)() end
	
	warn(teamData)
	if length(teamData) <= 1 then module.TerminateGame() return end
end

module.TerminateGame = function()
	warn("The game has been terminated")
	State = "Terminated"
	
	TimeManager.TerminateTracking()
	disconnectTracking()
	
	--if not RunService:IsStudio() then coroutine.wrap(function()
	--	local startTime = GameDataService.RemoveKeyFromDataStore("ActiveGames", game.PrivateServerId)
	--	GameDataService.SetKeyFromDataStore("TerminatedGames", game.PrivateServerId, startTime)
	--end)() end
	
	local winningTeam = nil
	for team, _ in pairs(AliveTeams) do winningTeam = team break end
	if winningTeam == nil then warn("No Winning Team!") return end
	
	local winningTeamData = TeamData[winningTeam]
	local losingTeamDatas = {}
	for team, _ in pairs(DeadTeams) do losingTeamDatas[team] = TeamData[team] end
	--for team, _ in pairs(AliveTeams) do losingTeamDatas[team] = TeamData[team] end
	
	local TotalTimeData, DeathTimeData, GameTime = TimeManager.GetTimeData()
	local InputData = {["WinningTeam"] = winningTeamData; ["LosingTeams"] = losingTeamDatas;}
	local DataTable, ReturnTable = RatingProcessor.GetRatingDeltas(InputData, TotalTimeData)
	
	while #winningTeamData.userIDs == 0 do wait() end
	if not RunService:IsStudio() then 
		Results.SendWinMessage(winningTeam, ReturnTable)
		Results.SendMatchResult(winningTeam, DataTable, ReturnTable, DeathTimeData, GameTime)
		
		RatingProcessor.ApplyRatings(DataTable, ReturnTable)
	end
end

CollectionService:GetInstanceAddedSignal("Spawn"):Connect(onSpawnAdded)
CollectionService:GetInstanceRemovedSignal("Spawn"):Connect(onSpawnRemoved)

return module