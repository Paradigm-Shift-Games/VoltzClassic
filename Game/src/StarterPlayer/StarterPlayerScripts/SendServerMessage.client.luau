-- Author: n0pa

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")


local ServerMessageRemote = game.ReplicatedStorage.Events.ServerChat

local function sendChat(configTable)		
	StarterGui:SetCore("ChatMakeSystemMessage", configTable)
end

ServerMessageRemote.OnClientEvent:Connect(sendChat)