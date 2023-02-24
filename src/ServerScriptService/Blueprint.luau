-- Author: 4812571

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Stats = require(ReplicatedStorage.Stats.Structure)
local ColorizerService = require(ServerScriptService.Services.ColorizerService)
local StructureUtil = require(ReplicatedStorage.StructureUtility)
local Structure = require(ServerScriptService.Services.Structure)
local UpgradeData = require(ServerScriptService.Services.UpgradeData)
local WeldService = require(ServerScriptService.Services.WeldService)
local DamageService = require(ServerScriptService.Services.DamageService)
local BuildingConstraints = require(ReplicatedStorage.BuildingConstraints)
local SnapData = require(ServerScriptService.Services.SnapData).GetSnaps()
local AssemblyService = require(ServerScriptService.Services.AssemblyService)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)
local ElectricNode = require(ServerScriptService.Packages.Electricity.Classes.Node)
local ElectricHook = require(ServerScriptService.Packages.Electricity.Classes.NetworkObjects.Hook)

local Blueprint = {}
local BuildEvent = ReplicatedStorage.Events.Builder
local UpgradeEvent = ReplicatedStorage.Events.Upgrade

local attachNames = {"Distributor Cap", "Cap"}

function ConnectCylinder(cylinder, h1, h2)
	--[[Hemisphere code
		local pos1 = h1.CFrame * CFrame.new(h1.Size.X / 2, 0, 0).Position
		local pos2 = h2.CFrame * CFrame.new(h2.Size.X / 2, 0, 0).Position
	]]
	
	local pos1, pos2 = h1.Position, h2.Position
	cylinder.Size = Vector3.new((pos1 - pos2).Magnitude, 1.5, 1.5)
	local cylinderPos = pos1:lerp(pos2, 0.5)
	local CylinderCFrame = CFrame.new(cylinderPos, pos2)
	cylinder.CFrame = CylinderCFrame:ToWorldSpace(CFrame.Angles(0, math.rad(90) ,0)) -- Cylinders are sideways because roblox
end

function ConnectorGroup(folder)
	for _, v in folder:GetChildren() do
		v.Name = "DisabledConnector"
	end
	
end

function WireGroup(model, folder1, folder2)
	for _, v in folder2:GetChildren() do
		v.Parent = folder1
	end
	folder2:Destroy()
	folder1.Parent = model
	ConnectorGroup(folder1)
end

function SnapGroup(folder)
	for _, v in folder:GetChildren() do
		v.Name = "DisabledSnap"
	end
end

function GetWire(attachment1, attachment2)
	local model = Instance.new("Model")
	local wire1 = ReplicatedStorage.Objects["Wire"]:Clone()
	local wire2 = ReplicatedStorage.Objects["Wire"]:Clone()
	wire1.Name = "Wire1"
	wire2.Name = "Wire2"
	local wireCylinder = ReplicatedStorage.Extras.WireCylinder:Clone()
	wire1:SetPrimaryPartCFrame(attachment1.part.CFrame * attachment1.offsetCF)
	wire2:SetPrimaryPartCFrame(attachment2.part.CFrame * attachment2.offsetCF)
	ConnectCylinder(wireCylinder, wire1.Ball, wire2.Ball)
	wire1.Parent = model
	wire2.Parent = model
	wireCylinder.Parent = model
	model.Name = "Wire"
	model.PrimaryPart = wireCylinder
	return model
end

function GetStructure(modelName, attachment, snapState)
	local model = ReplicatedStorage.Objects[modelName]:Clone()
	model:SetPrimaryPartCFrame(attachment.part.CFrame * attachment.offsetCF)
	local attachedModel = StructureUtil.IsDetector(attachment.part) and StructureUtil.GetModel(attachment.part)
	local snapped = attachedModel and StructureUtil.CanSnap(modelName, attachedModel)
	local connected = attachedModel and attachment.part.Name == "Connector" and StructureUtil.CanSnap(modelName, "Connector")
	return model
end

function GetModel(modelName, attachment1, attachment2, snapState)
	if modelName == "Wire" then
		return GetWire(attachment1, attachment2)
	else
		return GetStructure(modelName, attachment1, snapState)
	end
end

function Place(player, team, modelName, buildType, snapState, instantStructure, attachment1, attachment2)
	
	-- Get Model
	local model = GetModel(modelName, attachment1, attachment2, snapState)
	
	-- Get Attachment Models
	if attachment1 then attachment1.Model = StructureUtil.GetModel(attachment1.part) end
	if attachment2 then attachment2.Model = StructureUtil.GetModel(attachment2.part) end
	local attachment1Lookup = attachment1 and attachment1.Model and (attachment1.part.Name == "Connector" and "Connector" or attachment1.Model.Name)
	local attachment2Lookup = attachment2 and attachment2.Model and (attachment2.part.Name == "Connector" and "Connector" or attachment2.Model.Name)
	
	-- Check Attachment Model Connection State
	local attachedModel1 = attachment1 and StructureUtil.IsDetector(attachment1.part) and StructureUtil.CanSnap(model, attachment1Lookup) and (not attachment1.part.Object.Value) and attachment1.Model or nil
	local attachedModel2 = attachment2 and StructureUtil.IsDetector(attachment2.part) and StructureUtil.CanSnap(model, attachment2Lookup) and (not attachment2.part.Object.Value) and attachment2.Model or nil
	
	if (buildType == "Snapped" or buildType == "Connected") and not attachedModel1 then
		warn("Server-Side Snap Failure!")
	end
	
	-- Assemble Models
	if attachedModel1 and table.find(attachNames, modelName) then
		AssemblyService.Attach(model, attachedModel1, "Attach")
	end
	
	-- Attach Model Values
	if modelName == "Wire" then
		if attachedModel1 then
			local wire = model.Wire1
			local attachment = attachment1
			attachment.part.Object.Value = wire.Connectors["1"]
			wire.Connectors["1"].Object.Value = attachment.part
		end
		
		if attachedModel2 then
			local wire = model.Wire2
			local attachment = attachment2
			attachment.part.Object.Value = wire.Connectors["1"]
			wire.Connectors["1"].Object.Value = attachment.part
		end
		
	elseif attachedModel1 then
		local snapFolder = model:FindFirstChild("Snaps") or model:FindFirstChild("Connectors")
		attachment1.part.Object.Value = snapFolder[tostring(snapState)]    
		snapFolder[tostring(snapState)].Object.Value = attachment1.part
	end
	
	-- Group Snaps
	if modelName == "Wire" then
		WireGroup(model, model.Wire1.Connectors, model.Wire2.Connectors)
	else
		if model:FindFirstChild("Connectors") then
			ConnectorGroup(model.Connectors)
		end
		if model:FindFirstChild("Snaps") then
			SnapGroup(model.Snaps)
		end
	end
	
	-- Constraints
	BuildingConstraints.Add(model, player)
	local canPlace = BuildingConstraints.Check(model, {attachedModel1, attachedModel2})
	BuildingConstraints.Clear(model)
	if not canPlace then return end
	
	-- Welding
	if model:FindFirstChild("Hinge1", true) then
		WeldService.WeldAssembly(model)
	else
		WeldService.WeldModel(model)
	end
	
	WeldService.Unanchor(model)
	for _, v in model:GetDescendants() do
		if v.Name == "WeldPad" then
			local weldPad = v
			weldPad.CanCollide = false
			weldPad.Transparency = 1
			weldPad.Parent = workspace
			for _, v in pairs(StructureUtil.GetTouchingModels(weldPad)) do
				WeldService.WeldModels(model, v)
			end
		elseif v.Name == "Snaps" or v.Name == "Connectors" then
			for _, g in v:GetChildren() do
				if g.Object.Value then WeldService.WeldModels(model, StructureUtil.GetModel(g.Object.Value)) end		
			end
		end
	end
	
	-- Electrical $$DUPLICATE CODE$$
	CollectionService:AddTag(model, "NoLeaks")
	local node = ElectricNode.New()
	node.charge = 1 / 10^12 -- Small nonzero value
	node.storage = Stats[model.Name].Cost
	Electricity.BindStructure(model, node)
	
	local fullHook = ElectricHook.New("Filled")
	fullHook:Connect(function() Structure.Promote(model) end)
	fullHook:BindNode(node)
	
	local emptyHook = ElectricHook.New("Emptied")
	emptyHook:Connect(function() DamageService.Destroy(model) end)
	emptyHook:BindNode(node)
	
	local updatedHook = ElectricHook.New("ChargeUpdated")
	updatedHook:Connect(function(node) ColorizerService.UpdateBlueprintColor(node.structure, node:GetCharge(), node:GetStorage()) end)
	updatedHook:BindNode(node)
	
	local teamVal = Instance.new("ObjectValue")
	teamVal.Value = team
	teamVal.Name = "Team"
	teamVal.Parent = model
	
	-- Color $$DUPLICATE CODE$$
	if instantStructure then
		ColorizerService.ColorAsStructure(model)
		Structure.Promote(model)
	else
		ColorizerService.ColorAsBlueprint(model)
		CollectionService:AddTag(model, "Blueprint")
	end
	
	model.Parent = workspace.Structures
	CollectionService:RemoveTag(model, "BlueprintLoading")
	return model
end

function Upgrade(model, instantStructure)
	if CollectionService:HasTag(model, "Blueprint") then return false end
	if not (model:FindFirstChild("UpgradeState") and model:FindFirstChild("MaxUpgrades")) then return false end
	if model:FindFirstChild("Upgrading") then return false end
	if model.UpgradeState.Value >= model.MaxUpgrades.Value then return false end
	model.UpgradeState.Value += 1
	local upgrade = UpgradeData.GetUpgrade(model, model.UpgradeState.Value)
	local upgradeModel = upgrade.model:Clone()
	if upgradeModel:FindFirstChild("Rename") then upgradeModel.Name = upgradeModel.Rename.Value upgradeModel.Rename:Destroy() end
	AssemblyService.Attach(upgradeModel, model, "Attach")
	WeldService.WeldModel(upgradeModel)
	upgradeModel:SetPrimaryPartCFrame(model.PrimaryPart.CFrame:ToWorldSpace(upgrade.offset))
	WeldService.WeldModels(upgradeModel, model)
	WeldService.Unanchor(upgradeModel)
	local upgradeStats = Stats[model.Name]["Upgrades"][model.UpgradeState.Value]
	
	-- Values $$DUPLICATE CODE$$
	local teamVal = Instance.new("ObjectValue")
	local upgradeRoot = Instance.new("ObjectValue")
	local upgrading = Instance.new("BoolValue")
	teamVal.Value = model.Team.Value
	upgradeRoot.Value = model
	teamVal.Name = "Team"
	upgradeRoot.Name = "UpgradeRoot"
	upgrading.Name = "Upgrading"
	teamVal.Parent = upgradeModel
	upgradeRoot.Parent = upgradeModel
	upgrading.Parent = model
	
	
	-- Electrical $$DUPLICATE CODE$$
	CollectionService:AddTag(upgradeModel, "NoLeaks")
	local node = ElectricNode.New()
	node.charge = 1 / 10^12 -- Small nonzero value
	node.storage = upgradeStats.Cost
	Electricity.BindStructure(upgradeModel, node)

	local fullHook = ElectricHook.New("Filled")
	fullHook:Connect(function() Structure.Promote(upgradeModel) end)
	fullHook:BindNode(node)

	local emptyHook = ElectricHook.New("Emptied")
	emptyHook:Connect(function() DamageService.Destroy(upgradeModel) end)
	emptyHook:BindNode(node)

	local updatedHook = ElectricHook.New("ChargeUpdated")
	updatedHook:Connect(function(node) ColorizerService.UpdateBlueprintColor(node.structure, node:GetCharge(), node:GetStorage()) end)
	updatedHook:BindNode(node)
	
	-- Color $$DUPLICATE CODE$$
	if instantStructure then
		ColorizerService.ColorAsStructure(upgradeModel)
		Structure.Promote(upgradeModel)
	else
		ColorizerService.ColorAsBlueprint(upgradeModel)
		CollectionService:AddTag(upgradeModel, "Blueprint")
	end
	
	CollectionService:AddTag(upgradeModel, "Upgrade")
	upgradeModel.Parent = workspace.Structures	
end
	
function OnBuilderUpgrade(player, model)
	if model and model:FindFirstChild("Team") and model.Team.Value ~= player.Team then return end
	Upgrade(model)
end
function OnBuilderPlace(player, modelName, buildType, snapState,  attachment1, attachment2)
	Place(player, player.Team, modelName, buildType, snapState, false, attachment1, attachment2)
end

function Blueprint.Upgrade(model)
	Upgrade(model)
end

function Blueprint.Place(team, modelName, attachment1, attachment2, snapState, instantStructure)
	return Place("Server", team, modelName, "Placing", snapState, instantStructure, attachment1, attachment2)
end

function Blueprint.EasyPlace(team, modelName, attachedPart, PlacementCFrame, instantStructure)
	local cf = PlacementCFrame:ToWorldSpace(SnapData[modelName].Position)
	local attachment = {part = attachedPart, offsetCF = attachedPart.CFrame:ToObjectSpace(cf)}
	return Blueprint.Place(team, modelName, attachment, nil, 1, instantStructure)
end

BuildEvent.OnServerEvent:Connect(OnBuilderPlace)
UpgradeEvent.OnServerEvent:Connect(OnBuilderUpgrade)

return Blueprint

