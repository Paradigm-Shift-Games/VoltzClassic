--Author: 4812571

local RunService = game:GetService("RunService")
local ModerationManager = require(script.Moderation)
local DoorManager = require(script.Doors)
local LaunchManager = require(script.Launch)
local PodManager = require(script.Pods)
local TimerManager = require(script.Timers)
local GameDataService = require(game.ServerScriptService.Services.GameDataService)
local ButtonService = require(game.ServerScriptService.Services.ButtonService)
local RatingSerice = require(game.ServerScriptService.Services.RatingService)
local BackpackService = require(game.ServerScriptService.Services.BackpackService)
local TeamRemote = game.ReplicatedStorage.Remotes.RequestJoin
local Teams = game.Teams
local NeutralTeam = Teams["No Team"]

require(game.ServerScriptService.Services.TickManager).Activate()
require(game.ServerScriptService.Services.CleanupService)
require(game.ReplicatedStorage.Stats.Structure)
require(game.ReplicatedStorage.Stats.Weapon)
workspace:WaitForChild("Extras").Parent = game.ReplicatedStorage

local timerEnabled = false
local launchTime = 45
local timerStartTime
TimerManager.SetTimers(launchTime)

local function onPlayerAdded(player) --Set to the rejection of rejoining the match when it exists
	--coroutine.wrap(function() GameDataService.SetKeyData("PlayerGames", player.UserId, "") end)()
end

local function SetTeam(player, team)
	local previousTeam = player.Team
	player.Team = team
	if previousTeam ~= NeutralTeam and #previousTeam:GetPlayers() == 0 then delay(2, function() DoorManager.OpenDoor(previousTeam) end) end
end

local function OnTeamRequest(player, team)
	if team == NeutralTeam then SetTeam(player, team) return end
	if DoorManager.IsDoorClosed(team) then player:LoadCharacter() return end
	SetTeam(player, team)
end

local function Update()
	--Debounce
	if LaunchManager.IsLaunching() then return end
	
	--Count Occupied Teams
	local teamsOccupied = 0
	for _, v in pairs(Teams:GetTeams()) do
		if v == NeutralTeam then continue end
		if #v:GetPlayers() > 0 then teamsOccupied += 1 end
	end
	
	--Match Start/Stop
	if timerEnabled then
		if teamsOccupied < 1 then
			timerEnabled = false
			timerStartTime = nil
			TimerManager.SetTimers(launchTime)
		end
	else
		if teamsOccupied >= 1 then
			timerEnabled = true
			timerStartTime = tick()
		end
	end
	
	--Timing
	if not timerEnabled then return end
	local timeTillLaunch = (timerStartTime + launchTime) - tick()
	
	--Update Timers
	TimerManager.SetTimers(timeTillLaunch)
	
	--Launch
	if timeTillLaunch <= 0 then LaunchManager.Launch() end
end

--Timer Initialization
for _, Display in pairs(workspace:WaitForChild("Lobby"):WaitForChild("Displays"):GetChildren()) do
	TimerManager.RegisterDisplay(tonumber(Display.Name), Display)
end

--Door Initialization
for i = 1, 5 do
	local pod = workspace.Lobby.Pods[tostring(i)]
	local function toBind(player, isEnabled)
		if player.Team ~= pod.Team.Value then return end
		if isEnabled then DoorManager.CloseDoor(i) else DoorManager.OpenDoor(i) end
		return false
	end
	ButtonService.Bind(pod, pod.Door.Button, toBind)
	DoorManager.OpenDoor(i)
end

PodManager.InitializePods()

TeamRemote.OnServerEvent:Connect(OnTeamRequest)

RunService.Heartbeat:Connect(Update)

game.Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(game.Players:GetPlayers()) do onPlayerAdded(player) end