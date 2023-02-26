-- Author: Styx

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Electricity = require(ServerScriptService.Packages.Electricity.Interface)

local JetpackEvent = ReplicatedStorage.Events.Jetpack

function JetpackConsume(Player, amount)
	if amount > 0 then
		return
	end

	Electricity.Pull(Player.Character.Backpack, amount)
end

local JetpackService = {}

function JetpackService:Start()
	JetpackEvent.OnServerEvent:Connect(JetpackConsume)
end

return JetpackService