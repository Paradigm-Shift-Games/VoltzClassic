local SpireGenerator = {}

SpireGenerator.Dependencies = {
    "Island",
}

function SpireGenerator._shouldGenerate(position, cityNoise, buildingNoise, alleyNoise, heightNoise, config)
    local isCity = cityNoise:EdgeRange(position.X, position.Z, config.Cities.Scale, config.Cities.Weight)
    local isBuilding = buildingNoise:EdgeRange(position.X, position.Z, config.Buildings.Scale, config.Buildings.Weight)
    local isAlley = alleyNoise:EdgeRange(position.X, position.Z, config.Alleys.Scale, config.Alleys.Weight)

    return isCity and isBuilding and not isAlley
end

function SpireGenerator.Generate(config, randomizers, grids)
    -- Grids
    local islandGrid = grids.Island

    -- Settings
    local spireSettings = config.Spire

    -- Randomizers
    local cityNoise = randomizers.SpireCities
    local buildingNoise = randomizers.SpireBuildings
    local alleyNoise = randomizers.SpireAlleys
    local heightNoise = randomizers.SpireHeight
 
    local spireGrid = {}

    for position, _ in islandGrid do
        if not SpireGenerator._shouldGenerate(position, cityNoise, buildingNoise, alleyNoise, heightNoise, spireSettings) then
            continue
        end

        local spireHeight = math.floor(heightNoise:UnitNoise(position.X, position.Z, spireSettings.Height.Scale))

        if spireHeight == 0 then
            continue
        end

        spireGrid[position] = math.floor(heightNoise:UnitNoise(position.X, position.Z, spireSettings.Height.Scale))
    end

    return spireGrid
end

return SpireGenerator