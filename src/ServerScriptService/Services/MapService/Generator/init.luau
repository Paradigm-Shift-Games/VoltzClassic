local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local Loader = require(Packages.Loader)

local Generator = {}

local loadOrder = {
    -- Beacon
    "Beacon",

    -- Starter Island
    "StarterIslandPoint",
    "StarterIsland",

    -- Island
    "Island",

    -- Island Features
    "Crystal",
    "Grass",
    "Spire",

    -- Support
    "SupportPoint",

    -- Support Features
    "Support",
}

function Generator.Generate(config, randomizers)
    local generators = Loader.LoadChildren(script)

    local grids = {}

    for _, generatorName in loadOrder do
        local generator = generators[generatorName]
        grids[generatorName] = generator.Generate(config, grids, randomizers)
    end

    return grids
end

return Generator