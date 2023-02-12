-- Author: 4812571

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Stats = require(ReplicatedStorage.Stats.Structure)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)
local ElectricityDisplay = require(ServerScriptService.Packages.Electricity.Display)
local Influencer = require(ServerScriptService.Packages.Electricity.Classes.NetworkObjects.Influencer)





local module = {}

--Roblox Services

--Import

--Data
local Grounded = {}
local Ungrounded = {}
local objectStats = Stats[script.Name]
local objectData = {}

--Variables
local tickCount = 0
local updateFrequency = 30
local minProduction = objectStats.MinProduction
local maxProduction = objectStats.MaxProduction
local minHeight = objectStats.MinHeight
local maxHeight = objectStats.MaxHeight

function getProduction(object)
	--https://www.desmos.com/calculator/pshxnz0pjo
	local heightFactor = math.clamp((object.PrimaryPart.Position.Y - minHeight) / (maxHeight - minHeight), 0, 1)
	print(heightFactor)
	return minProduction + ((maxProduction - minProduction) * heightFactor)
end

function updateProduction(object)
	local production = getProduction(object)
	objectData[object].influencer:SetInfluence(production)
	ElectricityDisplay.SetDisplay(object, production)
	
	print("Setting production to:", production)
end

function onAdded(object)
	objectData[object] = {}
	
	--Ground State
	if object.PrimaryPart:IsGrounded() then Grounded[object] = true else Ungrounded[object] = true end
	
	--Create Influencer
	local influencer = Influencer.New()
	objectData[object].influencer = influencer
	updateProduction(object)
	
	local node = Electricity.GetNode(object)
	influencer:BindNode(node)
end

function onRemoved(object)
	Grounded[object] = nil
	Ungrounded[object] = nil
	objectData[object] = nil
end

module.Run = function(delta)
	
	for v, _ in pairs(Ungrounded) do
		if v.PrimaryPart:IsGrounded() then
			Ungrounded[v], Grounded[v]  = nil, true
			updateProduction(v)
		end
	end
	
	for v, _ in pairs(Grounded) do
		if not v.PrimaryPart:IsGrounded() then
			Ungrounded[v], Grounded[v]  = true, nil
		end
	end
	
	if tickCount == 0 then
		for v, _ in pairs(Ungrounded) do
			updateProduction(v)
		end
	end
	
	tickCount = (tickCount + 1) % updateFrequency 
end

CollectionService:GetInstanceAddedSignal(script.Name):Connect(onAdded)
CollectionService:GetInstanceRemovedSignal(script.Name):Connect(onRemoved)

return module
