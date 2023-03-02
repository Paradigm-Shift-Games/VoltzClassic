local SupportGenerator = {}

SupportGenerator.Dependencies = {
    "SupportPoint",
    "StarterIslandPoint",
}

function SupportGenerator._generateSupport(radius, isCircular, supportConfig, wellRandom, ladderRandom)
    local support = {}

    for x = -radius, radius do
        for z = -radius, radius do
            if isCircular and math.sqrt(x*x + z*z) > radius then
                continue
            end

            if ladderRandom:NextNumber() < supportConfig.LadderChance then
                support[Vector3.new(x, 0, z)] = "Ladder"
            elseif wellRandom:NextNumber() < supportConfig.WellChance then
                support[Vector3.new(x, 0, z)] = "Well"
            else
                support[Vector3.new(x, 0, z)] = "Fill"
            end
        end
    end

    return support
end

function SupportGenerator._generateStarterSupport()
    local support = {}
    
    for x = -1, 1 do
        for z = -1, 1 do
            if math.sqrt(x*x + z*z) > 1 then
                continue
            end

            if x == 0 and z == 0 then
                support[Vector3.new(x, 0, z)] = "Well"
            else
                support[Vector3.new(x, 0, z)] = "Fill"
            end
        end
    end

    return support
end

function SupportGenerator.Generate(config, randomizers, grids)
    -- Grids
    local supportPointGrid = grids.SupportPoint
    local starterIslandPointGrid = grids.StarterIslandPoint

    -- Settings
    local supportSettings = config.Support

    -- Randomizers
    local radiusRandom = randomizers.SupportRadius
    local circularRandom = randomizers.SupportCircular
    local wellRandom = randomizers.Well
    local ladderRandom = randomizers.Ladder

    local supportGrid = {}

    for position, _ in supportPointGrid do
        local radius = radiusRandom:NextNumber(supportSettings.MinRadius, supportSettings.MaxRadius)
        local isCircular = circularRandom:NextNumber() < supportSettings.CircularChance

        supportGrid[position] = SupportGenerator._generateSupport(radius, isCircular, supportSettings, wellRandom, ladderRandom)
    end

    for position, _ in starterIslandPointGrid do
        supportGrid[position] = SupportGenerator._generateStarterSupport()
    end
end

return SupportGenerator