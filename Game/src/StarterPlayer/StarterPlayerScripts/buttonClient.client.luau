local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedFirst:WaitForChild("ContextHint"))--  =  = game:GetService("ReplicatedFirst:WaitForChild("ContextHint"))--  = ")

local MouseData = require(ReplicatedFirst.MouseData)
local contextHint = require(ReplicatedFirst:WaitForChild("ContextHint"))--  = )

local Events = ReplicatedStorage:WaitForChild("Events")
local ButtonRemote = Events:WaitForChild("ButtonRemote")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local currentButton = nil
local buttons = {}

local function onButtonTagAdded(button)
	buttons[button] = true
end

local function onButtonTagRemoved(button)
	buttons[button] = nil
end

local function onEKey(_, InputState, _)
	if InputState == Enum.UserInputState.Begin and currentButton then
		ButtonRemote:FireServer(currentButton)
	end
end

local bound = false
local function Bind()
	if not bound then
		ContextActionService:BindAction("ButtonClient", onEKey, false, Enum.KeyCode.E)
		bound = true
	end
end

local function UnBind()
	if bound then
		ContextActionService:UnbindAction("ButtonClient")
		bound = false
	end
end

local function parseText(button)
	local text = {}
	local Type = button:FindFirstChild("Type")
	
	text[1] = "E"
	if Type.Value == "Toggle" then
		local Enabled = button:WaitForChild("Enabled")
			if Enabled.Value then
			local DisableText = button:WaitForChild("DisableText")
--			text[1] = "E"
			text[2] = DisableText.Value
		else
			local EnableText = button:WaitForChild("EnableText")
--			text[1] = "E"
			text[2] = EnableText.Value
		end
	elseif Type.Value == "Push" then
		local textValue = button:FindFirstChild("Text")
		if textValue then
--			text[1] = "E"
			text[2] = textValue.Value
		else
--			text[1] = "E"
			text[2] = "NO_BUTTON_TEXT_FOUND"
		end
	end
	return text
end

local function onHeartBeat(delta)
	local hitPart = MouseData.GetMouseData()
	local didFindAButton = buttons[hitPart] or false
	if didFindAButton then
		Bind()
		
		contextHint.AddHint("Button", parseText(currentButton or hitPart))
		if hitPart ~= currentButton then
			currentButton = hitPart
--			contextHint.AddHint("Button", parseText(currentButton))--Method testing to lazy to add text until I know it's working
		else
--			contextHint.AddHint("Button", parseText(currentButton))
			--Update text
		end
	elseif currentButton ~= nil then
		currentButton = nil
		contextHint.RemoveHint("Button")
		UnBind()
	end
end

CollectionService:GetInstanceAddedSignal("Button"):Connect(onButtonTagAdded)
CollectionService:GetInstanceRemovedSignal("Button"):Connect(onButtonTagRemoved)
for _, button in ipairs(CollectionService:GetTagged("Button")) do
	onButtonTagAdded(button)
end

RunService.Heartbeat:Connect(onHeartBeat)