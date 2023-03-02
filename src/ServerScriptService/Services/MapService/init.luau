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

-- Data Pipeline Architecture
local Randomizer = require(script.Randomizer)
local Generator = require(script.Generator)
local Builder = require(script.Builder)

local MapService = {}
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

local TerrainConfig = {
	Seed = 123456,

	Island = {
		MainlandSize = 45,

		StarterIslandDistance = 15,
		StarterIslandSize = 5,
		StarterIslandAmount = 6,
		StarterIslandOffset = (45/2),
 
		Grass = {
			Scale = 16,
			Weight = 0.5,
		},

		Gaps = {
			Scale = 16,
			Weight = 0.19,
		},

		Depth = {
			Scale = 32,
			Magnitude = 2,
		},
	},

	Crystal = {
		CrystalSpawnRate = 0.05,
	},

	Beacon = {
		BeaconCount = 7,
		Offset = (45 / 2);
	},

	Support = {
		SupportSpacing = 7,
		SupportHeight = 10,
	},

	Spire = {
		Cities = {
			Scale = 32,
			Weight = 0.5,
		},

		Buildings = {
			Scale = 12,
			Weight = 0.5,
		},

		Alleys = {
			Scale = 3,
			Weight = 0.5,
		},

		Height = {
			Scale = 8,
			Magnitude = 16,
		}
	},
}

function MapService:Generate(TerrainGrid)
	-- Source Objects
	local randomizers = RandomizerSource.CreateRandomizers(TerrainConfig)
	local replacers = ReplacerSource.CreateReplacers(TerrainConfig)
	local selectors = SelectorSource.CreateSelectors(TerrainConfig)

	-- Generate Grids
	local grids = Generator.Generate(TerrainConfig, randomizers)
	local terrainGrid = Builder.Build(TerrainConfig, randomizers, grids)

	-- Replace Cells
	local replacementData = Replacer.Replace(terrainGrid, replacers)

	-- Select Templates
	local selectionData = Selector.Select(selectors, terrainGrid.LargeCells, terrainGrid.SmallCells)

	-- Render Terrain
	local cellModels = Renderer.Render(TerrainConfig, replacementData.CellGrid, selectionData.LargeTemplates, selectionData.SmallTemplates)

	-- Weld
	local weldGraph = Welder.Weld(replacementData.CellGrid, cellModels)

	-- Package Results
	local generationResult = {
		Models = cellModels,
		WeldGraph = weldGraph,
	}

	return generationResult
end

return MapService