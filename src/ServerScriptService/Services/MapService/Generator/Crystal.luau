local CrystalGenerator = {}

CrystalGenerator.Dependencies = {
    "Island",
    "Spire",
}

function CrystalGenerator.Generate(config, randomizers, grids)
    -- Grids
    local islandGrid = grids.Island
    local spireGrid = grids.Spire

    -- Settings
    local crystalSettings = config.Crystal

    -- Randomizers
    local crystalRandom = randomizers.Crystal

    local crystalGrid = {}

    for position, _ in islandGrid do
        -- Spire Avoidance
        if spireGrid[position] then
            continue
        end

        -- Crystal Randomization
        if crystalRandom:NextNumber() < crystalSettings.SpawnRate then
            crystalGrid[position] = true
        end
    end

    return crystalGrid
end

return CrystalGenerator