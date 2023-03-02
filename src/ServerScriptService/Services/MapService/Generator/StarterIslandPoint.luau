local StarterIslandPointGenerator = {}

StarterIslandPointGenerator.Dependencies = {
    
}

function StarterIslandPointGenerator.Generate(config, randomizers, grids)
    -- Config
    local islandConfig = config.Island

    local starterIslandPointGrid = {}

    local islandAngleDifference = math.rad(360 / islandConfig.IslandCount)

    for i = 1, islandConfig.IslandCount do
        local unitX = math.cos(islandAngleDifference * i)
        local unitY = math.sin(islandAngleDifference * i)

        local scaledX = math.round(unitX * (islandConfig.MainlandSize + islandConfig.StarterIslandOffset))
        local scaledY = math.round(unitY * (islandConfig.MainlandSize + islandConfig.StarterIslandOffset))

        starterIslandPointGrid[Vector3.new(scaledX, 0, scaledY)] = true
    end
end

return StarterIslandPointGenerator