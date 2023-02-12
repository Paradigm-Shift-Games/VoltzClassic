--Author: 4812571

local module = {}

local CollectionService = game:GetService("CollectionService")
local ElectricityDisplay = require(game.ServerScriptService.Packages.Electricity.Display)
local Stats = require(game.ReplicatedStorage.Stats.Structure)
local totalProduction = Stats["Geothermal Generator"].ConstantProduction + Stats["Pump Producer"].ConstantProduction

function onAdded(object)
	ElectricityDisplay.SetDisplay(object.UpgradeRoot.Value, totalProduction)
end

CollectionService:GetInstanceAddedSignal(script.Name):Connect(onAdded)

return module
