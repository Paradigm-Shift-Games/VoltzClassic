-- Author: Styx

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Electricity = require(ServerScriptService.Packages.Electricity.Interface)

local JetpackEvent = ReplicatedStorage.Events.Jetpack

function JetpackConsume(Player, amount)
	if not (amount > 0) then return end --Exploit
	Electricity.Pull(Player.Character.Backpack, amount)
end

JetpackEvent.OnServerEvent:Connect(JetpackConsume)