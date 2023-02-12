-- Author: 4812571

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local StructureStats = require(ReplicatedStorage.Stats.Structure)
local Graph = require(ServerScriptService.Classes.Datastructure.Graph)
local EffectService = require(ServerScriptService.Services.EffectService)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)
local TransferLine = require(ServerScriptService.Packages.Electricity.Classes.NetworkObjects.TransferLine)

	
local module = {}

local hardGraph = Graph.New()
local softGraph = Graph.New()

--Stats
local DistributorStats = StructureStats["Distributor"]
local CapStats = StructureStats["Distributor Cap"]
local range = DistributorStats.Range

--Data
local Grounded = {}
local Ungrounded = {}
local TransferFlux = 0
local ConnectedPlayers = {}

--Settings
local Debug = false

local DebugHard = ColorSequence.new(Color3.fromRGB(0, 255, 0)) 
local DebugSoft = ColorSequence.new(Color3.fromRGB(255, 0, 0)) 

--Effect Creation
function ConnectBeam(Distributor, Cap)
	local effectID = EffectService.CreateEffect("DistributorBeam", Distributor.Point.Attachment, Cap:FindFirstChild("DistributorAttachment", true))
	local transferLine = TransferLine.New(Electricity.GetNode(Cap), DistributorStats.TransferRate)
	transferLine:BindNode(Electricity.GetNode(Distributor))
	return {transferLine = transferLine, effectID = effectID}
end

function TerminateBeam(beamData)
	print("Connecting un beam")
	EffectService.EndEffect(beamData.effectID)
	beamData.transferLine:Unbind()
end

function AttemptInitialConnection(Distributor, Cap)	
	if (Distributor.Point.Position - Cap.PrimaryPart.Position).Magnitude > range then return end
	local beamData = ConnectBeam(Distributor, Cap)
	
	--Effect Initialize
	if Grounded[Distributor] and Grounded[Cap] then
		--print("Creating Initial Hard Connection")
		hardGraph:Connect(Distributor, Cap, beamData)
		if Debug then EffectService.SignalEffect(beamData.effectID, "SetColor", DebugHard) end
	else
		--print("Creating Initial Soft Connection")
		softGraph:Connect(Distributor, Cap, beamData)
		if Debug then EffectService.SignalEffect(beamData.effectID, "SetColor", DebugSoft) end
	end
end

--Objects Added
function OnDistributorAdded(Distributor)
	--print("Adding Distributor")
	if Distributor.PrimaryPart:IsGrounded() then Grounded[Distributor] = true else Ungrounded[Distributor] = true end
	for _, Cap in pairs(CollectionService:GetTagged("Distributor Cap")) do AttemptInitialConnection(Distributor, Cap) end
	for _, Pack in pairs(CollectionService:GetTagged("Backpack")) do AttemptInitialConnection(Distributor, Pack) end
end

function OnCapAdded(Cap)
	if Cap.PrimaryPart:IsGrounded() then Grounded[Cap] = true else Ungrounded[Cap] = true end
	for _, Distributor in pairs(CollectionService:GetTagged("Distributor")) do AttemptInitialConnection(Distributor, Cap) end
end

function OnRemoved(Structure)
	for _, beamData in pairs(hardGraph:GetConnections(Structure)) do TerminateBeam(beamData) end
	for _, beamData in pairs(softGraph:GetConnections(Structure)) do TerminateBeam(beamData) end
	hardGraph:RemoveNode(Structure)
	softGraph:RemoveNode(Structure)
	Grounded[Structure], Ungrounded[Structure] = nil, nil
end

--Connections
CollectionService:GetInstanceAddedSignal("Distributor"):Connect(OnDistributorAdded)
CollectionService:GetInstanceAddedSignal("Distributor Cap"):Connect(OnCapAdded)
CollectionService:GetInstanceAddedSignal("Backpack"):Connect(OnCapAdded)

CollectionService:GetInstanceRemovedSignal("Distributor"):Connect(OnRemoved)
CollectionService:GetInstanceRemovedSignal("Distributor Cap"):Connect(OnRemoved)
CollectionService:GetInstanceRemovedSignal("Backpack"):Connect(OnRemoved)


--Object Update
function runObject(Distributor)
	local team = Distributor.Team.Value
	local hardConnected = hardGraph:GetConnections(Distributor)
	local softConnected = softGraph:GetConnections(Distributor)
	
	--Scan New Soft Connections
	for v, _ in pairs(Ungrounded) do
		if not (v.Name == "Distributor Cap" or v.Name == "Backpack") then continue end
		if softConnected[v] then continue end
		if (Distributor.Point.Position - v.PrimaryPart.Position).Magnitude > range then continue end
		--print("Creating New Soft Connection")
		local beamData = ConnectBeam(Distributor, v)
		softGraph:Connect(Distributor, v, beamData)
		if Debug then EffectService.SignalEffect(beamData.effectID, "SetColor", DebugSoft) end
	end
	
	--Disconnect Invalid Soft Connections
	for Cap, _ in pairs(softConnected) do
		if (Distributor.Point.Position - Cap.PrimaryPart.Position).Magnitude > range then
			local beamData = softGraph:GetConnectionData(Distributor, Cap)
			softGraph:Disconnect(Distributor, Cap)
			TerminateBeam(beamData)
		end
	end 
end

--Service Update
module.Run = function(delta)
	--Swap Grounded -> Ungrounded
	for Object, _ in pairs(Grounded) do
		if Object.PrimaryPart:IsGrounded() then continue end
		--print(Object.Name, "Ungrounded!")

		--Transfer all connections to Soft Graph
		for Connected, _ in pairs(hardGraph:GetConnections(Object)) do
			--print("Swapping Hard -> Soft Graph!")
			local beamData = hardGraph:GetConnectionData(Object, Connected)
			hardGraph:Disconnect(Object, Connected)
			softGraph:Connect(Object, Connected, beamData)
			if Debug then EffectService.SignalEffect(beamData.effectID, "SetColor", DebugSoft) end
		end
		Grounded[Object], Ungrounded[Object] = nil, true
	end

	--Swap Ungrounded -> Grounded
	for Object, _ in pairs(Ungrounded) do
		if not Object.PrimaryPart or not Object.PrimaryPart:IsGrounded() then continue end		
		--print(Object.Name, "Grounded!")

		--Transfer all grounded connections to Hard Graph
		for Connected, _ in pairs(softGraph:GetConnections(Object)) do
			if not Grounded[Connected] then continue end
			--print("Swapping Soft -> Hard Graph!")
			local beamData = softGraph:GetConnectionData(Object, Connected)
			softGraph:Disconnect(Object, Connected)
			hardGraph:Connect(Object, Connected, beamData)
			if Debug then EffectService.SignalEffect(beamData.effectID, "SetColor", DebugHard) end
		end
		Grounded[Object], Ungrounded[Object] = true, nil
	end
	
	--Run All Distributors
	TransferFlux = DistributorStats.TransferRate * delta
	for _, v in pairs(CollectionService:GetTagged("Distributor")) do runObject(v) end
end

return module
