local replicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local ContextHint = require(game.ReplicatedFirst.ContextHint)

--[[ Ui Variables ]]--
local buildingUi = script:WaitForChild("buildingUi")
local frames = {
	["1"] = buildingUi:WaitForChild("zMenu");
	["2"] = buildingUi:WaitForChild("xMenu");
	["3"] = buildingUi:WaitForChild("cMenu");
	["4"] = buildingUi:WaitForChild("vMenu");
}
--[[ ]]--
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local selectionRoot = replicatedStorage:WaitForChild("selectionItems")
local selectedCategory = selectionRoot
local selectedObjectValue = nil
local connected = nil
local keyCodeMap = {
	[Enum.KeyCode.Z] = "1";
	[Enum.KeyCode.X] = "2";
	[Enum.KeyCode.C] = "3";
	[Enum.KeyCode.V] = "4";
}

local GuiScript = {}
GuiScript.Selected = nil

local function updateUiData()
	for name, frame in pairs(frames) do
		local data = selectedCategory:FindFirstChild(name)
		local infoName, infoCost = "", ""
		if data then
			if data:IsA("ObjectValue") then
				infoName = data.Value.Name
			else
				infoName = data.Value
			end
		end
		--I'm not doing images just yet as we have none nor do we have a storage for it.
		if infoName == "" then
			frame.Visible = false
		else
			frame.Visible = true
		end
		frame.textLabel.Text = infoCost.."    "..infoName--This will have to be split later.
	end
end

GuiScript.Deselect = function()
	ContextHint.RemoveHint("Cancel")
	GuiScript.Selected = nil
	connected(nil)
end

GuiScript.Select = function(keyCode)
	if keyCode == Enum.KeyCode.Q and selectedCategory ~= selectionRoot then
		selectedCategory = selectedCategory.Parent
	elseif keyCode == Enum.KeyCode.E then
		GuiScript.Deselect()
	elseif keyCodeMap[keyCode] then
		local selected = selectedCategory:FindFirstChild(keyCodeMap[keyCode])
		if selected then
			if selected:IsA("ObjectValue") then
				GuiScript.Selected = selected.Value
				connected(GuiScript.Selected)
			else
				selectedCategory = selected
			end
		end
	end
	updateUiData()
	return
end

local function onKeyPress(_, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		GuiScript.Select(inputObject.KeyCode)
	end
end
GuiScript.Reset = function()
	GuiScript.Deselect()
	selectedCategory = selectionRoot
	updateUiData()
end
GuiScript.Bind = function(ConnectedFunction)
	connected = ConnectedFunction
	updateUiData()
	buildingUi.Parent = playerGui
	for keyCode, _ in pairs(keyCodeMap) do
		ContextActionService:BindAction("Selection"..tostring(keyCode), onKeyPress, false, keyCode)
	end
	ContextActionService:BindAction("SelectionQ", onKeyPress, false, Enum.KeyCode.Q)
end
GuiScript.UnBind = function()
	buildingUi.Parent = script
	for keyCode, _ in pairs(keyCodeMap) do
		ContextActionService:UnbindAction("Selection"..tostring(keyCode))
	end
	ContextActionService:UnbindAction("SelectionQ")
end

return GuiScript