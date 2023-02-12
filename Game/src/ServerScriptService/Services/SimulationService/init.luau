-- Author: 4812571

local ServerScriptService = game:GetService("ServerScriptService")

local TimerService = require(ServerScriptService.Services.TimerService)





local module = {}
local Modules = {}


for _, v in pairs(script:GetChildren()) do
	Modules[v.Name] = require(v)
end


module.Run = function(delta)
	for name, mod in pairs(Modules) do
		if mod.Run then
			TimerService.Start("Simulation "..name)
			mod.Run(delta)
			TimerService.Record("Simulation "..name)
		end
	end
end

return module