--Author: Styx

local FallEvent = game.ReplicatedStorage.Events.Damage

function DamagePlayer(Player, amount)
	local humanoid = Player.Character:FindFirstChild("Humanoid")
	if humanoid then humanoid:TakeDamage(math.abs(amount)) end
end

FallEvent.OnServerEvent:Connect(DamagePlayer)