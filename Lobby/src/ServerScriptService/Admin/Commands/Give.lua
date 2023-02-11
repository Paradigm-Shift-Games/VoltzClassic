local Weapons = {}

function parseString(str)
	return (str:lower()):gsub(" ", "")
end

for _, v in pairs(game.ReplicatedStorage.Guns:GetChildren()) do
	Weapons[parseString(v.Name)] = v
end

local function findPlayerFromPartialName(partial)
	if game.Players:FindFirstChild(partial) then return game.Players[partial] end

	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:match("^" .. partial) then return player end
	end

	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:lower():match("^" .. partial:lower()) then return player end
	end

	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:lower():gmatch(partial:lower()) then return player end
	end
end

function GiveWeapon(player, weaponString)
	local weapon = Weapons[parseString(weaponString)]
	print(weapon:GetFullName())
	if not weapon then warn("Invalid Weapon!") return end
	weapon = weapon:Clone()
	weapon.Parent = player.Backpack
end

local function Command(player, parameters)
	local target
	if not parameters[2] then target = player
	else target = findPlayerFromPartialName(parameters[1]) end

	GiveWeapon(target, table.concat(parameters, " "))
end

return Command