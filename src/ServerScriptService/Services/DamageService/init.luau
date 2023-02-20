-- Author: 4812571

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DamageTypes = require(script.DamageTypes)
local DamageEffects = require(script.DamageEffects)
local Stats = require(ReplicatedStorage.Stats.Structure)
local StructureUtil = require(ReplicatedStorage.StructureUtility)
local CleanupService = require(ServerScriptService.Services.CleanupService)
local AssemblyService = require(ServerScriptService.Services.AssemblyService)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)

local module = {}

local DamageFactorsByBodyPart = {
    Head = 2, 
    UpperTorso = 1.1, 
    LowerTorso = 0.9, 
    RightUpperArm = 0.7, 
    RightLowerArm = 0.7, 
    RightHand = 0.7, 
    LeftUpperArm = 0.7, 
    LeftLowerArm = 0.7, 
    LeftHand = 0.7, 
    RightUpperLeg = 0.8, 
    RightLowerLeg = 0.8, 
    RightFoot = 0.8, 
    LeftUpperLeg = 0.8, 
    LeftLowerLeg = 0.8, 
    LeftFoot = 0.8
}

function GetHealthValue(Object)
	local ValueNames = {"ShieldPower", "Health", "Resource"}
	for _, v in pairs(ValueNames) do
		if Object:FindFirstChild(v) then return Object[v] end
	end
end

local function GetHumanoidFromPart(part)
  if part == nil then return nil end
  local hum = part:FindFirstChild("Humanoid")
  if hum then return hum end
  return GetHumanoidFromPart(part.Parent)
end

function GetModelType(Object)
	if CollectionService:HasTag(Object, "Crystal") then return "Crystal" end
	if CollectionService:HasTag(Object, "Terrain") then return "Terrain" end
	if CollectionService:HasTag(Object, "Blueprint") then return "Blueprint" end
	if CollectionService:HasTag(Object, "Structure") then return "Structure" end
	if Object.Name == "Shield" then return "Shield" end
end

function GetDamageFactor(damageType, damagingType)
	if not damageType and damagingType then return 1 end
	if not DamageTypes[damageType] then warn("Invalid damage type "..tostring(damageType)) return 1 end
	if not DamageTypes[damageType][damagingType] then warn("Invalid damaging type "..tostring(damagingType)) return 1 end
	return DamageTypes[damageType][damagingType]
end

function module.Damage(instance, damage, damageType)
	--print("Damaging", instance, damage, damageType)
	if not (damage < 0 or damage == 0 or damage > 0) then warn("Illegal damage value") end
	
	local humanoid = GetHumanoidFromPart(instance)
	local model = StructureUtil.GetModel(instance)
	
	--Player
	if humanoid then
		humanoid:TakeDamage(damage * (DamageFactorsByBodyPart[instance.Name] or 0.8)) return
	end
	
	--Structure
	if model then
		if CollectionService:HasTag(model, "Invincible") then print("Haha you can't kill me | Tell 4812571 if you see this!") return end
		local isMerged = AssemblyService.getAttachmentType(model) == "Merge"
		local damaging = isMerged and AssemblyService.getRoot(model) or model
		local modelType = GetModelType(damaging)
		damage = damage * GetDamageFactor(damageType, modelType)
		
		--Explosion
		if isMerged and damageType == "Explosive" then print("Handled") return end
		
		--Damage
		if CollectionService:HasTag(damaging, "Blueprint") or CollectionService:HasTag(damaging, "Crystal") then
			Electricity.Pull(damaging, damage, true)
		else
			local health = damaging.Health
			if health.Value <= damage then module.Destroy(damaging) return end
			health.Value -= damage
			
			--Effects
			if CollectionService:HasTag(damaging, "Structure") then
				local health = health.Value
				local maxHealth = Stats[damaging.Name].Health
				
				DamageEffects.Update(damaging, health, maxHealth)
				for v, _ in pairs(AssemblyService.getAttachments(damaging)) do
					if CollectionService:HasTag(v, "Structure") then DamageEffects.Update(damaging, health, maxHealth) end
				end
			end
		end
	end
end

function Destroy(Object)
	if not Object.Parent then return end
	
	--Clean Connectors
	for _, v in pairs(Object:GetChildren()) do
		if v.Name == "Snaps" or v.Name == "Connectors" then
			for _, g in pairs(v:GetChildren()) do
				if g.Object.Value then g.Object.Value.Object.Value = nil end
			end
		end
	end
	
	--Clean Upgrades
	if CollectionService:HasTag(Object, "Blueprint") and CollectionService:HasTag(Object, "Upgrade") then
		Object.UpgradeRoot.Value.Upgrading:Destroy()
		Object.UpgradeRoot.Value.UpgradeState.Value -= 1
	end
	
	--Clean Tags
	for _, v in ipairs(CollectionService:GetTags(Object)) do CollectionService:RemoveTag(Object, v) end
	
	CleanupService.Clean(Object)
	Object:Destroy()
end

function module.Destroy(Object)
	local isRoot = AssemblyService.isRoot(Object)
	if isRoot then
		for v, _ in pairs(AssemblyService.getAttachments(Object)) do Destroy(v) end
	end
	Destroy(Object)
end

return module
