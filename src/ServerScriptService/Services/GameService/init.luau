local Team = require(script.Team)
local State = require(script.State)
local Moderation = require(script.Moderation)

local GameService = {}

local Spawn = require(script.Spawn) 

GameService.SpawnPlayer = Spawn.SpawnPlayer
GameService.GetTeamData = Team.GetTeamData

task.spawn(function() 
	local teamData = GameService.GetTeamData()
	State.StartGame(teamData) 
end)

return GameService
