local GrassGenerator = {}

GrassGenerator.Dependencies = {
    "Island",
}

function GrassGenerator.Generate(config, randomizers, grids)
    -- Grids
    local islandGrid = grids.Island

    -- Settings
    local grassSettings = config.Grass

    -- Randomizers
    local grassNoise = randomizers.Grass

    local grassGrid = {}

    for position, _ in islandGrid do
        -- Grass Noise
        if grassNoise:EdgeRange(position.X, position.Z, grassSettings.Scale, grassSettings.Weight) then
            grassGrid[position] = true
        end
    end

    return grassGrid
end

return GrassGenerator