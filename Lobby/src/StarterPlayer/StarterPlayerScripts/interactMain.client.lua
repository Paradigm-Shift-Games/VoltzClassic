local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")--I'll probably rewrite this garbage Later
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local foundButton
local contextHint = require(ReplicatedFirst:WaitForChild("ContextHint"))
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local lobbyFolder = workspace:WaitForChild("Lobby")
local pods = lobbyFolder:WaitForChild("Pods")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UseButtonRemote = Remotes:WaitForChild("UseButton")
mouse.TargetFilter = pods

local teamNames = {
	"blue";
	"yellow";
	"red";
	"orange";
	"green";
}
local buttons = {}

for _, teamName in ipairs(teamNames) do
	local door = lobbyFolder:FindFirstChild(teamName.."Door")
	local button = door:WaitForChild("Button")
	buttons[teamName] = button
end
print("Got all buttons!")
local function onRenderStepped(delta)
	local currentButton = mouse.Target
	if currentButton ~= nil and currentButton.Name == "Button" then
		local isDoorButton = false
		for teamName, doorButton in pairs(buttons) do
			if doorButton == currentButton then
				isDoorButton = true
				break
			end
		end
		if isDoorButton then
			local text = "Close Door"--Will be done later
			contextHint.AddHint("Button", {"E", text})
			foundButton = currentButton;
			return
		end
	end
	foundButton = nil
	contextHint.RemoveHint("Button")
end
local function onE(_, InputState, InputObject)
	if InputState == Enum.UserInputState.Begin and foundButton ~= nil then
		UseButtonRemote:FireServer(foundButton)
	end
end
ContextActionService:BindAction("interaction", onE, false, Enum.KeyCode.E)
RunService:BindToRenderStep("interaction", 200, onRenderStepped)