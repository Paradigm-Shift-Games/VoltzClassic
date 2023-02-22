-- Author: 4812571

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Welder = require(script.Weld)
local Matrix = require(script.Matrix)
local Picker = require(script.Picker)
local Support = require(script.Support)
local Renderer = require(script.Render)
local Replacer = require(script.Replace)
local StarterIsland = require(script.StarterIsland)
local Settings = require(script.Settings.Default)

local Map = {}
local NoiseKeys = {}
local generated = false

function Noise(x, z, f, key)
    if not NoiseKeys[key] then
        NoiseKeys[key] = math.random(-123456, 123456)
    end
    return (math.noise(x/f, z/f, NoiseKeys[key]) + 1) / 2
end

local sleepCount = 0
function Sleep(frequency)
    sleepCount = sleepCount + 1
    if sleepCount > frequency then
        wait(0.03333333)
        sleepCount = 0
    end
end

function Map.Generate() -- will take a datastore at some point
	if generated then warn("Map generate called > 1 times") end
	generated = true
	print("Initializing!")
	Replacer.Intitialize()
	Renderer.Initialize()
	Picker.Initialize()
	Welder.Initialize()
	workspace.MapCells.Parent = ReplicatedStorage
	print("Generating Map!")
	for x = -Settings.Size, Settings.Size do
		for z = -Settings.Size, Settings.Size do
			Sleep(256)
			if math.sqrt(x*x + z*z) <= Settings.Size then
				local gapNoise = Noise(x, z, 24, "Gap")
				local isGap = gapNoise > 0.5 - (Settings.GapSize/2) and gapNoise < 0.5 + (Settings.GapSize/2)
				if not isGap then
					--[[ Surface ]]--
					local isGrass = Noise(x, z, 16, "Grass") < 0.5
					if isGrass then
						Matrix.CreateCell(x, z, 0, "Surface Grass")
					else
						Matrix.CreateCell(x, z, 0, "Surface Fill")
					end
					--[[ Underground ]]--
					local thickness = math.floor((Noise(x, z, 32, "Thickness") * 2) + 0.5)
					for y = -thickness, -1 do
						Matrix.CreateCell(x, z, y, "Surface Fill") 
					end
					--[[ Support ]]--
					if Support.CanGenerate(x, z) then
						Support.Add(x, z)
					end
					--[[ Ruins ]]--
					local isCity = Settings.CityDensity >= Noise(x, z, 32, "City")
					local isBuilding = Settings.BuildingDensity >= Noise(x, z, 12, "Ruin")
					local isAlley = Noise(x, z, 3, "Alley") > 0.5
					local isRuin = Settings.Ruins and (isCity and isBuilding) and not isAlley
					if isRuin then
						local ruinHeight = math.floor(Noise(x, z, 8, "RuinHeight") * 16)
						for y = 1, ruinHeight do
							Matrix.CreateCell(x, z, y, "Ruin Fill")
						end
					end
					--[[ Crystals ]]--
					if not isRuin then
						if Settings.CrystalSpawnRate >= math.random() then
							Matrix.CreateCell(x, z, 1, "Resource Crystal")
						end
					end
				end
			end
		end
	end
	StarterIsland.Generate()
	Support.Generate()
	Replacer.Replace()
	Renderer.Render()
	Welder.Weld()
	StarterIsland.EnableIslands()
end

return Map