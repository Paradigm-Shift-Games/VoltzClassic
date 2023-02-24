local Team = require(script.Team)
local State = require(script.State)

local GameService = {}

task.spawn(function() 
	local teamData = Team.GetTeamData()
	State.StartGame(teamData)
end)

return GameService