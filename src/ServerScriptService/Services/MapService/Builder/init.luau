local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local Loader = require(Packages.Loader)

local Builder = {}

local loadOrder = {

}

function Builder.Build(config, randomizers, grids)
    local builders = Loader.LoadChildren(script)

    local terrainGrid = {}

    for _, builderName in loadOrder do
        local builder = builders[builderName]
        builder.Build(config, randomizers, grids, terrainGrid)
    end

    return terrainGrid
end

return Builder