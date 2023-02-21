-- Author: 4812571

local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local TimerService = require(ServerScriptService.Services.TimerService)
local Simulation = require(ServerScriptService.Services.SimulationService)
local Projectile = require(ServerScriptService.Services.ProjectileService)
local Network = require(ServerScriptService.Packages.Electricity.Classes.Network)

local TickManager = {}

local activated = false
local connection

function serviceWrapper(name, func, delta)
	TimerService.Start(name)
	func(delta)
	TimerService.Record(name)
end

function Tick(delta)
	TimerService.Start("Game")
	serviceWrapper("Electricity", Network.Run, delta)
	serviceWrapper("ProjectileService", Projectile.Run, delta)
	serviceWrapper("Simulation", Simulation.Run, delta)
	TimerService.Record("Game")	
end

TickManager.Activate = function()
	activated = true
	TickManager.Enable()	
end

TickManager.Enable = function()
	if not activated then warn("TickManager inactive!") return false end
	if not connection then
		connection = RunService.Heartbeat:Connect(Tick)
	end
end
	
TickManager.Disable = function()
	if not activated then warn("TickManager inactive!") return false end
	if connection then
		connection:Disconnect()
		connection = nil
	end
end

TickManager.Toggle = function()
	if not activated then warn("TickManager inactive!") return false end
	if connection then TickManager.Disable() else TickManager.Enable() end
end

return TickManager
