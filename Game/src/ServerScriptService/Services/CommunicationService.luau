-- Author: Sheikh

local MessagingService = game:GetService("MessagingService")



-- Script for cross-server communication in an ordered fashion


local module = {}

module.MessageChannels = {
	["General"] = "GENERAL";
	["Moderation"] = "MODERATION";
}

module.BoundToCommunication = {}

module.CreateChannel = function(key, channel)
	module.MessageChannels[key] = channel
end

module.BindToCommunication = function(channel, name, callback)
	local success, connection = pcall(function()
		return MessagingService:SubscribeAsync(channel, function(message) callback(message.Data) end)
	end)
	
	if success then
		module.BoundToCommunication[name] = connection
		print("Successfully bound " .. name .. " to cross-server communication on " .. channel .. " channel.")
	else
		error("Unsuccessfully attempted to bind " .. name .. " to cross-server communication on " .. channel .. " channel: " .. connection)
	end
end

module.UnbindFromCommunication = function(name)
	if not module.BoundToCommunication[name] then print("Unsuccessfully attempted to unbind " .. name .. " from cross-server communication as no bound callbacks exist under specified name.") return end
	module.BoundToCommunication[name]:Disconnect()
	print("Successfully unbound " .. name .. " from cross-server communication!")
end

module.Communicate = function(channel, content)
	if not channel then print("Unsuccessfully published message as channel key does not exist (" .. channel .. ")") return end
	
	local success, result = pcall(function()
		MessagingService:PublishAsync(channel, content)
	end)
	if success then
		print("Successfully published message to " .. channel .. " channel via cross-server communication!")
	else
		error("Unsuccessfully attempted to publish message to " .. channel .. " via cross-server communication: " .. result)
	end
end

return module
