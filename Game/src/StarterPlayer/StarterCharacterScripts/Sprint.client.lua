--Author: Accedo

local ContextActionService = game:GetService("ContextActionService")

local sprinting = false
local sprintMultiplier = 1.5

local player = game.Players.LocalPlayer
local humanoid = player.Character:WaitForChild("Humanoid")

function SprintPlayer(actionName, inputState, inputObject)
	if not sprinting and inputState == Enum.UserInputState.Begin and not _G.Jetpacking then
		sprinting = true
		humanoid.WalkSpeed = humanoid.WalkSpeed * sprintMultiplier
	end
	
	if sprinting and inputState == Enum.UserInputState.End then
		sprinting = false
		humanoid.WalkSpeed = humanoid.WalkSpeed / sprintMultiplier
	end
end

ContextActionService:BindAction("KeyPressedSprint", SprintPlayer, false, Enum.KeyCode.LeftShift)