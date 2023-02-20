-- Author: 4812571

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Stats = require(ReplicatedStorage.Stats.Structure)
local ElectricityDisplay = require(ServerScriptService.Packages.Electricity.Display)

local totalProduction = Stats["Geothermal Generator"].ConstantProduction + Stats["Pump Producer"].ConstantProduction

function onAdded(object)
	ElectricityDisplay.SetDisplay(object.UpgradeRoot.Value, totalProduction)
end

local PumpProducer = {}
PumpProducer.__index = PumpProducer

function PumpProducer.new(instance)
	local self = setmetatable({}, PumpProducer)
	self.Instance = instance

	-- Shim
	onAdded(instance)

	return self
end

function PumpProducer:Destroy()

end

return PumpProducer