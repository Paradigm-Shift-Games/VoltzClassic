local StarterIslandGenerator = {}

StarterIslandGenerator.Dependencies = {
    "StarterIslandPoint",
}

function StarterIslandGenerator._generateStarterIsland(position, islandConfig, islandRadiusNoise, islandDepthNoise)
    local islandSize = islandConfig.StarterIslandSize

    local starterIsland = {}

    -- Extract noise values
    local radiusVariation = islandConfig.StarterIslandRadiusVariation

    for x = -islandSize, islandSize do
        for z = -islandSize, islandSize do
            -- Noisy Radius
            local islandRadius = islandSize + islandRadiusNoise:Range(x, z, radiusVariation.Scale, radiusVariation.Weight)

            -- Circle
            if math.sqrt(x ^ 2 + z ^ 2) > islandRadius then
                continue
            end

            -- Generate Depth
            local depth = math.floor(islandDepthNoise:UnitNoise(x, z, islandConfig.Depth.Scale) * islandConfig.Depth.Magnitude)

            -- Grid
            starterIsland[Vector3.new(x, 0, z)] = depth
        end
    end
end

function StarterIslandGenerator.Generate(config, randomizers, grids)
    -- Grids
    local starterIslandPointGrid = grids.StarterIslandPoint

    -- Config
    local islandConfig = config.Island

    -- Randomizers
    local islandRadiusNoise = randomizers.StarterIslandRadius
    local islandDepthNoise = randomizers.IslandDepth

    local starterIslandGrid = {}

    for position, _ in starterIslandPointGrid do
        starterIslandGrid = StarterIslandGenerator._generateStarterIsland(position, islandConfig, islandRadiusNoise, islandDepthNoise)
    end

    return starterIslandGrid
end
    
return StarterIslandGenerator