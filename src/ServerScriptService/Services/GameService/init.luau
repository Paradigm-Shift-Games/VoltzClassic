local Team = require(script.Team)
local State = require(script.State)

local GameService = {}

function GameService:Start()
	-- I find the usage of spawn here a bit odd, but I guess it's fine.
	-- Services are generally already running in their own threads, so I'm not sure why we need to spawn another one.
	-- ^ Note, this is not true for this game, at least yet.
	task.spawn(function() 
		local teamData = Team.GetTeamData()
		State.StartGame(teamData)
	end)
end

return GameService