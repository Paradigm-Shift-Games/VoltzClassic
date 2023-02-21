-- Author: 4812571, Styx

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StructureUtil = require(ReplicatedStorage.StructureUtility)
local CleanupService = require(game:GetService("ServerScriptService"):WaitForChild("Services"):WaitForChild("CleanupService"))

local Events = ReplicatedStorage:WaitForChild("Events")
local ButtonRemote = Events:WaitForChild("ButtonRemote")
local ButtonService = {}
local objectData = {}
local buttonData = {}
local buttonModes = {}
local buttonDebounce = 0.5

function buttonModes.Push(player, button)
	buttonData[button].Func(player)
end

function buttonModes.Toggle(player, button)
	buttonData[button].Enabled = not buttonData[button].Enabled
	buttonData[button].Func(player, buttonData[button].Enabled)
	local EnabledValue = button:FindFirstChild("Enabled")
	if EnabledValue then
		EnabledValue.Value = buttonData[button].Enabled
	end
end

buttonFire = function(player, button)
	if buttonData[button].lastTimePressed + buttonDebounce <= tick() then
		buttonData[button].lastTimePressed = tick()
		buttonModes[buttonData[button].Type](player, button)
	end
end

local function onServerEvent(player, button)
	if buttonData[button] then
		buttonFire(player, button)
	else
		warn(player.Name, "Attempt to press non registered button ", button.Name)
	end
end
--[[
Binded function will be called with
	Player : player, Button : BasePart
]]
function ButtonService.Clean(object)
	for button, _ in pairs(objectData[object]) do
		ButtonService.UnBind(button)
	end
	objectData[object] = nil
end

function ButtonService.Bind(object, button, func)
	if not objectData[object] then objectData[object] = {} end
	objectData[object][button] = true
	CleanupService.Reserve(object, "Buttons")
	CollectionService:AddTag(button, "Button")
	buttonData[button] = {
		Type = button.Type.Value;
		Func = func;
		lastTimePressed = 0;
		Team = StructureUtil.GetModel(button).Team.Value;
		Object = object;
	}
	if button.Type.Value == "Toggle" then
		buttonData[button].Enabled = false
	end
end

function ButtonService.UnBind(button)
	CollectionService:RemoveTag(button, "Button")
	buttonData[button] = nil
end

CleanupService.Bind("Buttons", ButtonService.Clean)
ButtonRemote.OnServerEvent:Connect(onServerEvent)
return ButtonService