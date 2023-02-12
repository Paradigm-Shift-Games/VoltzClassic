-- Author: Accedo

local ContextActionService = game:GetService("ContextActionService")


local ReplicatedStorage = game.ReplicatedStorage
local FlashlightRemote = ReplicatedStorage.Events.Flashlight
local enabled = false

function ToggleFlashlight(actionName, inputState, inputObject)
	if enabled and inputState == Enum.UserInputState.Begin then
		enabled = false
		FlashlightRemote:FireServer(enabled)
	else
		if inputState == Enum.UserInputState.Begin then
			enabled = true
			FlashlightRemote:FireServer(enabled)
		end
	end
end

ContextActionService:BindAction("KeyPressedFlashlight", ToggleFlashlight, false, Enum.KeyCode.F)