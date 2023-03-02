local SupportBuilder = {}

SupportBuilder.Dependencies = {
    "Island",
    "StarterIsland",
}

function SupportBuilder.Build(config, randomizers, grids, terrainGrid)
    -- Grids
    local supportGrid = grids.Support

    -- Config
    local supportConfig = config.Support

    for position, support in supportGrid do
        for offset, column in support do
            local columnPosition = position + offset

            if column == "Well" then
                for y = -supportConfig.Height, -1 do
                    terrainGrid[columnPosition + Vector3.new(0, y, 0)] = "Support Well"
                end

                continue
            end

            if column == "Ladder" then
                for y = -supportConfig.Height, -1 do
                    terrainGrid[columnPosition + Vector3.new(0, y, 0)] = "Support Ladder"
                end

                continue
            end

            if column == "Fill" then
                for y = -supportConfig.Height, 0 do
                    terrainGrid[columnPosition + Vector3.new(0, y, 0)] = "Support Fill"
                end

                continue
            end

            error("Invalid support column type: " .. column)
        end
    end
end

return SupportBuilder