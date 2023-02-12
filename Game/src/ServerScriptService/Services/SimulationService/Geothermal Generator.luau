-- Author: 4812571

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Stats = require(ReplicatedStorage.Stats.Structure)
local ElectricityDisplay = require(ServerScriptService.Packages.Electricity.Display)

local module = {}

local objectStats = Stats[script.Name]

function onAdded(object)
	ElectricityDisplay.SetDisplay(object, objectStats.ConstantProduction)
end

CollectionService:GetInstanceAddedSignal(script.Name):Connect(onAdded)

return module
