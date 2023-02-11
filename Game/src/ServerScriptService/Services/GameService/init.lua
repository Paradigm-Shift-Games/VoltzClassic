local module = {}

local Spawn = require(script.Spawn) 
local Team = require(script.Team)
local State = require(script.State)
local Moderation = require(script.Moderation)

module.SpawnPlayer = Spawn.SpawnPlayer
module.GetTeamData = Team.GetTeamData

coroutine.wrap(function() 
	local teamData = module.GetTeamData()
	State.StartGame(teamData) 
end)()

return module
