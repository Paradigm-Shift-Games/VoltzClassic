-- Author: dead memes

superfunkyhotdogmantime = false
local currentStarter = game.StarterPlayer.StarterCharacter
local hotdogStarter = game.ReplicatedStorage.HotdogMan

game.Players.PlayerAdded:Connect(function()
	if superfunkyhotdogmantime then
		print("It's superfunkyhotdogmantime!")
		
		currentStarter.Parent = game.ReplicatedStorage
		hotdogStarter.Name = "StarterCharacter"
		hotdogStarter.Parent = game.StarterPlayer
	end
end)