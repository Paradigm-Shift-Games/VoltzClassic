--local DamageService = require(game.ServerScriptService.Services.DamageService)
local EffectService = require(game.ServerScriptService.Services.EffectService)
--local ResourceInteract = require(game.ServerScriptService.Services.ResourceInteract)
local MouseData = require(game.ServerScriptService.MouseData)
local RunService = game:GetService("RunService")

local function Raycast(player, bulletRay)
	local ignore = {player.Character}
	local part, position, normal
	while true do
		part, position, normal = workspace:FindPartOnRayWithIgnoreList(bulletRay, ignore)
		if part and part.Name == "ShieldDome" and part.Parent.Team.Value == player.Team then table.insert(ignore, part) continue end
		break
	end
	return part, position
end

local function SpreadHitscan(player, barrelPos, targetPos, range, spreadAngle)
	--Spread
	local targetCF = CFrame.new(barrelPos, targetPos)
	local rotationCF = CFrame.Angles(0, 0, math.pi * 2 * math.random())
	local translationCF = CFrame.Angles(math.rad(spreadAngle / 2) * math.random(), 0, 0)
	local spreadCF = targetCF * rotationCF * translationCF
	local bulletRay = Ray.new(barrelPos, spreadCF.LookVector * range)
	--Raycast
	return Raycast(player, bulletRay)
end

local function Bullet(weapon, weaponStats, weaponData)
	--if weaponStats.Consumption then
	--	if RunService:IsStudio() then
	--		weaponStats.Consumption = 0
	--	else
	--		if ResourceInteract.GetResource(weaponData.Owner.Character.Backpack) < weaponStats.Consumption then return false end
	--		ResourceInteract.Pull(weaponData.Owner.Character.Backpack, weaponStats.Consumption)
	--	end
	--end
	local FireAttachment = weapon:FindFirstChild("FirePos", true)
	local barrelPosition = FireAttachment.WorldPosition
	local _, targetPosition = MouseData.GetMouse(weaponData.Owner)
	local hitPart, hitPosition = SpreadHitscan(weaponData.Owner, barrelPosition, targetPosition, weaponStats.Range, weaponStats.Spread)
	EffectService.FireEffect("Bullet", FireAttachment, hitPosition, weaponStats.Effect)
	--DamageService.Damage(hitPart, weaponStats.Damage, weaponStats.DamageType)
	return true
end

return Bullet
