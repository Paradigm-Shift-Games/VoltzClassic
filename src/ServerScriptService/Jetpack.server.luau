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

JetpackEvent.OnServerEvent:Connect(JetpackConsume)