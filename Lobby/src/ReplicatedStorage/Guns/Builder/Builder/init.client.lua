--Waits
script:WaitForChild("SelectionGui")
script:WaitForChild("Placer")

--Services
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

--Modules
local SelectionGui = require(script.SelectionGui)
local ContextHint = require(ReplicatedFirst.ContextHint)
local StructureUtil = require(game.ReplicatedStorage.StructureUtility)
local Placer = require(script.Placer)

--References
local tool = script.Parent
local player = game.Players.LocalPlayer
local character = player.Character
local camera = workspace.CurrentCamera
local upgradeEvent = game.ReplicatedStorage.Events.Upgrade
local actionEvent = game.ReplicatedStorage.Events.Action

--Variables
local mousePart, mousePos, mouseNormal, mouseModel
local action
local equipped

function UpdateMouse()
	local mouse = player:GetMouse()
	local ray = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
	ray = Ray.new(ray.Origin, ray.Direction * 1024)
	mousePart, mousePos, mouseNormal = workspace:FindPartOnRayWithIgnoreList(ray, {character, workspace:FindFirstChild("Effects")})
	mouseModel = StructureUtil.GetModel(mousePart)
end

function SelectionChanged(selected)
	Placer.DeSelect()
	if selected then Placer.Select(selected) end
end

function Upgrade(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin and mouseModel then
		upgradeEvent:FireServer(mouseModel)
	end
end

function SetAction(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then actionEvent:FireServer(actionName, true) return end
	if inputState == Enum.UserInputState.End then actionEvent:FireServer(actionName, false) return end
end

function UpdateHints()
	ContextHint.RemoveHint("Push")
	ContextHint.RemoveHint("Pull")
	ContextHint.RemoveHint("Destroy")
	ContextHint.RemoveHint("Upgrade")
	
	if Placer.Placing then return end
	
	if player:DistanceFromCharacter(mousePos) > 30 then return end
	
	if mousePart then
		if mousePart:IsA("Terrain") then
			ContextHint.AddHint("Pull", {"E", "Pull"})
		end
		
		if mousePart.Name == "RefillConsole" then
			ContextHint.AddHint("Push", {"L-Click", "Push"})
			ContextHint.AddHint("Pull", {"E", "Pull"})
		end
	end
	
	if mouseModel then
		if CollectionService:HasTag(mouseModel, "Crystal") then
			ContextHint.AddHint("Push", {"L-Click", "Push"})
			ContextHint.AddHint("Pull", {"E", "Pull"})	
			ContextHint.AddHint("Destroy", {"G", "Destroy"})
		end
		
		if CollectionService:HasTag(mouseModel, "Blueprint") and mouseModel:FindFirstChild("Team") and mouseModel.Team.Value == player.Team then
			ContextHint.AddHint("Push", {"L-Click", "Push"})
			ContextHint.AddHint("Pull", {"E", "Pull"})
			ContextHint.AddHint("Destroy", {"G", "Destroy"})
		end
		
		if CollectionService:HasTag(mouseModel, "Structure") and mouseModel:FindFirstChild("Team") and mouseModel.Team.Value == player.Team then
			ContextHint.AddHint("Destroy", {"G", "Destroy"})
		end
		
		
		
		if CollectionService:HasTag(mouseModel, "Structure") and mouseModel:FindFirstChild("UpgradeState") and mouseModel:FindFirstChild("MaxUpgrades") and mouseModel.UpgradeState.Value < mouseModel.MaxUpgrades.Value and not mouseModel:FindFirstChild("Upgrading") then
			ContextHint.AddHint("Upgrade", {"B", "Upgrade"})
		end
	end
end

function OnRender()
	UpdateMouse()
	UpdateHints()
	Placer.Update()
end

function OnEquipped()
	if equipped then return end
	
	equipped = true
	SelectionGui.Bind(SelectionChanged)
	ContextActionService:BindAction("Push", SetAction, false, Enum.UserInputType.MouseButton1)
	ContextActionService:BindAction("Pull", SetAction, false, Enum.KeyCode.E)
	ContextActionService:BindAction("Break", SetAction, false, Enum.KeyCode.G)
	ContextActionService:BindAction("Upgrade", Upgrade, false, Enum.KeyCode.B)
	RunService:BindToRenderStep("PortafabRender", 255, OnRender)
end

function OnUnequipped()
	if not equipped then return end
	
	equipped = false
	SelectionGui.Reset()
	SelectionGui.UnBind()
	actionEvent:FireServer("Push", false)
	actionEvent:FireServer("Pull", false)
	actionEvent:FireServer("Destroy", false)
	ContextHint.RemoveHint("Push")
	ContextHint.RemoveHint("Pull")
	ContextHint.RemoveHint("Destroy")
	ContextActionService:UnbindAction("Push")
	ContextActionService:UnbindAction("Pull")
	ContextActionService:UnbindAction("Break")
	RunService:UnbindFromRenderStep("PortafabRender")
end

tool.Equipped:Connect(OnEquipped)
tool.Unequipped:Connect(OnUnequipped)