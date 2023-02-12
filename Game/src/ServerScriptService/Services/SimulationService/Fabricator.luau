-- Author: 4812571

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local StructureStats = require(ReplicatedStorage.Stats.Structure)
local Graph = require(ServerScriptService.Classes.Datastructure.Graph)
local EffectService = require(ServerScriptService.Services.EffectService)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)
local ArrayGraph = require(ServerScriptService.Classes.Datastructure.ArrayGraph)
local TransferLine = require(ServerScriptService.Packages.Electricity.Classes.NetworkObjects.TransferLine)

local module = {}

--Graphs
local beamGraph = 		Graph.New()
local debugBeamGraph = 	Graph.New()
local hardGraph = 		ArrayGraph.New()
local softGraph = 		ArrayGraph.New()

--Stats
local FabricatorStats = StructureStats["Fabricator"]
local range = FabricatorStats.Range

--Data
local Grounded = {}
local Ungrounded = {}
local FabricatorData = {}

--Settings
local Debug = false
local DebugDefault = ColorSequence.new(Color3.fromRGB(0, 0, 0))
local DebugHard = ColorSequence.new(Color3.fromRGB(0, 255, 0)) 
local DebugSoft = ColorSequence.new(Color3.fromRGB(255, 0, 0)) 

--Debug
function EnableDebug()
	print("Fabricator: Enabling Debug Mode")
	for _, Fabricator in ipairs(CollectionService:GetTagged("Fabricator")) do
		
		for _, Blueprint in ipairs(hardGraph:GetConnections(Fabricator)) do
			local effectID = EffectService.CreateEffect("FabricatorDebugBeam")
			EffectService.SignalEffect(effectID, "SetColor", DebugHard)
			debugBeamGraph:Connect(Fabricator, Blueprint, effectID)
		end
		
		for _, Blueprint in ipairs(softGraph:GetConnections(Fabricator)) do
			local effectID = EffectService.CreateEffect("FabricatorDebugBeam")
			EffectService.SignalEffect(effectID, "SetColor", DebugHard)
			debugBeamGraph:Connect(Fabricator, Blueprint, effectID)
		end
	end
end

function DisableDebug()
	print("Fabricator: Disabling Debug Mode")
	for _, Fabricator in ipairs(CollectionService:GetTagged("Fabricator")) do
		for Blueprint, effectID in pairs(debugBeamGraph:GetConnections(Fabricator)) do 
			EffectService.EndEffect(effectID)  
			debugBeamGraph:Disconnect(Fabricator, Blueprint)
		end
	end
end

--Lines
function ConnectBeam(Fabricator, Blueprint)
	local effectID = EffectService.CreateEffect("FabricatorBeam", Fabricator.Point.Attachment, Blueprint.PrimaryPart)
	local transferLine = TransferLine.New(Electricity.GetNode(Blueprint), FabricatorStats.TransferRate)
	transferLine:BindNode(Electricity.GetNode(Fabricator))
	return {transferLine = transferLine, effectID = effectID}
end

function TerminateBeam(beamData)
	EffectService.EndEffect(beamData.effectID)
	beamData.transferLine:Unbind()
end

--Connections
function Connect(graph, Fabricator, Blueprint)
	graph:Connect(Fabricator, Blueprint)
	if Debug then
		local effectID = EffectService.CreateEffect("FabricatorDebugBeam", Fabricator.Point.Attachment, Blueprint.PrimaryPart)
		local debugColor = DebugDefault
		if graph == softGraph then debugColor = DebugSoft end
		if graph == hardGraph then debugColor = DebugHard end
		EffectService.SignalEffect(effectID, "SetColor", debugColor)
		debugBeamGraph:Connect(Fabricator, Blueprint, effectID)
	end
end

function Disconnect(Fabricator, Blueprint)
	local beamData = debugBeamGraph:GetConnectionData(Fabricator, Blueprint)
	if beamData then TerminateBeam(beamData) end
	
	beamGraph:Disconnect(Fabricator, Blueprint)
	softGraph:Disconnect(Fabricator, Blueprint)
	hardGraph:Disconnect(Fabricator, Blueprint)
	if Debug then
		local effectID = debugBeamGraph:GetConnectionData(Fabricator, Blueprint)
		EffectService.EndEffect(effectID)
		debugBeamGraph:Disconnect(Fabricator, Blueprint)
	end
end

function SwapConnection(graph1, graph2, Fabricator, Blueprint)
	graph1:Disconnect(Fabricator, Blueprint)
	graph2:Connect(Fabricator, Blueprint)
	local debugColor = DebugDefault
	if graph2 == softGraph then debugColor = DebugSoft end
	if graph2 == hardGraph then debugColor = DebugHard end
	if Debug then
		local effectID = debugBeamGraph:GetConnectionData(Fabricator, Blueprint)
		EffectService.SignalEffect(effectID, "SetColor", debugColor)
	end
end

function AttemptInitialConnection(Fabricator, Blueprint)	
	if Fabricator.Team.Value ~= Blueprint.Team.Value then return end
	if (Fabricator.Point.Position - Blueprint.PrimaryPart.Position).Magnitude > range then return end
	
	--Effect Initialize
	if Grounded[Fabricator] and Grounded[Blueprint] then
		print("Creating Initial Hard Connection")
		Connect(hardGraph, Fabricator, Blueprint)
	else
		print("Creating Initial Soft Connection")
		Connect(softGraph, Fabricator, Blueprint)
	end
end

--Objects Added

function OnFabricatorAdded(Fabricator)
	print("Adding Fabricator")
	if Fabricator.PrimaryPart:IsGrounded() then Grounded[Fabricator] = true else Ungrounded[Fabricator] = true end
	for _, Blueprint in pairs(CollectionService:GetTagged("Blueprint")) do AttemptInitialConnection(Fabricator, Blueprint) end
	FabricatorData[Fabricator] = {targetCount = 0}
end

function OnBlueprintAdded(Blueprint)
	if Blueprint.PrimaryPart:IsGrounded() then Grounded[Blueprint] = true else Ungrounded[Blueprint] = true end
	for _, Fabricator in pairs(CollectionService:GetTagged("Fabricator")) do AttemptInitialConnection(Fabricator, Blueprint) end
end

function OnRemoved(Structure)
	print("Remove")
	for _, beamData in pairs(beamGraph:GetConnections(Structure)) do TerminateBeam(beamData) end
	for _, effectID in pairs(debugBeamGraph:GetConnections(Structure)) do EffectService.EndEffect(effectID) end
	debugBeamGraph:RemoveNode(Structure)
	beamGraph	  :RemoveNode(Structure)
	hardGraph     :RemoveNode(Structure)
	softGraph     :RemoveNode(Structure)
	Grounded[Structure], Ungrounded[Structure] = nil, nil
	FabricatorData[Structure] = nil
end

--Connections
CollectionService:GetInstanceAddedSignal("Blueprint"):Connect(OnBlueprintAdded)
CollectionService:GetInstanceRemovedSignal("Blueprint"):Connect(OnRemoved)

--Object Update
function getCount(hashtab) 
	local count = 0 for _, _ in pairs(hashtab) do count += 1 end
	return count
end

function GetBlueprint(Fabricator)
	local hardConnected = hardGraph:GetConnections(Fabricator)
	local softConnected = softGraph:GetConnections(Fabricator)
	local beamConnected = beamGraph:GetConnections(Fabricator)
	local tab = {}
	
	for _, blueprint in ipairs(hardConnected) do 
		tab[blueprint] = true
		if not beamConnected[blueprint] then return blueprint end
	end
	
	for _, blueprint in ipairs(softConnected) do
		tab[blueprint] = true
		if not beamConnected[blueprint] then return blueprint end
	end
end

function runObject(Fabricator)
	local softConnected = softGraph:GetConnections(Fabricator)
	
	--Scan New Soft Connections
	for v, _ in ipairs(Ungrounded) do
		if v.Name == "Fabricator" then continue end
		if softConnected[v] then continue end
		if (Fabricator.Point.Position - v.PrimaryPart.Position).Magnitude > range then continue end
		AttemptInitialConnection(Fabricator, v)
	end
	
	--Disconnect Invalid Soft Connections
	for i = softConnected:GetSize(), 1 , -1 do
		local Blueprint = softConnected[i]
		if (Fabricator.Point.Position - Blueprint.PrimaryPart.Position).Magnitude < range then continue end
		Disconnect(Fabricator, Blueprint)
	end
	
	if getCount(beamGraph:GetConnections(Fabricator)) < FabricatorStats.BeamCount then
		local Blueprint = GetBlueprint(Fabricator)
		if not Blueprint then return end
		local beamData = ConnectBeam(Fabricator, Blueprint)
		beamGraph:Connect(Fabricator, Blueprint, beamData)
	end
end

--Service Update
module.Run = function(delta)
	--Swap Grounded -> Ungrounded
	for Object, _ in pairs(Grounded) do
		if Object.PrimaryPart:IsGrounded() then continue end
		print(Object.Name, "Ungrounded!")

		--Transfer all connections to Soft Graph
		local connections = hardGraph:GetConnections(Object)
		for i = connections:GetSize(), 1, -1 do 
			local Connected = connections[i]
			print("Swapping Hard -> Soft Graph!")
			SwapConnection(hardGraph, softGraph, Object, Connected)
		end
		Grounded[Object], Ungrounded[Object] = nil, true
	end

	--Swap Ungrounded -> Grounded
	for Object, _ in pairs(Ungrounded) do
		if not Object.PrimaryPart:IsGrounded() then continue end		
		print(Object.Name, "Grounded!")

		--Transfer all grounded connections to Hard Graph
		local connections = softGraph:GetConnections(Object)
		for i = connections:GetSize(), 1, -1 do
			local Connected = connections[i]
			if not Grounded[Connected] then continue end
			print("Swapping Soft -> Hard Graph!")
			SwapConnection(softGraph, hardGraph, Object, Connected)
		end
		Grounded[Object], Ungrounded[Object] = true, nil
	end
end

local FabricatorServer = {}
FabricatorServer.__index = FabricatorServer

function FabricatorServer.new(instance)
	local self = setmetatable({}, FabricatorServer)
	self.Instance = instance

	-- Shim
	OnFabricatorAdded(instance)

	return self
end

function FabricatorServer:Update(deltaTime)
	-- Shim
	runObject(self.Instance)
end

function FabricatorServer:Destroy()
	-- Shim
	OnRemoved(self.Instance)
end

function FabricatorServer.StaticUpdate(deltaTime)
	-- Shim
	module.Run(deltaTime)
end

return FabricatorServer
