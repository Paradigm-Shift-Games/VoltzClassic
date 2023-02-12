-- Author: 4812571

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Stats = require(ReplicatedStorage.Stats.Structure)
local buttonService = require(ServerScriptService.Services.ButtonService)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)

local objectData = {}
local objectStats = Stats[script.Name]

function onAdded(object)
	objectData[object] = {}
	buttonService.Bind(object, object.Button, function(_, state) objectData[object].State = state end)
end

function onRemoved(object)
	objectData[object] = {state = false}
end

function runObject(object, delta)
	local enabled = objectData[object].State and Electricity.Pull(object, delta * objectStats.Consumption)
	if enabled then
		object.Anchor.Anchored = true
		object.Core.Transparency = 0
	else
		object.Anchor.Anchored = false
		object.Core.Transparency = 1
	end
end

local GravityDisplacerServer = {}
GravityDisplacerServer.__index = GravityDisplacerServer

function GravityDisplacerServer.new(instance)
	local self = setmetatable({}, GravityDisplacerServer)
	self.Instance = instance

	-- Shim
	onAdded(instance)
end

function GravityDisplacerServer:Update(delta)
	-- Shim
	runObject(self.Instance, delta)
end

function GravityDisplacerServer:Destroy()
	-- Shim
	onRemoved(self.Instance)
end

return GravityDisplacerServer
