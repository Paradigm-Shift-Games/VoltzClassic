-- Author: 4812571

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Stats = require(ReplicatedStorage.Stats.Structure)

local Template = {}

local objectStats = Stats[script.Name]
local objectData = {}

function onAdded(object)
	objectData[object] = {}	
end

function onRemoved(object)
	objectData[object] = nil
end

function runObject(object, delta)
	
end

local TemplateServer = {}
TemplateServer.__index = TemplateServer

function TemplateServer.new(instance)
	local self = setmetatable({}, TemplateServer)
	self.Instance = instance

	-- Shim
	onAdded(instance)
end

function TemplateServer:Update(deltaTime)
	-- Shim
	runObject(self.Instance, deltaTime)
end

function TemplateServer:Destroy()
	-- Shim
	onRemoved(self.Instance)
end

return Template
