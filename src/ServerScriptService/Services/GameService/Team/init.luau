-- Author: 4812571

local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ServerScriptService = game:GetService("ServerScriptService")

local StarterIsland = require(ServerScriptService.ServerBootLoader.Map.StarterIsland)

local Team = {}
local teamData = {}
local loaded = false
local matchData

local StudioColor = BrickColor.random()

local function DumpData()
	print("TeleportData:Dump():\n")
	for teamName, data in pairs(teamData) do
		print(teamName..":")
		for _, v in pairs(data.UserIds) do print("\t"..v, Players:GetPlayerByUserId(v)) end
	end
end

local function BuildTeams()
	print("Building Teams!")
	for teamName, data in pairs(matchData) do		
		-- Team Object
		local newTeam = Instance.new("Team")
		newTeam.Name = teamName
		newTeam.AutoAssignable = false
		newTeam.TeamColor = BrickColor.new(Color3.new(data.teamColor.R, data.teamColor.G, data.teamColor.B))
		newTeam.Parent = Teams
		
		-- Data Formatting
		print("Creating Team Entry", data.teamColor, data.pos)
		teamData[data.pos] = {}
		teamData[data.pos].Team = newTeam
		teamData[data.pos].UserIds = data.players
		
		-- Islands
		StarterIsland.AssignIsland(data.pos, newTeam)
	end
	loaded = true
end

-- Added by sheikh - testing for admins to spectate matches with FreeCam
local function Freecam(player)
	local playerGui = player:WaitForChild("PlayerGui")
	local spectatorScript = script.Spectator:Clone()
	
	spectatorScript.Parent = playerGui
	loaded = true
end

local function AssignTeam(player)
	print("Finding team for", player)
	for teamName, data in pairs(teamData) do
		if table.find(data.UserIds, player.UserId) then
			print("\t".."Found Team")
			player.Team = data.Team
			return
		end
	end
	
	DumpData()
	error("No team found for "..player.Name.." UserID: "..player.UserId)
end

local function OnPlayerAdded(player)
	local teleportData = player:GetJoinData().TeleportData
	if teleportData and teleportData.Mode == "Spectator" then
		task.spawn(function()
			Freecam(player)
		end)
		return 
	end
	if matchData == nil then
		matchData = teleportData
		BuildTeams()
	end
	
	while not loaded do wait() end
	if RunService:IsStudio() then
		table.insert(teamData[1].UserIds, player.UserId)
	end
	
	AssignTeam(player)
end

if RunService:IsStudio() then
	matchData = {
		["Studio"] = {
			teamColor = {R = StudioColor.r, G = StudioColor.g, B = StudioColor.b};
			players = {};
			pos = 1;
		}
	}

	task.spawn(BuildTeams)
end
	
function Team.GetTeamData()
	while not loaded do wait() end
	return teamData
end

task.spawn(function()
	for _, player in ipairs(Players:GetPlayers()) do
		OnPlayerAdded(player)
	end
end)

Players.PlayerAdded:Connect(OnPlayerAdded)

return Team