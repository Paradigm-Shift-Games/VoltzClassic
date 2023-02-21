-- Author: 4812571

local ServerScriptService = game:GetService("ServerScriptService")

local Matrix = require(script.Parent.Matrix)
local Supports = require(script.Parent.Support)
local Blueprint = require(ServerScriptService.Blueprint)
local Settings = require(script.Parent.Settings.selectedSettings.Value)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)

local StarterIsland = {}
local TeamIslands = {}
local Islands = {}
local generated = false

local function PlaceCrystal(Blocks)
	for _ = 1, 32 do
		local block = Blocks[math.random(1, #Blocks)]
		if not block.hasCrystal then
			block.hasCrystal = true
			Matrix.CreateCell(block.X, block.Z, 1, "Resource Crystal")
			return
		end
	end
end

function GetSafePart(island)
	local centerBlock = Islands[island].Center
	local centerPosition = Vector3.new(centerBlock.X, centerBlock.Y, centerBlock.Z) 
	local foundPositions = {}
	
	--Generate Positions
	while #foundPositions < 75 do
		local Blocks = Islands[island].Blocks
		local block = Blocks[math.random(1, #Blocks)]
		if (block.hasCrystal or block.isCenter) then continue end
		local results = workspace:Raycast(Vector3.new(block.X * 12, 10, block.Z * 12), Vector3.new(0, -10.5, 0))
		if results then
			local distance = (centerPosition - Vector3.new(block.X, 0, block.Z)).Magnitude
			table.insert(foundPositions, {result = results, distance = distance})
		end
		wait()
	end
	
	--Find Best Position
	local bestResults, bestScore = nil, math.huge
	for _, v in pairs(foundPositions) do
		local score = math.abs(v.distance - 2)
		if score < bestScore then
			bestResults = v.result
			bestScore = score
		end
	end	
	
	return bestResults.Instance, bestResults.Position
end

StarterIsland.Generate = function()
	local step = math.rad(360 / 5)
	for i = 1, 5 do
		local center = CFrame.Angles(0, step * i, 0)
		local islandPosition = center * CFrame.new(Settings.Size + Settings.StarterDistance + Settings.StarterSize, 0, 0)
		local x, z = math.floor(islandPosition.X + 0.5), math.floor(islandPosition.Z + 0.5)
		--Generate Island
		Islands[i] = {}
		Islands[i].Blocks = {}
		local Blocks = Islands[i].Blocks
		Supports.Add(x, z, true, 1, true)
		for dx = -Settings.StarterSize, Settings.StarterSize do
			for dz = -Settings.StarterSize, Settings.StarterSize do
				if math.sqrt(dx*dx + dz*dz) <= Settings.StarterSize then
					Matrix.CreateCell(x + dx, z + dz, 0, "Surface Fill")
					local blockData = {X = x + dx, Z = z + dz}
					if dx == 0 and dz == 0 then
						blockData.isCenter = true 
						Islands[i].Center = blockData
					end
					table.insert(Blocks, blockData)
				end
			end
		end
		for j = 1, Settings.StarterCrystals do
			PlaceCrystal(Blocks)
		end
	end
	generated = true
	print("generated")
end

function StarterIsland.AssignIsland(island, team)
	while not generated do wait() end
	TeamIslands[team] = island
	local part, position = GetSafePart(island)
	local spawnPad = Blueprint.EasyPlace(team, "Spawn", part, CFrame.new(position), true)
	local spawnPadConnector = spawnPad:WaitForChild("Connectors"):WaitForChild("Connector")
	Blueprint.Place(team, "Cap", {part = spawnPadConnector, offsetCF = CFrame.new(0, 0.562, 0)}, nil, 1, true)
	Electricity.Push(spawnPad, math.huge, true)
end

function StarterIsland.GetSafePosition(player) 
	while not TeamIslands[player.Team] do wait() end
	local part, position = GetSafePart(TeamIslands[player.Team])
	return position
end

StarterIsland.EnableIslands = function()
	generated = true
end

return StarterIsland