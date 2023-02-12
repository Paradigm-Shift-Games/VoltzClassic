local messagingService = game:GetService("MessagingService")
local TeleportService = game:GetService("TeleportService")
local tweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local DoorService = require(script.Parent:WaitForChild("DoorService"))
local TeamService = require(script.Parent:WaitForChild("TeamService"))
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

local exlcudedTeams = {
	["No Team"] = true;
}

local teamNames = {
	"Red";
	"Green";
	"Orange";
	"Blue";
	"Yellow";
}

local teamPos = {
	["Blue"] = 1;
	["Red"] = 2;
	["Green"] = 3;
	["Yellow"] = 4;
	["Orange"] = 5;
}

local lobbyFolder = workspace:WaitForChild("Lobby")
local currentTimer = 0
local maxTimer = 30
local timeLabels = {}
local count = 0

local function smartPause()
	if count > 5000 then
		wait()
		count = 0
	else
		count = count + 1
	end
end

for _, object in ipairs(workspace:GetDescendants()) do
	if object.Name == "timeLabel" then
		table.insert(timeLabels, object)
	end
	
	smartPause()
end

local MatchMakingService = {}
MatchMakingService.Enabled = true

local function openEmptyTeamDoors()
	for _, teamName in ipairs(teamNames) do
		if Teams:FindFirstChild(teamName) == nil and DoorService.isDoorOpen(teamName) == false then
			DoorService.OpenDoor(teamName)
		end
	end
end

local function getTotalTeams()
	return #Teams:GetChildren()-1
end

local function MeetsLaunchRequirements()
	if maxTimer <= currentTimer and getTotalTeams() > 0  then
		return true
	end
	
	return false
end

local function UpdateScreens()
	local timeLeft = maxTimer-currentTimer
	local Minutes = math.floor(timeLeft/60)
	local seconds = math.ceil(timeLeft%60)
	
	if seconds < 10 then
		seconds = "0"..tostring(seconds)
	end
	
	local text = tostring(Minutes)..":"..tostring(seconds)
	for _, label in ipairs(timeLabels) do
		label.Text = text
	end
end

local launching = false
local function onHeartBeat(delta)
	if MeetsLaunchRequirements() and MatchMakingService.Enabled and not launching and not RunService:IsStudio() then
		--Launch the players
		launching = true
		local reservedServer = TeleportService:ReserveServer(4566800668)
		local teleportData = {}
		local players = {}
		
		for _, team in pairs(Teams:GetChildren()) do
			if exlcudedTeams[team.Name] then continue end
			
			local color = team.TeamColor.Color
			teleportData[team.Name] = {
				players = {};
				teamColor = {R = color.R; G = color.G; B = color.B;};
				pos = teamPos[team.Name];
			}
			
			for _, player in pairs(team:GetPlayers()) do
				table.insert(teleportData[team.Name].players, player.UserId)
				table.insert(players, player)
			end
		end
		
		TeleportService:TeleportToPrivateServer(4566800668, reservedServer, players, nil, teleportData)
		
		while #players > 0 do
			wait()
			for i, v in ipairs(players) do
				if v == nil or v.Parent == nil then
					table.remove(players, i)
				end
			end
		end
		
		launching = false
		
	elseif MatchMakingService.Enabled and getTotalTeams() > 0 then
		currentTimer = math.min(currentTimer + delta, maxTimer)
	else
		currentTimer = 0
	end
	
	UpdateScreens()
	openEmptyTeamDoors()
end

if RunService:IsStudio() then
	warn("MatchMakingService will not be able to teleport you in Studio! (It will just error so I added a debounce)")
end

RunService.Heartbeat:Connect(onHeartBeat)

return MatchMakingService