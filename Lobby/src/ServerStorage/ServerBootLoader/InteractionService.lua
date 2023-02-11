local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UseButtonRemote = Remotes:WaitForChild("UseButton")

local InteractionService = {}

InteractionService.UseButton = function(Player, Button)
	local buttonFunctionality = Button:FindFirstChild("buttonMain")
	if buttonFunctionality ~= nil then
		require(buttonFunctionality)(Player)
	end
end
UseButtonRemote.OnServerEvent:Connect(InteractionService.UseButton)

return InteractionService