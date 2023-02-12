-- Author: Hexcede

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local StructureUtil = require(ReplicatedStorage.StructureUtility)
local Destruction = require(ServerScriptService.Services.DamageService)

local module = {}

local raycastParams = RaycastParams.new() -- Create a RaycastParams object
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist -- Set the filter mode to whitelist

local collider = Instance.new("Part")
collider.Shape = Enum.PartType.Ball
collider.Transparency = 1
collider.CanCollide = false
collider.Anchored = true
collider.Touched:Connect(function() end)

module.Explode = function (position, radius, damage)
	local DEBUG = true
	local SELF_BLOCK = true -- Will the explosion block parts from getting hit more than once by the same explosion?
	local explosionTime = 0 -- How long to allow the explosion to "last"? (Before damage is applied) 
	local cleanupTime = 30 -- Debug cleanup
	
	-- Create the explosion
	local explosion = Instance.new("Explosion")
	explosion.Position = position
	explosion.BlastRadius = radius
	explosion.DestroyJointRadiusPercent = 0
	explosion.BlastPressure = 0 -- Do not apply explosion force
	
	collider.Size = Vector3.new(1, 1, 1) * (radius * 2)
	collider.Position = position
	local function getHitParts()
		collider.Parent = workspace
		local hitParts = collider:GetTouchingParts()
		collider.Parent = nil
		return hitParts
	end
	
	local modelDamage = {}
	local partCache = {}
	-- On hit
	--explosion.Hit:Connect(function(part)
	for _, part in ipairs(getHitParts()) do
		if SELF_BLOCK and partCache[part] then continue end
		local model = StructureUtil.GetModel(part)
		if not model then continue end
		
		modelDamage[model] = modelDamage[model] or {
			DamageSum = 0,
			DamageCount = 0
		}
		
		-- Put model into filter
		raycastParams.FilterDescendantsInstances = {model}
		-- Perform cast
		local origin = explosion.Position
		local direction = part.Position - explosion.Position
		local raycastResult = workspace:Raycast(origin, direction, raycastParams)
		
		if not raycastResult then
			continue
		end
		
		partCache[raycastResult.Instance] = true -- Mark the hit part as seen
		
		-- Calculate damage
		local rayDistance = (raycastResult.Position - origin).Magnitude
		local damageMultiplier = math.clamp(1 - rayDistance/radius, 0, 1) -- Clamp for the sake of ensuring damage isnt somehow negative
		
		-- Calculate new damage
		local blastDamage = damage * damageMultiplier
		
		modelDamage[model].DamageSum += blastDamage
		modelDamage[model].DamageCount += 1
		
		if DEBUG then
			do -- Ray indicator
				local rayIndicator = Instance.new("Part")
				
				rayIndicator.Size = Vector3.new(0.1, 0.1, rayDistance)
				rayIndicator.Material = Enum.Material.ForceField
				rayIndicator.Color = Color3.new(0.1, 0.1, 0.1)
				rayIndicator.CanCollide = false
				rayIndicator.CastShadow = false -- Disable shadows for ShadowMap and beyond
				rayIndicator.CFrame = CFrame.new(origin/2 + raycastResult.Position/2, raycastResult.Position)
				rayIndicator.Anchored = true
				
				rayIndicator.Name = "PointIndicator_"..raycastResult.Instance.Name
				
				rayIndicator.Parent = workspace.Effects
				
				coroutine.wrap(function()
					wait(cleanupTime)
					
					rayIndicator:Destroy()
					rayIndicator = nil
				end)()
			end
			
			do -- Hit point indicator
				local pointIndicator = Instance.new("Part")
				
				pointIndicator.Shape = Enum.PartType.Ball
				pointIndicator.Size = Vector3.new(0.2, 0.2, 0.2)
				pointIndicator.Material = Enum.Material.ForceField
				pointIndicator.Color = Color3.new(0.1, 0.1, 0.1)
				pointIndicator.CanCollide = false
				pointIndicator.CastShadow = false -- Disable shadows for ShadowMap and beyond
				pointIndicator.CFrame = CFrame.new(raycastResult.Position)
				pointIndicator.Anchored = true
				
				pointIndicator.Name = "PointIndicator_"..raycastResult.Instance.Name
				
				pointIndicator.Parent =	workspace
				
				coroutine.wrap(function()
					wait(cleanupTime)
					
					pointIndicator:Destroy()
					pointIndicator = nil
				end)()
			end
			
			do -- Hit part indicator
				-- Clone the object (and ensure it is clonable)
				local archivable = raycastResult.Instance.Archivable
				raycastResult.Instance.Archivable = true
				local indicator = raycastResult.Instance:Clone()
				raycastResult.Instance.Archivable = archivable
				
				if not indicator then
					-- Failed to clone still
					continue
				end
				
				indicator.Material = Enum.Material.ForceField
				indicator.Size *= 1.05
				indicator.Color = Color3.new(1, 0.5, 0)
				indicator.CanCollide = false
				indicator.CastShadow = false -- Disable shadows for ShadowMap and beyond
				indicator.Anchored = true
				
				-- Ensure that unions can be colored
				if indicator:IsA("PartOperation") then
					indicator.UsePartColor = true
				end
				
				indicator.Name = "HitIndicator_"..indicator.Name
				
				indicator.Parent = workspace.Effects
				
				coroutine.wrap(function()
					wait(cleanupTime)
					
					indicator:Destroy()
					indicator = nil
				end)()
			end
		end
	end
	explosion.Parent = workspace.Effects
	if DEBUG then
		local blastIndicator = Instance.new("Part")
		blastIndicator.Shape = Enum.PartType.Ball
		blastIndicator.Size = Vector3.new(1, 1, 1) * (radius * 2)
		blastIndicator.Material = Enum.Material.ForceField
		blastIndicator.Color = Color3.new(1, 1, 1)
		blastIndicator.CanCollide = false
		blastIndicator.CastShadow = false -- Disable shadows for ShadowMap and beyond
		blastIndicator.CFrame = CFrame.new(explosion.Position)
		blastIndicator.Anchored = true
		blastIndicator.Name = "BlastIndicator"
		blastIndicator.Parent =	workspace.Effects
		coroutine.wrap(function()
			wait(cleanupTime)
			blastIndicator:Destroy()
			blastIndicator = nil
		end)()
	end	
	-- Apply damage
	for model, data in pairs(modelDamage) do
		if data.DamageCount == 0 then continue end
		local blastDamage = data.DamageSum / data.DamageCount
		Destruction.Damage(model, blastDamage, "Explosive")
	end
end

return module