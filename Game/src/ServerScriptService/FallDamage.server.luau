-- Author: Styx

local ReplicatedStorage = game:GetService("ReplicatedStorage")



local FallEvent = ReplicatedStorage.Events.Damage

function DamagePlayer(Player, amount)
	local humanoid = Player.Character:FindFirstChild("Humanoid")
	if humanoid then humanoid:TakeDamage(math.abs(amount)) end
end

FallEvent.OnServerEvent:Connect(DamagePlayer)