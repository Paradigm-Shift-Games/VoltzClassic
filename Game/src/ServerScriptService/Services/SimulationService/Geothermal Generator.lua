--Author: 4812571

local module = {}

local CollectionService = game:GetService("CollectionService")
local ElectricityDisplay = require(game.ServerScriptService.Packages.Electricity.Display)
local Stats = require(game.ReplicatedStorage.Stats.Structure)
local objectStats = Stats[script.Name]

function onAdded(object)
	ElectricityDisplay.SetDisplay(object, objectStats.ConstantProduction)
end

CollectionService:GetInstanceAddedSignal(script.Name):Connect(onAdded)

return module
