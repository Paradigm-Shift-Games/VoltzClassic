--Author: 4812571, Styx

local CollectionService = game:GetService("CollectionService")
local Remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local ButtonRemote = Remotes:WaitForChild("Button")
local ButtonService = {}
local objectData = {}
local buttonData = {}
local buttonModes = {}
local buttonDebounce = 1.5

buttonModes.Push = function(player, button)
	buttonData[button].Func(player)
end

buttonModes.Toggle = function(player, button)
	local EnabledValue = button:FindFirstChild("Enabled")
	local Success = buttonData[button].Func(player, not EnabledValue.Value)
	if Success then EnabledValue.Value = not EnabledValue.Value end
end

buttonFire = function(player, button)
	local buttonData = buttonData
	if buttonData[button].lastTimePressed + buttonDebounce > tick() then return end
	if buttonData[button].Object and buttonData[button].Object.Team.Value ~= player.Team then return end

	buttonData[button].lastTimePressed = tick()
	buttonModes[buttonData[button].Type](player, button)
end

local function onServerEvent(player, button)
	if buttonData[button] then
		buttonFire(player, button)
	else
		warn(player.Name, "Attempt to press non registered button ", button.Name)
	end
end

ButtonService.Bind = function(object, button, func)
	CollectionService:AddTag(button, "Button")
	buttonData[button] = {
		Type = button.Type.Value;
		Func = func;
		lastTimePressed = 0;
		Object = object;
	}
end

ButtonService.UnBind = function(button)
	CollectionService:RemoveTag(button, "Button")
	buttonData[button] = nil
end

ButtonRemote.OnServerEvent:Connect(onServerEvent)
return ButtonService