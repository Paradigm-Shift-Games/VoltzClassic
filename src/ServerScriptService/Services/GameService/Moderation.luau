local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local CommunicationService = require(ServerScriptService.Services.CommunicationService)

local function HandleCommands(commandString)
	local arguments = commandString:split(":")
	local command = table.remove(arguments, 1):lower()
	
	if command == "kick" then
		local userId = arguments[1]
		if not userId then return "No user ID provided with kick command!" end
		local player = Players:GetPlayerByUserId(userId)
		if player then player:Kick("You have been banned.") end
	end
end

local module = {}

module.ListenForEvents = function()
	CommunicationService.BindToCommunication(CommunicationService.MessageChannels.Moderation, "CommandHandler", HandleCommands)
end

module.ListenForEvents()

return module
