--Author: n0pa

local ServerChatRemote = game.ReplicatedStorage.Events.ServerChat

local DefaultChatConfig = {
	["Color"] = Color3.fromRGB(255, 255, 243);
	["Font"] = Enum.Font.SourceSansBold;
	["TextSize"] = 18;
}

local module = {}

module.SetDefaultConfig = function(color, font, textSize)
	local previousDefaultConfig = DefaultChatConfig
	
	DefaultChatConfig = {
		["Color"] = color or DefaultChatConfig["Color"];
		["Font"] = font or DefaultChatConfig["Font"];
		["TextSize"] = textSize or DefaultChatConfig["TextSize"];
	}
end

module.SendGlobalMessage = function(text, optionalConfigTable)
	local configTable = optionalConfigTable or DefaultChatConfig
	configTable["Text"] = text
	
	ServerChatRemote:FireAllClients(configTable)
end

module.SendMessage = function(player, text, optionalConfigTable)
	local configTable = optionalConfigTable or DefaultChatConfig
	configTable["Text"] = text

	ServerChatRemote:FireClient(player, configTable)
end

return module
