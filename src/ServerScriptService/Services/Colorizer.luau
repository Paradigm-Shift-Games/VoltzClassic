-- Author: 4812571

local Players = game:GetService("Players")

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

local Colorizer = {}

data = {}

function Colorizer.ColorAsBlueprint(Structure)
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

function Colorizer.DebugColor(Structure, debugColor)
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

function Colorizer.UpdateBlueprintColor(Structure, charge, cost)
	local completion = charge / cost
	if not data[Structure] then warn("Attempt to color invalid structure!") return end
	for part, partData in pairs(data[Structure]) do
		part.Color = Color3.fromRGB(11, 11, 11):lerp(Color3.fromRGB(26, 125, 255), completion)
	end
end

function Colorizer.ColorAsStructure(Structure)
	Colorizer.RevertColors(Structure)
	local teamColor = Structure:FindFirstChild("Team") and Structure.Team.Value.TeamColor.Color
	if not teamColor then return end
	for _, v in pairs(Structure:GetDescendants()) do
		if v:IsA("BasePart") and v.Name == "TeamColor" then
			v.Color = teamColor	
		end
	end
end

function Colorizer.RevertColors(Structure)
	if not data[Structure] then return nil end
	for part, partData in pairs(data[Structure]) do
		part.Color = partData.Color
		part.Transparency = partData.Transparency
		part.CanCollide = partData.CanCollide
	end
	Colorizer.Clean(Structure)
end

function Colorizer.ColorCharacter(character)
	local player = Players:GetPlayerFromCharacter(character)
	local teamColor = player.Team.TeamColor
	for _, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "Light" and v.Name ~= "Nozzle" then v.BrickColor = teamColor end
	end
end

function Colorizer.Clean(Structure)
	data[Structure] = nil
end

return Colorizer
