-- Author: n0pa

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")




local ServerMessageRemote = ReplicatedStorage.Events.ServerChat

local function sendChat(configTable)		
	StarterGui:SetCore("ChatMakeSystemMessage", configTable)
end

ServerMessageRemote.OnClientEvent:Connect(sendChat)