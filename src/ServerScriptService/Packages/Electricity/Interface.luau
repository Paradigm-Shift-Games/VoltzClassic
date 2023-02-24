local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Node =         	require(ServerScriptService.Packages.Electricity.Classes.Node)
local Influencer =     	require(ServerScriptService.Packages.Electricity.Classes.NetworkObjects.Influencer)
local ChargeAnimator = 	require(ServerScriptService.Packages.Electricity.Classes.NetworkObjects.ChargeAnimator)

local StructureStats =	require(ReplicatedStorage.Stats.Structure)
local CleanupService =	require(ServerScriptService.Services.CleanupService)
local Electricity =   	require(ServerScriptService.Packages.Electricity.Electricity)

local Interface = {}

-- Data
local boundNode = {}

-- Helper Functions

local function buildNode(structure)
	local node = Node.New()
	local structureStats = StructureStats[structure.Name]
	node.structure = structure
	
	-- Storage
	if structureStats.Storage then
		node.storage = structureStats.Storage
		node.charge = 0
		
		-- Bars
		local electricalBars = {} for _, v in structure:GetDescendants() do if v.Name == "ChargeBar" then table.insert(electricalBars, v) end end
		for _, v in pairs(electricalBars) do
			ChargeAnimator.New(v, structure.PrimaryPart):BindNode(node)
		end
		
	end
	
	-- Production
	if structureStats.isProducer then
		node.isProducer = true
	end
	
	if structureStats.ConstantProduction then
		Influencer.New(structureStats.ConstantProduction):BindNode(node)
	end
	
	return node
end

-- Structure Actions
function Interface.BindStructure(structure, node)
	node.structure = structure
	boundNode[structure] = node
	Electricity.AddNode(node)
	CleanupService.Reserve(structure, "Electricity")
	return node
end

function Interface.AddStructure(structure)
	local node = buildNode(structure)
	boundNode[structure] = node
	Electricity.AddNode(node)
	CleanupService.Reserve(structure, "Electricity")
	return node
end

function Interface.ConnectStructures(structure1, structure2)
	local node1, node2 = boundNode[structure1], boundNode[structure2]
	Electricity.ConnectNodes(node1, node2)
end

function Interface.RemoveStructure(structure)
	local node = boundNode[structure]
	Electricity.RemoveNode(node)
	CleanupService.Unreserve(structure, "Electricity")
	boundNode[structure] = nil
end

-- Data Retrieval

function Interface.GetNode(structure)
	return boundNode[structure]
end

function Interface.GetCharge(structure)
	local node = boundNode[structure]
	if node then return node:GetCharge() end
	-- return boundNode[structure]:GetCharge()
end

function Interface.GetStorage(structure)
	local node = boundNode[structure]
	if node then return node:GetCapacity() end
	-- return boundNode[structure]:GetStorage()
end

function Interface.GetCapacity(structure)
	local node = boundNode[structure]
	if node then return node:GetCapacity() end
	-- return boundNode[structure]:GetCapacity()
end

function Interface.GetActivity(structure)
	local node = boundNode[structure]
	if node then return node:GetActivity() end
	-- return boundNode[structure]:GetActivity()
end

function Interface.GetChargePercent(structure)
	local charge = boundNode[structure]:GetCharge()
	local storage = boundNode[structure]:GetStorage()
	return storage > 0 and charge / storage or 0
end

-- Electricity Actions
function Interface.Push(structure, amount, allowPartial)
	local node = boundNode[structure]
	if node then return node:Push(amount, allowPartial) end
	-- node[structure]:Push(amount, allowPartial)
end

function Interface.Pull(structure, amount, allowPartial)
	local node = boundNode[structure]
	if node then return node:Pull(amount, allowPartial) end
	-- return boundNode[structure]:Pull(amount, allowPartial)
end

function Interface.Transfer(strucutre1, structure2, amount)
	local node1, node2 = boundNode[strucutre1], boundNode[structure2]
	local flux = math.min(amount, node1:GetCharge(), node2:GetCapacity())
	node1:Pull(flux, true)
    node2:Push(flux, true)
end

CleanupService.Bind("Electricity", Interface.RemoveStructure)

return Interface