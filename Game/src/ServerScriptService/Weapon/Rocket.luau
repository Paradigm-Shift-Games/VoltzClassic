local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local MouseData = require(ServerScriptService.MouseData)
local DamageService = require(ServerScriptService.Services.DamageService)
local ExplosionService = require(ServerScriptService.Services.ExplosionService)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)
local ProjectileService = require(ServerScriptService.Services.ProjectileService)




local function Explode(projectileData)
	local hit = projectileData.Hit
	local projectileStats = projectileData.parameters.stats
	if hit and hit.Name == "ShieldDome" then
		print("Shield!")
		ExplosionService.Explode(projectileData.directions[1], 0, 0)
		DamageService.Damage(hit, projectileStats.Damage)
	end
	ExplosionService.Explode(projectileData.directions[1], projectileStats.BlastRadius, projectileStats.Damage)
	projectileData.projectile:Destroy()
end

local function Rocket(weapon, weaponStats, weaponData)
	if weaponStats.Consumption and not RunService:IsStudio() then
		if Electricity.GetCharge(weaponData.Owner.Character.Backpack) < weaponStats.Consumption then
			return false
		else
			Electricity.Pull(weaponData.Owner.Character.Backpack, weaponStats.Consumption)	
		end
	end
	local FireAttachment = weapon:FindFirstChild("FirePos", true)
	local barrelPosition = FireAttachment.WorldPosition
	local _, targetPosition = MouseData.GetMouse(weaponData.Owner)
	local targetDirection = (targetPosition - barrelPosition).Unit
	
	local directions = {barrelPosition, targetDirection * weaponStats.InitialSpeed}
	local parameters = {owner = weaponData.Owner, stats = weaponStats}
	
	local projectile = ProjectileService.New(weaponStats.Projectile, directions, parameters)
	ProjectileService.Bind(projectile, Explode)
	if weaponStats.ThrustTime and weaponStats.ThrustTime > 0 then
		coroutine.wrap(function() wait(weaponStats.ThrustTime) ProjectileService.Influence(projectile, {0, 0, Vector3.new(0, -workspace.Gravity, 0)}) end)()
	end
	return true
end

return Rocket
