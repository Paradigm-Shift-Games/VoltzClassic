-- Author: 4812571


--[[Code Audit: 1/1/2021, 4812571

Storing PartData is done in many places. Perhaps a LogPartData(part) function
would be more efficient.

Reverting PartData is done in many places. Perhaps a RevertPartData(part) function
would be more efficient.

LINES:

structureData[v] = {}
local partData = data[Structure][v]	
partData.Color = (v.Name == "TeamColor" and teamColor) or v.Color
partData.Transparency = v.Transparency
partData.CanCollide = v.CanCollide
v.Color = Color3.fromRGB(11, 11, 11)
v.Transparency = 0.7
v.CanCollide = false

structureData[v] = {}
local partData = data[Structure][v]	
partData.Color = (v.Name == "TeamColor" and teamColor) or v.Color
partData.Transparency = v.Transparency
partData.CanCollide = v.CanCollide
v.Color = Color3.fromRGB(11, 11, 11)
v.Transparency = 0.7
v.CanCollide = false

for part, partData in pairs(data[Structure]) do
	part.Color = partData.Color
	part.Transparency = partData.Transparency
	part.CanCollide = partData.CanCollide
end

]]


local module = {}

data = {}

module.ColorAsBlueprint = function(Structure)
	data[Structure] = {}
	local teamColor = Structure:FindFirstChild("Team") and Structure.Team.Value.TeamColor.Color
	for _, v in pairs(Structure:GetDescendants()) do
		if v.Name == "DisabledSnap" then continue end
		local structureData = data[Structure]
		if v:IsA("BasePart") then
			structureData[v] = {}
			local partData = data[Structure][v]
			partData.Color = (v.Name == "TeamColor" and teamColor) or v.Color
			partData.Transparency = v.Transparency
			partData.CanCollide = v.CanCollide
			v.Color = Color3.fromRGB(11, 11, 11)
			v.Transparency = 0.7
			v.CanCollide = false
		end
	end
end

module.DebugColor = function(Structure, debugColor)
	if typeof(debugColor) == "BrickColor" then debugColor = debugColor.Color end
	data[Structure] = {}
	for _, v in pairs(Structure:GetDescendants()) do
		if v.Name == "DisabledSnap" then continue end
		local structureData = data[Structure]
		if v:IsA("BasePart") then
			structureData[v] = {}
			local partData = data[Structure][v]	
			partData.Color = v.Color
			v.Color = debugColor
		end
	end
end

module.UpdateBlueprintColor = function(Structure, charge, cost)
	local completion = charge / cost
	if not data[Structure] then warn("Attempt to color invalid structure!") return end
	for part, partData in pairs(data[Structure]) do
		part.Color = Color3.fromRGB(11, 11, 11):lerp(Color3.fromRGB(26, 125, 255), completion)
	end
end

module.ColorAsStructure = function(Structure)
	module.RevertColors(Structure)
	local teamColor = Structure:FindFirstChild("Team") and Structure.Team.Value.TeamColor.Color
	if not teamColor then return end
	for _, v in pairs(Structure:GetDescendants()) do
		if v:IsA("BasePart") and v.Name == "TeamColor" then
			v.Color = teamColor	
		end
	end
end

module.RevertColors = function(Structure)
	if not data[Structure] then return nil end
	for part, partData in pairs(data[Structure]) do
		part.Color = partData.Color
		part.Transparency = partData.Transparency
		part.CanCollide = partData.CanCollide
	end
	module.Clean(Structure)
end

module.ColorCharacter = function(character)
	local player = game.Players:GetPlayerFromCharacter(character)
	local teamColor = player.Team.TeamColor
	for _, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "Light" and v.Name ~= "Nozzle" then v.BrickColor = teamColor end
	end
end

module.Clean = function(Structure)
	data[Structure] = nil
end

return module
