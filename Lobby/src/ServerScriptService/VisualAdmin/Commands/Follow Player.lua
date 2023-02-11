local TeleportService = game:GetService("TeleportService")
local Players = game.Players
local GameDataService = require(game.ServerScriptService.Services.GameDataService)
local ChatMessage = game.ReplicatedStorage.Remotes.ChatMessage

local GameID = 4566800668

local function Command(player, arguments)
	if not arguments["Username or UserId"] then return "No target player specified!" end
	local user = arguments["Username or UserId"]
	
	if user:gmatch("%a")() then
		if not pcall(function() user = Players:GetUserIdFromNameAsync(user) end) then return "Invalid Username / UserId" end
	else
		if not pcall(function() Players:GetNameFromUserIdAsync(user) end) and not pcall(function() user = Players:GetUserIdFromNameAsync(user) end) then return "Invalid Username / UserId" end
	end
	if not user then return end
	
	local username = Players:GetNameFromUserIdAsync(user)
	
	local matchCode = GameDataService.GetKeyData("PlayerGames", user)
	if not matchCode then return "Player \"" .. username .. "\" has not joined a match yet!" end
	if matchCode == "" then return "Player \"" .. username .. "\" is not in a match!" end

	ChatMessage:FireClient(player, "[Server] Successfully found " .. username .. " in a match - teleporting to match...", Color3.fromRGB(255, 136, 0), Enum.Font.Gotham )

	TeleportService:TeleportToPrivateServer(GameID, matchCode, {player}, nil, {Mode = "Spectator"})
end

return Command
