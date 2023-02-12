-- Author: dead memes

local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

superfunkyhotdogmantime = false
local currentStarter = StarterPlayer.StarterCharacter
local hotdogStarter = ReplicatedStorage.HotdogMan

Players.PlayerAdded:Connect(function()
	if superfunkyhotdogmantime then
		print("It's superfunkyhotdogmantime!")
		
		currentStarter.Parent = ReplicatedStorage
		hotdogStarter.Name = "StarterCharacter"
		hotdogStarter.Parent = StarterPlayer
	end
end)