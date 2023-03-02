local StarterIslandBuilder = {}

StarterIslandBuilder.Dependencies = {
    
}

function StarterIslandBuilder._buildStarterIsland(position, starterIsland, terrainGrid)
    for offset, _ in starterIsland do
        local columnPosition = position + offset

        for y = -starterIsland.Depth, 0 do
            terrainGrid[columnPosition + Vector3.new(0, y, 0)] = "Surface Fill"
        end
    end
end

function StarterIslandBuilder.Build(config, randomizers, grids, terrainGrid)
    -- Grids
    local starterIslandGrid = grids.StarterIsland

    for position, starterIsland in starterIslandGrid do

    end

    return starterIslandGrid
end

return StarterIslandBuilder