local IslandBuilder = {}

IslandBuilder.Dependencies = {
    
}

function IslandBuilder.Build(config, randomizers, grids, terrainGrid)
    -- Grids
    local islandGrid = grids.Island
    local grassGrid = grids.Grass

    for position, depth in islandGrid do
        for y = -depth, 0 do
            if y == 0 and grassGrid[position] then
                terrainGrid[position + Vector3.new(0, y, 0)] = "Surface Grass"
            else
                terrainGrid[position + Vector3.new(0, y, 0)] = "Surface Fill"
            end
        end
    end
end

return IslandBuilder