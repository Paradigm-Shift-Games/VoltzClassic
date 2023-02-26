-- Author: 4812571

local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local TimerService = require(ServerScriptService.Services.TimerService)
local SimulationService = require(ServerScriptService.Services.SimulationService)
local ProjectileService = require(ServerScriptService.Services.ProjectileService)
local Network = require(ServerScriptService.Packages.Electricity.Classes.Network)

local TickManagerService = {}

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
	serviceWrapper("ProjectileService", ProjectileService.Run, delta)
	serviceWrapper("Simulation", SimulationService.Run, delta)
	TimerService.Record("Game")
end

function TickManagerService.Enable()
	if not activated then warn("TickManagerService inactive!") return false end
	if not connection then
		connection = RunService.Heartbeat:Connect(Tick)
	end
end
	
function TickManagerService.Disable()
	if not activated then warn("TickManagerService inactive!") return false end
	if connection then
		connection:Disconnect()
		connection = nil
	end
end

function TickManagerService.Toggle()
	if not activated then warn("TickManagerService inactive!") return false end
	if connection then TickManagerService.Disable() else TickManagerService.Enable() end
end

function TickManagerService:Start()
	activated = true
	TickManagerService.Enable()	
end

return TickManagerService
