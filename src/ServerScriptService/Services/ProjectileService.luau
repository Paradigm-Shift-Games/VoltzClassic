local module = {}

local Projectiles = {}

local CanHit = function(instance, parameters)
	if instance == nil then return true end
	if instance:IsDescendantOf(workspace.Effects) then return false end
	if parameters.owner and instance:IsDescendantOf(parameters.owner.Character) then return false end
	if instance.Name == "ShieldDome" and parameters.stats.ShieldPierce then return false end 
	if instance.Name == "ShieldDome" and parameters.owner.team == instance.parent.Team.Value then return false end
	return true
end

local Raycast = function(parameters, origin, direction)
	local newRay = Ray.new(origin, direction)
	local ignoreList = {}
	local hit, hitPosition, normal
	while true do
		hit, hitPosition, normal = workspace:FindPartOnRayWithIgnoreList(newRay, ignoreList)
		if CanHit(hit, parameters) then break end
		table.insert(ignoreList, hit)
	end
	return hit, hitPosition
end

function module.New(template, directions, parameters)
	local projectile = template:Clone()
	Projectiles[projectile] = {directions = directions, parameters = parameters, projectile = projectile}
	projectile:SetPrimaryPartCFrame(CFrame.new(directions[1], directions[1] + (directions[2] or Vector3.new(0,0,0)))) 
	projectile.Parent = workspace.Effects
	return projectile
end

function module.Influence(projectile, directionsDelta)
	if not Projectiles[projectile] then return end
	local directions = Projectiles[projectile].directions
	for i, v in ipairs(directionsDelta) do
		if v == 0 then v = Vector3.new(0, 0, 0) end
		if not directions[i] then directions[i] = v else directions[i] = directions[i] + v end
	end
end

function module.GetDirections(projectile)
	if not projectile then return false end
	return Projectiles[projectile].directions
end

function module.SetDirections(projectile, directions)
	if not projectile then return false end
	Projectiles[projectile].directions = directions
end

function module.Bind(projectile, func)
	Projectiles[projectile].connected = func
end

function module.Run(delta)
	for projectile, data in pairs(Projectiles) do
		local directions = data.directions
		local parameters = data.parameters
		for i = #directions, 2, -1 do
			directions[i - 1] = directions[i - 1] + (directions[i] * delta)
		end
		--local result = workspace:Raycast(projectile.PrimaryPart.Position, directions[1] - projectile.PrimaryPart.Position)
		local hit, position = Raycast(parameters, projectile.PrimaryPart.Position, directions[1] - projectile.PrimaryPart.Position)
		if hit then directions[1] = position end
		projectile:SetPrimaryPartCFrame(CFrame.new(directions[1], directions[1] + directions[2])) 
		if hit or directions[1].Magnitude > 1000 then --memory safety
			Projectiles[projectile].Hit = hit
			if Projectiles[projectile].connected then Projectiles[projectile].connected(Projectiles[projectile]) end
			Projectiles[projectile] = nil
		end
	end
end

return module
