-- Author: Styx

local ReplicatedStorage = game:GetService("ReplicatedStorage")



local DamageEvent = ReplicatedStorage.Events.Damage
local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local MaxFallDistance = 75

local function RemoveVelocity(Model)
	for _, Part in pairs(Model:GetChildren()) do
		if Part:IsA("BasePart") then
			Part.Velocity = Vector3.new()
		elseif Part:IsA("Accessory") then
			local Handle = Part:FindFirstChild("Handle")
			if Handle then
				Handle.Velocity = Vector3.new()
			end
		end
	end
end

local function OnHumanoidStateChanged(OldState, NewState)
	if NewState == Enum.HumanoidStateType.Landed then
		local YVelocity = HumanoidRootPart.Velocity.Y
		if YVelocity < -MaxFallDistance then
			local FallDamage = (-YVelocity - MaxFallDistance) * 5
			DamageEvent:FireServer(FallDamage)
			RemoveVelocity(Character)
		end
	end
end

Humanoid.StateChanged:Connect(OnHumanoidStateChanged)