-- Author: 4812571

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Stats = require(ReplicatedStorage.Stats.Structure)
local ElectricityDisplay = require(ServerScriptService.Packages.Electricity.Display)

local objectStats = Stats[script.Name]

function onAdded(object)
	ElectricityDisplay.SetDisplay(object, objectStats.ConstantProduction)
end

local GeothermalGeneratorServer = {}
GeothermalGeneratorServer.__index = GeothermalGeneratorServer

function GeothermalGeneratorServer.new(instance)
	local self = setmetatable({}, GeothermalGeneratorServer)
	self.Instance = instance

	-- Shim
	onAdded(instance)
end

function GeothermalGeneratorServer:Destroy()

end

return GeothermalGeneratorServer
