-- Author: n0pa

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerChatRemote = ReplicatedStorage.Events.ServerChat

local DefaultChatConfig = {
	["Color"] = Color3.fromRGB(255, 255, 243);
	["Font"] = Enum.Font.SourceSansBold;
	["TextSize"] = 18;
}

local ChatService = {}

function ChatService.SetDefaultConfig(color, font, textSize)
	local previousDefaultConfig = DefaultChatConfig
	
	DefaultChatConfig = {
		["Color"] = color or DefaultChatConfig["Color"];
		["Font"] = font or DefaultChatConfig["Font"];
		["TextSize"] = textSize or DefaultChatConfig["TextSize"];
	}
end

function ChatService.SendGlobalMessage(text, optionalConfigTable)
	local configTable = optionalConfigTable or DefaultChatConfig
	configTable["Text"] = text
	
	ServerChatRemote:FireAllClients(configTable)
end

function ChatService.SendMessage(player, text, optionalConfigTable)
	local configTable = optionalConfigTable or DefaultChatConfig
	configTable["Text"] = text

	ServerChatRemote:FireClient(player, configTable)
end

return ChatService
