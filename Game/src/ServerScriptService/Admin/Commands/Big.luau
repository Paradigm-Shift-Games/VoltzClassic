big = false

local function Command(player, parameter, target)
	if not target then print("Cannot Resize Player: No target specified!") return end
	
	local character = target.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local jetpack = character:WaitForChild("Backpack")
	
	if not big then
		big = true
		humanoid:FindFirstChild("HeadScale").Value = 10
		humanoid:FindFirstChild("BodyDepthScale").Value = 10
		humanoid:FindFirstChild("BodyHeightScale").Value = 10
		humanoid:FindFirstChild("BodyWidthScale").Value = 10
		humanoid:FindFirstChild("BodyTypeScale").Value = 10
		humanoid.WalkSpeed = 50
		humanoid.JumpPower = 100
		humanoid.MaxHealth = 10^3
		humanoid.Health = humanoid.MaxHealth
		character:FindFirstChild("FallDamage").Disabled = true
	else
		big = false
		humanoid:FindFirstChild("HeadScale").Value = 1
		humanoid:FindFirstChild("BodyDepthScale").Value = 1
		humanoid:FindFirstChild("BodyHeightScale").Value = 1.05
		humanoid:FindFirstChild("BodyWidthScale").Value = 1
		humanoid:FindFirstChild("BodyTypeScale").Value = 0
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 32
		humanoid.MaxHealth = character.Upgrades.Health.Value
		humanoid.Health = humanoid.MaxHealth
		character:FindFirstChild("FallDamage").Disabled = false
	end
		
	humanoid.Died:Connect(function()
		big = false
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 32
		character:FindFirstChild("FallDamage").Disabled = false
	end)		
end

return Command