local Weapons = {}

function parseString(str)
	return (str:lower()):gsub(" ", "")
end

for _, v in pairs(game.ReplicatedStorage.Guns:GetChildren()) do
	Weapons[parseString(v.Name)] = v
end

function GiveWeapon(player, weaponString)
	local weapon = Weapons[parseString(weaponString)]
	print(weapon:GetFullName())
	if not weapon then warn("Invalid Weapon!") return end
	weapon = weapon:Clone()
	weapon.Parent = player.Backpack
end

local function Command(player, parameters, target)
	if target then
		GiveWeapon(target, table.concat(parameters, " "))
	else
		GiveWeapon(player, table.concat(parameters, " "))
	end
end

return Command