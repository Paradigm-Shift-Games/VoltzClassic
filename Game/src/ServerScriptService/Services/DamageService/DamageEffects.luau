local ServerScriptService = game:GetService("ServerScriptService")

local CleanupService = require(ServerScriptService.Services.CleanupService)

local DamageLevels = {0.75, 0.50, 0.30}

local EffectTypes = {"Cracks", "Sparks", "Fire"}
local IgnoredNames = {"Snap"}
local DamageStates = {}

local module = {}



local function FindPoint(Structure)
	local function CanHit(part)
		if not part:IsDescendantOf(Structure) then return false end
		if part:IsDescendantOf(workspace.Effects) then return false end
		if table.find(IgnoredNames, part.Name) then return false end
		return true
	end

	local dx = ((math.random() - 0.5) * 100)
	local dy = ((math.random() - 0.5) * 100)
	local dz = ((math.random() - 0.5) * 100)

	local startPoint = Structure.PrimaryPart.Position + Vector3.new(dx, dy, dz)
	local endPoint = Structure.PrimaryPart.Position - Vector3.new(dx, dy, dz)

	local direction = endPoint - startPoint

	local params = RaycastParams.new()
	local blacklist = {}
	params.FilterDescendantsInstances = blacklist
	params.FilterType = Enum.RaycastFilterType.Blacklist

	while true do
		local result = workspace:Raycast(startPoint, direction, params)
		if not result then return nil end
		if CanHit(result.Instance) then
			return result.Position
		else
			table.insert(blacklist, result.Instance)
			params.FilterDescendantsInstances = blacklist
		end
	end
end

local EffectData = {
	[1] = {};
	[2] = {};
	[3] = {};
}

local AddEffect = {
	[1] = function(Structure)
		print("Adding Effect: 1")
		DamageStates[Structure][1] = true
		CleanupService.Reserve(Structure, "DamageEffects")
		for _, v in ipairs(Structure:GetDescendants()) do
			if v:IsA("BasePart") and not table.find(IgnoredNames, v.Name) then 
				for _, g in ipairs(script.Cracks:GetChildren()) do g:Clone().Parent = v end
			end
		end
	end;
	
	[2] = function(Structure)
		print("Adding Effect: 2")
		DamageStates[Structure][2] = true
		CleanupService.Reserve(Structure, "DamageEffects")
		EffectData[2][Structure] = {}
		for i = 1, 15 do
			local point = FindPoint(Structure)
			if not point then continue end
			local effect = script.Sparks:Clone()
			effect.Position = point
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = effect
			weld.Part1 = Structure.PrimaryPart
			weld.Parent = effect
			effect.Parent = workspace.Effects
			table.insert(EffectData[2][Structure], effect)
		end
	end;
	
	[3] = function(Structure)
		print("Adding Effect: 3")
		DamageStates[Structure][3] = true
		CleanupService.Reserve(Structure, "DamageEffects")
		EffectData[3][Structure] = {}
		for i = 1, 15 do
			local point = FindPoint(Structure)
			if not point then continue end
			local effect = script.Fire:Clone()
			effect.Position = point
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = effect
			weld.Part1 = Structure.PrimaryPart
			weld.Parent = effect
			effect.Parent = workspace.Effects
			table.insert(EffectData[3][Structure], effect)
		end
	end;
}

local RemoveEffect = {
	[1] = function(Structure)
		print("Removing Effect: 1")
		DamageStates[Structure][1] = false
		for _, v in pairs(EffectData[1][Structure] or {}) do
			if v.Parent then v:Destroy() end
		end
	end;

	[2] = function(Structure)
		print("Removing Effect: 2")
		DamageStates[Structure][2] = false
		for _, v in pairs(EffectData[2][Structure] or {}) do
			v:Destroy()
		end
	end;

	[3] = function(Structure)
		print("Removing Effect: 3")
		DamageStates[Structure][3] = false
		for _, v in pairs(EffectData[3][Structure] or {}) do
			v:Destroy()
		end
	end;
}

local function CalculateDamageLevel(health, maxHealth)
	local percent = health / maxHealth
	local damageLevel = 0
	for i, v in ipairs(DamageLevels) do
		if percent < v then damageLevel = i else return damageLevel end
	end
	return damageLevel
end

module.Update = function(Structure, health, maxHealth)
	local damageLevel = CalculateDamageLevel(health, maxHealth) 
	if not DamageStates[Structure] then DamageStates[Structure] = {} end
	
	
	for i = 1, 3 do
		if damageLevel >= i then
			if not DamageStates[Structure][i] then AddEffect[i](Structure) end
		else
			if DamageStates[Structure][i] then RemoveEffect[i](Structure) end
		end
	end
	
	if damageLevel == 0 then end
end

module.Clean = function(Structure)
	for i = 1, 3 do if DamageStates[Structure][i] then RemoveEffect[i](Structure) end end
end

CleanupService.Bind("DamageEffects", module.Clean)

return module
