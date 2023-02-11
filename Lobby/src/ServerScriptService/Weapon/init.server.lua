--Author: 4812571

local RunService = game:GetService("RunService")
local WeldServcice = require(game.ServerScriptService.Services.WeldService)
local ActionService = require(game.ServerScriptService.Services.ActionService)
local WeaponStats = require(game.ReplicatedStorage.Stats.Weapon)
local EquippedWeapon = {}
local FiringWeapons = {}
local WeaponData = {}
local Registeredweapons = {}
local FiringModes = {}

local function Getweapon(player)
	if player.Character == nil then return nil end
	for _, child in ipairs(player.Character:GetChildren()) do
		if child:IsA("Tool") then return child end
	end
end

local function GetStats(weapon)
	return WeaponStats[weapon.Name]
end

local function AttemptFire(weapon)
	local weaponStats = GetStats(weapon)
	local nextFireTime = WeaponData[weapon].LastFireTime + (1 / weaponStats.FireRate)
	local currentTime = tick()
	if currentTime >= nextFireTime then
		if not FiringModes[weaponStats.FireType] then warn("Weapon:", weapon.Name, "Invalid firing mode", weaponStats.FireType) end
		if FiringModes[weaponStats.FireType](weapon, weaponStats, WeaponData[weapon]) then
			WeaponData[weapon].LastFireTime = currentTime
		end
	end
end

local function OnEquip(player, weapon)
	if not WeaponData[weapon] then WeaponData[weapon] = {Owner = player, LastFireTime = tick()} end
	EquippedWeapon[player] = weapon
	print("Equipped", weapon.Name.."!")
end

local function OnUnequip(player, weapon)
	EquippedWeapon[player] = nil
	FiringWeapons[weapon] = nil
	print("Unequipped", weapon.Name.."!")
end

local function OnGunFire(player, state)
	local equippedweapon = EquippedWeapon[player]
	if not equippedweapon then return end
	local stats = GetStats(equippedweapon)
	if state == true then
		AttemptFire(equippedweapon)
		if stats.FireMode == "automatic" then FiringWeapons[equippedweapon] = true end
	else
		FiringWeapons[equippedweapon] = nil
	end
end

local function OnChildAdded(player, child)
	print("ChildAdded!")
	if child:IsA("Tool") and Registeredweapons[child] == nil then
		Registeredweapons[child] = true
		child.Equipped:Connect(function()
			OnEquip(player, child)
		end)
		child.Unequipped:Connect(function()
			OnUnequip(player, child)
		end)
	end
end

local function OnCharacterAdded(Char)
	local player = game.Players:GetPlayerFromCharacter(Char)
	Char.ChildAdded:Connect(function(child)
		OnChildAdded(player, child)
	end)
end

local function OnPlayerAdded(Player)
	Player.CharacterAdded:Connect(OnCharacterAdded)
end

local function Run(delta)
	for weapon, _ in pairs(FiringWeapons) do
		AttemptFire(weapon)
	end
end

for _, v in ipairs(script:GetChildren()) do FiringModes[v.Name] = require(v) end

for _, v in ipairs(game.ReplicatedStorage.Guns:GetChildren()) do WeldServcice.Unanchor(v) WeldServcice.WeldTool(v) end

for _, player in ipairs(game.Players:GetPlayers()) do OnPlayerAdded(player) end
game.Players.PlayerAdded:Connect(OnPlayerAdded)
	
RunService.Heartbeat:Connect(Run)
ActionService.Bind("GunFire", OnGunFire)