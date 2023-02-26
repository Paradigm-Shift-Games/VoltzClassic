local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local currentStarter = StarterPlayer.StarterCharacter
local hotdogStarter = ReplicatedStorage.HotdogMan

local HotdogManService = {
	HotdogEnabled = false
}

function HotdogManService:Start()
	if self.HotdogEnabled then		
		currentStarter.Parent = ReplicatedStorage
		hotdogStarter.Name = "StarterCharacter"
		hotdogStarter.Parent = StarterPlayer
	end
end

return HotdogManService