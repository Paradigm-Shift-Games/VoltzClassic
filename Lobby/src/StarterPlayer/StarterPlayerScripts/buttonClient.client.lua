local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local contextHint = require(game.ReplicatedFirst:WaitForChild("ContextHint"))
local MouseData = require(game.ReplicatedFirst:WaitForChild("MouseData"))
local Remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local ButtonRemote = Remotes:WaitForChild("Button")
local LocalPlayer = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local currentButton = nil

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
			text[2] = DisableText.Value
		else
			local EnableText = button:WaitForChild("EnableText")
			text[2] = EnableText.Value
		end
	elseif Type.Value == "Push" then
		local textValue = button:FindFirstChild("Text")
		if textValue then
			text[2] = textValue.Value
		else
			text[2] = "NO_BUTTON_TEXT_FOUND"
		end
	end
	return text
end

local function onHeartBeat(delta)
	local hitPart = MouseData.GetMouseData()
	local didFindAButton = CollectionService:HasTag(hitPart, "Button")
	if didFindAButton then
		Bind()
		
		contextHint.AddHint("Button", parseText(currentButton or hitPart))
		if hitPart ~= currentButton then
			currentButton = hitPart
			contextHint.AddHint("Button", parseText(currentButton))--Method testing too lazy to add text until I know it's working
		else
			contextHint.AddHint("Button", parseText(currentButton))
		end
	elseif currentButton ~= nil then
		currentButton = nil
		contextHint.RemoveHint("Button")
		UnBind()
	end
end

RunService.Heartbeat:Connect(onHeartBeat)