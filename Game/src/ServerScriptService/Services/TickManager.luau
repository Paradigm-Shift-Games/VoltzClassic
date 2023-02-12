--Author: 4812571

local module = {}

local RunService = game:GetService("RunService")
local Network = require(game.ServerScriptService.Packages.Electricity.Classes.Network)
local TimerService = require(game.ServerScriptService.Services.TimerService)
local Simulation = require(game.ServerScriptService.Services.SimulationService)
local Projectile = require(game.ServerScriptService.Services.ProjectileService)

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

module.Activate = function()
	activated = true
	module.Enable()	
end

module.Enable = function()
	if not activated then warn("TickManager inactive!") return false end
	if not connection then
		connection = RunService.Heartbeat:Connect(Tick)
	end
end
	
module.Disable = function()
	if not activated then warn("TickManager inactive!") return false end
	if connection then
		connection:Disconnect()
		connection = nil
	end
end

module.Toggle = function()
	if not activated then warn("TickManager inactive!") return false end
	if connection then module.Disable() else module.Enable() end
end


return module
