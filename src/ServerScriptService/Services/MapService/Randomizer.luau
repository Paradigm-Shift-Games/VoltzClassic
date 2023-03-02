local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local Noise2D = require(Packages.Noise2D)

local Randomizer = {}

function Randomizer.CreateRandomizers(config)
    local random = Random.new(config.Seed)

    local function GenRandom()
        return Random.new(random:NextNumber())
    end

    local function GenNoise()
        return Noise2D.new(random:NextNumber())
    end

    local randomizers = {
        -- Island
        IslandGaps = GenNoise(),
        IslandDepth = GenNoise(),
        StarterIslandRadius = GenNoise(),

        -- Crystal
        Crystal = GenRandom(),

        -- Spire
        SpireCities = GenNoise(),
        SpireBuildings = GenNoise(),
        SpireAlleys = GenNoise(),
        SpireHeight = GenNoise(),
    }

    return randomizers
end

return Randomizer