local SpireBuilder = {}

function SpireBuilder.Build(config, randomizers, grids, terrainGrid)
    -- Grids
    local spireGrid = grids.Spire
    local grassGrid = grids.Grass

    for position, height in spireGrid do
        for y = 1, height do
            if y == height then
                if grassGrid[position] then
                    terrainGrid[position + Vector3.new(0, y, 0)] = "Spire Grass"
                else
                    terrainGrid[position + Vector3.new(0, y, 0)] = "Spire Top"
                end
            else
                terrainGrid[position + Vector3.new(0, y, 0)] = "Spire Fill"
            end
        end
    end
end

return SpireBuilder