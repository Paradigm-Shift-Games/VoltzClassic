-- For banned players
local GameDataService = require(game.ServerScriptService.Services.GameDataService)

local module = {}

local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}

module.IsPlayerBanned = function(playerID)
	local unbanInstant = GameDataService.GetKeyData("BannedPlayers", playerID) or 0
	return tick() - unbanInstant < 0, unbanInstant
end

local function formatDate(seconds)
	local date = os.date("*t", seconds)
	
	return date.day .. " " .. months[date.month] .. " " .. date.year
end

function onPlayerAdded(player)
	local banned, instant = module.IsPlayerBanned(player.UserId)
	print("Checking if player " .. player.Name .. " is banned...")
	if banned then
		warn("Kicked " .. player.Name .. " because they are banned!")
		player:Kick("You are banned until " .. formatDate(instant))
	end
end

game.Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(game.Players:GetPlayers()) do onPlayerAdded(player) end

return module
