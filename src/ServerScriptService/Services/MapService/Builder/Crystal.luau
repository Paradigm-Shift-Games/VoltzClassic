local CrystalBuilder = {}

CrystalBuilder.Dependencies = {
    
}

function CrystalBuilder.Build(config, randomizers, grids, terrainGrid)
    -- Grids
    local crystalGrid = grids.Crystal

    for position, _ in crystalGrid do
        terrainGrid[position + Vector3.new(0, 1, 0)] = "Resource Crystal"
    end
end

return CrystalBuilder