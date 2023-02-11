--n0pa

--[[Work In Progress]]--

local selectedModel
local selectedAssembly
local RunService = game:GetService("RunService")

camera = workspace.CurrentCamera
script:WaitForChild("Positioner")

local BuildRemote = game.ReplicatedStorage.Events.Builder
local ContextActionService = game:GetService("ContextActionService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local BuildingConstraints = require(game.ReplicatedStorage.BuildingConstraints)
local StructureUtil = require(game.ReplicatedStorage.StructureUtility)
local Positioner = require(script.Positioner)
local ContextHint = require(game.ReplicatedFirst.ContextHint)
local SelectionGui = require(script.Parent.SelectionGui)
local scrollBound = false
local wire
local buildType
local part, pos, normal
local maxSnaps
local snapState
local canPlace
local hidden

local Placer = {}

Placer.Placing = false

local function GetMouse()
	buildType = nil
	
	local ignore = {workspace.Effects, selectedModel, game.Players.LocalPlayer.Character}
	local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
	ray = Ray.new(ray.Origin, ray.Direction * 500)
	
	while true do
		part, pos, normal = workspace:FindPartOnRayWithIgnoreList(ray, ignore, true, true)
		if not part then buildType = nil return end
		
		if part.Name == "ShieldDome" then 
			table.insert(ignore, part) continue 
		end
		
		if part.Name == "Snap" then 
			if StructureUtil.CanSnap(selectedAssembly, StructureUtil.GetModel(part)) and part.Object.Value == nil then 
				buildType = "Snapped" return 
			end
			
			table.insert(ignore, part) continue
		end
		
		if part.Name == "Connector" then
			if StructureUtil.CanSnap(selectedAssembly, "Connector") and part.Object.Value == nil then 
				buildType = "Connected" return 
			end
		end
		
		buildType = "Placing"
		
		return
	end
end

local function Rotate(_, inputState, inputObject)
	if inputObject.KeyCode == Enum.KeyCode.R and inputState == Enum.UserInputState.Begin then
		Positioner.Rotate(90)
	end
	
	if inputObject.UserInputType == Enum.UserInputType.MouseWheel then
		if inputObject.Position.Z == 1 then
			Positioner.Rotate(15)
			
		elseif inputObject.Position.Z == -1 then
			Positioner.Rotate(-15)
		end
	end
end

function AdvanceSnap(_, inputState, _)
	if inputState ~= Enum.UserInputState.Begin then return end
	
	snapState = (snapState % maxSnaps) + 1
end

function OnShift(_, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		ContextActionService:BindAction("SmoothRotate", Rotate, false, Enum.UserInputType.MouseWheel)
		scrollBound = true
		
	elseif inputState == Enum.UserInputState.End then
		ContextActionService:UnbindAction("SmoothRotate")
		scrollBound = false
	end
end

function ConnectCylinder(cylinder, h1, h2)
	local pos1 = h1.CFrame * CFrame.new(h1.Size.X / 2, 0, 0).Position
	local pos2 = h2.CFrame * CFrame.new(h2.Size.X / 2, 0, 0).Position
	local cylinderPos = pos1:lerp(pos2, 0.5)
	local CylinderCFrame = CFrame.new(cylinderPos, pos2)
	
	cylinder.Size = Vector3.new((pos1 - pos2).Magnitude, 1, 1)
	cylinder.CFrame = CylinderCFrame:ToWorldSpace(CFrame.Angles(0, math.rad(90) ,0)) -- Cylinders are sideways because roblox
end

function Transmit()
	if hidden or not canPlace then return end
	
	local offset = part.CFrame:ToObjectSpace(selectedAssembly.PrimaryPart.CFrame)
	if selectedModel.Name == "Wire" and wire.attach1 then
		BuildRemote:FireServer(selectedModel.Name, buildType, snapState, {part = wire.attach1, offsetCF = wire.offset1}, {part = part, offsetCF = offset})
	else
		BuildRemote:FireServer(selectedModel.Name, buildType, snapState, {part = part, offsetCF = offset}, nil)
	end
	
	SelectionGui.Deselect()
end

function TransparentObject(obj)
	local toColor = obj:GetDescendants()
	table.insert(toColor, obj)
	
	for _, v in pairs(toColor) do
		if v:IsA("BasePart") then
			v.Transparency = 0.7 + 0.3*v.Transparency --1 - (1 - v.Transparency) * 0.3 --n0pa
			v.CanCollide = false
			
		elseif v:IsA("Texture") then
			v:Destroy()
		end
	end
end

function Advance(_, inputState, inputObject)
	if not selectedModel then return end
	
	if inputState ~= Enum.UserInputState.Begin then return end
	
	if not part then return end

	if selectedModel.Name == "Wire" then
		if wire.state == 1 then
			wire.attach1 = part
			wire.offset1 = part.CFrame:ToObjectSpace(selectedAssembly.PrimaryPart.CFrame)
			selectedAssembly = selectedAssembly:Clone()
			selectedAssembly.Parent = selectedModel
			wire[2] = selectedAssembly
			wire.Cylinder = game.ReplicatedStorage.Extras.WireCylinder:Clone()
			wire.Cylinder.Parent = selectedModel
			TransparentObject(wire.Cylinder)
			wire.state = 2
			BuildingConstraints.Add(selectedModel)
			Positioner.Rotate(180)
			
		elseif wire.state == 2 then
			Transmit()
		end
	else
		Transmit()
	end
end

function ColorConstraint(obj, canPlace)
	local color = canPlace and BrickColor.new("Cyan") or BrickColor.new("Really red")
	local toColor = obj:GetDescendants()
	table.insert(toColor, obj)
	
	for _, v in pairs(toColor) do
		if v:IsA("BasePart") then v.BrickColor = color end
	end
end

function ToggleView(view)
	hidden = not view
	selectedModel.Parent = (view and workspace.Effects) or nil
end

Placer.Update = function()
	if not selectedModel then return end
	
	GetMouse()
	if not part then ToggleView(false) return end
	
	local offsetCF
	if buildType == "Placing" then
		offsetCF = Positioner.Standard(selectedAssembly, part, pos, normal) 
		
	elseif buildType == "Snapped" then
		offsetCF = Positioner.Snapped(selectedAssembly.PrimaryPart, selectedAssembly.Snaps[tostring(snapState)], part)
		
	elseif buildType == "Connected" then
		offsetCF = Positioner.Wire(selectedAssembly.PrimaryPart, selectedAssembly.Connectors[tostring(snapState)], part)
	end
	selectedAssembly:SetPrimaryPartCFrame(part.CFrame:ToWorldSpace(offsetCF))
	
	if wire and wire.state == 2 then ConnectCylinder(wire.Cylinder, wire[1].Ball, wire[2].Ball) end
	
	local attachedModel1, attachedModel2
	if wire then 
		attachedModel1 = (StructureUtil.IsDetector(wire.attach1) and StructureUtil.GetModel(wire.attach1)) or nil
		attachedModel2 = (StructureUtil.IsDetector(wire.attach2) and StructureUtil.GetModel(wire.attach2)) or nil
	else 
		attachedModel1 = (StructureUtil.IsDetector(part) and StructureUtil.GetModel(part)) or nil
	end
	
	canPlace = BuildingConstraints.Check(selectedModel, {attachedModel1, attachedModel2})
	
	ColorConstraint(selectedModel, canPlace)
	ToggleView(true)
end

Placer.Select = function(model)
	Placer.Placing = true
	selectedAssembly = model:Clone()
	if model.Name == "Wire" then
		wire = {}
		selectedModel = Instance.new("Model")
		selectedModel.Name = "Wire"
		wire[1] = selectedAssembly
		wire[1].Parent = selectedModel
		wire.state = 1
	else
		selectedModel = selectedAssembly
	end
	
	local snapFolder = selectedAssembly:FindFirstChild("Snaps") or selectedAssembly:FindFirstChild("Connectors")
	ContextActionService:BindAction("Cancel", SelectionGui.Deselect, false, Enum.KeyCode.E)
	ContextHint.AddHint("Place", {"L-Click", "Place"})	
	ContextHint.AddHint("HardRotate", {"R", "Rotate 90"})
	ContextHint.AddHint("SmoothRotate", {"Shift + Scroll", "Smooth Rotate"})
	ContextHint.AddHint("Cancel", {"E", "Cancel"})
	ContextActionService:BindAction("ClickAdvance", Advance, false, Enum.UserInputType.MouseButton1)
	ContextActionService:BindAction("HardRotate", Rotate, false, Enum.KeyCode.R)
	ContextActionService:BindAction("ShiftRotate", OnShift, false, Enum.KeyCode.LeftShift)
	ContextActionService:BindAction("ChangeSnap", AdvanceSnap, false, Enum.KeyCode.T)
	
	snapState = 1
	maxSnaps = snapFolder and #snapFolder:GetChildren()
	if maxSnaps and maxSnaps > 1 then 
		ContextHint.AddHint("ChangeSnap", {"T", "Change Snap"})
	end
	
	TransparentObject(selectedModel)
	BuildingConstraints.Add(selectedModel)
end

Placer.DeSelect = function()
	Placer.Placing = false
	
	if selectedModel then
		selectedModel:Destroy() 
		selectedModel = nil
	end
	
	if wire then wire = nil end
	
	Positioner.Rotation = 0
	if scrollBound then ContextActionService:UnbindAction("SmoothRotate") end
	ContextActionService:UnbindAction("ClickAdvance")
	ContextHint.RemoveHint("Place")
	ContextActionService:UnbindAction("HardRotate")
	ContextHint.RemoveHint("HardRotate")
	ContextActionService:UnbindAction("ShiftRotate")
	ContextHint.RemoveHint("SmoothRotate")
	ContextActionService:UnbindAction("ChangeSnap")
	ContextHint.RemoveHint("ChangeSnap")
	ContextActionService:UnbindAction("Cancel")
	ContextHint:RemoveHint("Cancel")
	selectedModel = nil
end

return Placer