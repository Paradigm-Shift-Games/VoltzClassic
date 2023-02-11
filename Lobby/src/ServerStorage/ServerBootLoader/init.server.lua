local matchMakingService = require(script:WaitForChild("MatchMakingService"))
local InteractionService = require(script:WaitForChild("InteractionService"))
local DoorService = require(script:WaitForChild("DoorService"))
local BackpackService = require(script:WaitForChild("BackpackService"))
local RatingService = require(game.ServerScriptService.Services.RatingService)
local teamNames = {
	"Red";
	"Green";
	"Orange";
	"Blue";
	"Yellow";
}
for _, teamName in ipairs(teamNames) do
	DoorService.OpenDoor(teamName)
end