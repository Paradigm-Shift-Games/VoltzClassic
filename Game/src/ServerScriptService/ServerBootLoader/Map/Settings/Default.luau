local RunService = game:GetService("RunService")

local Settings = {}
-- Map Size
Settings.Size = (RunService:IsStudio() and 45) or 45
-- Support Spacing 
Settings.SupportSpacing = 7
-- Support Height
Settings.SupportHeight = 12
-- Gap Size
Settings.GapSize = 0.112
-- Ruins
Settings.Ruins = true
-- City Density
Settings.CityDensity = 0.44 
-- Building Density
Settings.BuildingDensity = 0.52 
-- LargeBlock Density
Settings.ReplacerIntensity = 0.8
-- Crystal Spawn Rate
Settings.CrystalSpawnRate = 1/16
-- Well Pipe Weight
Settings.WellPipeWeight = 0.77 
-- Ladder Weight
Settings.LadderWeight = 0.5
-- StarterIsland
Settings.StarterIsland = true
-- StarterIsland Crystals
Settings.StarterCrystals = 5
-- StarterIsland Distance
Settings.StarterDistance = 5
-- StarterIsland Size
Settings.StarterSize = 5
-- StarterIsland Well
Settings.StarterWell = true
-- TeamCount
Settings.TeamCount = 5


return Settings
