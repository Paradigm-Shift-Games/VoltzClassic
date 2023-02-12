local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Electricity = require(ServerScriptService.Packages.Electricity.Interface)


local Charging = {}

RunService.Heartbeat:Connect(function(dt)
	for player, _ in pairs(Charging) do
		if not player or not player.Character or not player.Character:FindFirstChild("Backpack") then continue end
		Electricity.Push(player.Character.Backpack, math.huge, true)
	end
end)

local function Command(player, parameters, target)
	if not target then print("Cannot add to charge list: No target player specified!") return end
	local targetPlayer = game.Players:WaitForChild(tostring(target))
	if not targetPlayer then print("Cannot add to charge list: Target player specified not present!") return end
	
	Charging[targetPlayer] = Charging[targetPlayer] and nil or true
end

return Command