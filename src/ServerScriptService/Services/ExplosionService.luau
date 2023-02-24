-- Author: 4812571, Hexcede

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local StructureUtil = require(ReplicatedStorage.StructureUtility)
local Destruction = require(ServerScriptService.Services.DamageService)

local ExplosionService = {}

local collider = Instance.new("Part")
collider.Shape = Enum.PartType.Ball
collider.Transparency = 1
collider.CanCollide = false
collider.Anchored = true
collider.Touched:Connect(function() end)

local DEBUG = false
local ExplosionForceConstant = 5000

local function CreateDebugPart(position, brickColor)
	if not DEBUG then return end
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position
	if brickColor then part.BrickColor = brickColor end
	part.Parent = workspace.Effects
end

local function ApplyKnockback(part, direction, force)
	local bodyForce = Instance.new("BodyForce")
	bodyForce.Force = direction.Unit * force
	bodyForce.Parent = part
	Debris:AddItem(bodyForce, 0.05)
end

local function getHitParts()
	collider.Parent = workspace.Effects 
	local hitParts = collider:GetTouchingParts()
	collider.Parent = nil
	return hitParts
end

local function roundPercent(n)
	return math.ceil(n * 100) / 100
end

local function getDamageMultiplier(distance, radius)
	local distanceFactor = roundPercent(math.clamp(distance / radius, 0, 1))
	return 1 - distanceFactor
end

local function getDistance(model, position)
	local closest, closestDistance
	for _, v in model:GetDescendants() do
		if not v:IsA("BasePart") then continue end
		local origin, direction = position, v.Position - position
		local safetyOffset = (direction.Unit * 2) -- Prevents surface rays from tunneling through block
		origin = position - safetyOffset
		direction = direction + safetyOffset
		local ray = Ray.new(origin, direction)
		local resultPart, resultPosition = workspace:FindPartOnRayWithWhitelist(ray, {model})
		CreateDebugPart(position, BrickColor.new("Neon orange"))
		CreateDebugPart(origin, BrickColor.new("Bright blue"))
		CreateDebugPart(origin + direction, BrickColor.new("Lime green"))
		if not resultPart then continue end
		CreateDebugPart(resultPosition, BrickColor.new("Really red"))
		local distance = (resultPosition - position).Magnitude
		if not closest then v = closest closestDistance = distance end
		if distance < closestDistance then v = closest closestDistance = distance end
	end
	return closestDistance or math.huge
end

function ExplosionService.Explode(position, radius, damage)
	-- Create the explosion
	local explosion = Instance.new("Explosion")
	explosion.Position = position
	explosion.BlastRadius = radius
	explosion.DestroyJointRadiusPercent = 0
	explosion.BlastPressure = 0
	
	-- Position Collider
	collider.Size = Vector3.new(1, 1, 1) * (radius * 2)
	collider.Position = position
	
	local modelCache = {}
	if radius > 0 and damage > 0 then
		-- Get Hit Models
		for _, part in pairs(getHitParts()) do
			local model = StructureUtil.GetModel(part)
			if model then modelCache[model] = true end
		end
		
		-- Models
		for v, _ in pairs(modelCache) do
			if not v.Parent then continue end
			if v.Name == "Shield" then continue end
			local distance = getDistance(v, position)
			local blastDamage = damage * getDamageMultiplier(distance, radius)
			if not v.PrimaryPart then error(v.Name.. " has no primarypart!") end
			ApplyKnockback(v.PrimaryPart, v.PrimaryPart.Position - position, blastDamage * ExplosionForceConstant)
			Destruction.Damage(v, blastDamage, "Explosive")
		end
		
		-- Players
		for _, v in Players:GetPlayers() do
			if not (v.Character and v.Character:FindFirstChild("HumanoidRootPart")) then continue end
			local distance = (v.Character.HumanoidRootPart.Position - position).Magnitude
			local blastDamage = damage * getDamageMultiplier(distance, radius)
			v.Character.Humanoid:TakeDamage(blastDamage)
			ApplyKnockback(v.Character.HumanoidRootPart, v.Character.Head.Position - position, blastDamage * ExplosionForceConstant)
		end
	end
	explosion.Parent = workspace.Effects
end

return ExplosionService