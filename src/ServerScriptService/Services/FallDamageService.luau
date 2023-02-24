local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FallEvent = ReplicatedStorage.Events.Damage

local FallDamageService = {}

function DamagePlayer(Player, amount)
	local humanoid = Player.Character:FindFirstChild("Humanoid")
	if humanoid then humanoid:TakeDamage(math.abs(amount)) end
end

function FallDamageService:Start()
    FallEvent.OnServerEvent:Connect(DamagePlayer)
end

return FallDamageService