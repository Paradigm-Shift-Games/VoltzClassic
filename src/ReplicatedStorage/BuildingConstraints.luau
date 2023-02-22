local module = {}

local Constraints = {}
local WireMinAngle = 35
local WireMaxDistance = 35
local MaxHeight = 300
local MaxDistance = 35

function GetCharacters()
	local characters = {}
	local players = game.Players:GetPlayers()
	for _, v in pairs(players) do table.insert(characters, v.Character) end
	return characters
end

function Angle(A, B, Center)
    local a = Center - A
    local b = Center - B
    return math.acos(a.Unit:Dot(b.Unit))
end

function GetTouchingParts(part)
	local connection = part.Touched:Connect(function() end)
	local touching = part:GetTouchingParts()
	connection:Disconnect()
	return touching
end

function IsTouching(part, IgnoreTables)
	local ignoredNames = {"Snap", "DisabledSnap", "CollisionIgnore", "ShieldDome", "WeldPad"}
	local ignored = {}
	ignored[part] = true
	for _, v in pairs(IgnoreTables) do
		for _, g in pairs(v) do
			if g:IsA("BasePart") then ignored[g] = true end
			for _, j in pairs(g:GetDescendants()) do
				if j:IsA("BasePart") then ignored[j] = true end
			end
		end		
	end
	for _, v in pairs(GetTouchingParts(part)) do
		if not ignored[v] and not v:IsDescendantOf(workspace.Effects) and not table.find(ignoredNames, v.Name) then if game["Run Service"]:IsServer() then v.BrickColor = BrickColor.new("Really red") end --[[print("Touching", v.Name)]] return true end
	end
	return false
end

module.Add = function(Structure, Player)
	Constraints[Structure] = {Player = Player}
	local constraint = Constraints[Structure]
	if Structure:FindFirstChild("Region", true) then 	
		constraint.Regions = {}
		if Structure.Name == "Wire" and Structure:FindFirstChild("WireCylinder") then table.insert(constraint.Regions, Structure.WireCylinder) end
		for _, v in pairs(Structure:GetDescendants()) do
			if v.Name == "Region" and v:IsA("Folder") then
				for _, g in pairs(v:GetChildren()) do
					table.insert(constraint.Regions, g)
				end
			end
		end
	end
	
	-- Force Snap
	if Structure:FindFirstChild("ForceSnap") then
		constraint.ForceSnap = true
	end
	
	-- Wire Angle/Distance
	if Structure.Name == "Wire" and Structure:FindFirstChild("WireCylinder") then
		constraint.Wire = true
	end
end

module.Check = function(Structure, Attached)
	local constraint = Constraints[Structure]
	
	-- Distance
	if constraint.Player ~= "Server" then
		if (Structure.PrimaryPart.Position - constraint.Player.Character.PrimaryPart.Position).Magnitude > MaxDistance then return false end
	end
	
	-- Regions
	if constraint.Regions then
		local isVoidStructure = (Structure.Parent == nil)
		for _, v in pairs(constraint.Regions) do
			local part
			if isVoidStructure then
				part = v:Clone()
				part.Parent = workspace
			else
				part = v
			end
			local failed = IsTouching(part, {constraint.Regions, {Structure}, GetCharacters(), Attached})
			if isVoidStructure then part:Destroy() end
			if failed then return false end
		end
	end
	
	-- Force Snap
	if constraint.ForceSnap then
		if not (Attached and #Attached > 0) then 
			return false
		end
	end
	
	-- Wire Angle/Distance
	if constraint.Wire then
		for _, v in pairs(Structure:GetChildren()) do
			if v.Name == "Wire" then
				local angle = Angle(v.PrimaryPart.Position + v.PrimaryPart.CFrame.RightVector, Structure.WireCylinder.Position, v.PrimaryPart.Position)
				if math.deg(angle) < WireMinAngle then return false end
			end
		end
		if Structure.WireCylinder.Size.X > WireMaxDistance then return false end
	end
	
	-- Height
	if Structure.PrimaryPart.Position.Y > MaxHeight then
		return false
	end
	
	return true
end

module.Clear = function(Structure, Attached)
	
	local constraint = Constraints[Structure]
	
	-- Regions
	if constraint.Regions then
		if Structure.Name == "Wire" then table.remove(constraint.Regions, table.find(constraint.Regions, Structure:FindFirstChild("WireCylinder"))) end
		for _, v in pairs(constraint.Regions) do
			v:Destroy()
		end
	end
	
	-- Force Snap
	if constraint.ForceSnap then Structure.ForceSnap:Destroy() end
end

return module