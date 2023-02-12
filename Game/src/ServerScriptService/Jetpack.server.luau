--Author: Styx

local JetpackEvent = game.ReplicatedStorage.Events.Jetpack
local Electricity = require(game.ServerScriptService.Packages.Electricity.Interface)

function JetpackConsume(Player, amount)
	if not (amount > 0) then return end --Exploit
	Electricity.Pull(Player.Character.Backpack, amount)
end

JetpackEvent.OnServerEvent:Connect(JetpackConsume)