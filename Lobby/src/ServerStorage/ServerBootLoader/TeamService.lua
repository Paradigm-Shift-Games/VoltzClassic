local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RequestJoinRemote = Remotes:WaitForChild("RequestJoin")
local DoorService = require(script.Parent:WaitForChild("DoorService"))
--[[
	Too lazy to write the code but not lazy enough to write down what my tired self thought
	Step one take the remote request
	Step two check if the team given is none or x team
	if its none then set the team they where previously on by playerData[player].team to not include them anymore then set there team to none
	if it is x team then check the door status then change there team based on if its closed or not
	goodnight
	don't forget to use GetJoinData to get the data from the teleport!11
	on matchmaking thing make the countdown check each team if the door is closed if it is then check size of team if it 0 then open door
]]--

local acceptableTeams = {
	["red"] = true;
	["blue"] = true;
	["yellow"] = true;
	["orange"] = true;
	["green"] = true;
}

local currentTeamData = {
	playerData = {};
}

local Colors = {
	["red"] = BrickColor.Red();
	["blue"] = BrickColor.Blue();
	["yellow"] = BrickColor.new("New Yeller");
	["orange"] = BrickColor.new("Neon orange");
	["green"] = BrickColor.Green();
}

local TeamService = {}
TeamService.Enabled = true

local function cleanEmptyTeams()
	for _, team in pairs(Teams:GetTeams()) do
		if #team:GetPlayers() == 0 and team.Name ~= "No Team" then
			team:Destroy()
		end
	end
end
local function addPlayerToTeam(player, teamName)
	local team = Teams:FindFirstChild(teamName) or Instance.new("Team")
	if team.Parent == nil then
		--this is a new team
		team.Name = teamName
		team.TeamColor = Colors[teamName]
		team.Parent = Teams
	end
	player.Team = team
	cleanEmptyTeams()
end
local function onRequestJoin(player, teamName)
	if currentTeamData.playerData[player] == nil then currentTeamData.playerData[player] = {} end
	if teamName == "none" then
		local previousTeam = currentTeamData.playerData[player].currentTeam or "none"
		if previousTeam ~= "none" then
			if DoorService.isDoorOpen(previousTeam) then
				currentTeamData.playerData[player].currentTeam = "none"
				addPlayerToTeam(player, "No Team")
			else
				return
			end
		end
		currentTeamData.playerData[player].currentTeam = "none"
		addPlayerToTeam(player, "No Team")
	elseif acceptableTeams[teamName] then
		local isDoorOpen = DoorService.isDoorOpen(teamName)
		if isDoorOpen then
			currentTeamData.playerData[player].currentTeam = teamName
			addPlayerToTeam(player, teamName)
		end
	end
end
RequestJoinRemote.OnServerEvent:Connect(onRequestJoin)
game.Players.PlayerRemoving:Connect(cleanEmptyTeams)
return TeamService