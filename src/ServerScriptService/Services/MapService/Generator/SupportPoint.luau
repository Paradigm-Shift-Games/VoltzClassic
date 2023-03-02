local ServerScriptService = game:GetService("ServerScriptService")

local ChunkGrid = require(ServerScriptService.Classes.Datastructure.ChunkGrid)

local SupportPointGenerator = {}

SupportPointGenerator.Dependencies = {
    "Island",
}

function SupportPointGenerator._generateMainlandSupports(supportPointGrid, islandGrid, supportSettings)
    local supportChunkGrid = ChunkGrid.new(Vector3.new(10, 10, 10))

    for position, _ in islandGrid do
        if supportChunkGrid:IsInRange(position, supportSettings.SupportSpacing) then
            continue
        end

        supportChunkGrid:Insert(position)
    end

    for _, position in supportChunkGrid:GetElements() do
        supportPointGrid[position] = true
    end
end

function SupportPointGenerator._generateStarterIslandSupports(supportPointGrid, starterIslandGrid)
    for position, _ in starterIslandGrid do
        supportPointGrid[position] = true
    end
end

function SupportPointGenerator.Generate(config, randomizers, grids)
    -- Grids
    local islandGrid = grids.Island
    local starterIslandGrid = grids.StarterIsland

    -- Settings
    local supportSettings = config.Support

    local supportPointGrid = {}

    local supportPointChunkGrid = ChunkGrid.new(Vector3.new(10, 10, 10))

    for position, _ in islandGrid do
        if supportPointChunkGrid:IsInRange(position, supportSettings.SupportSpacing) then
            continue
        end

        supportPointChunkGrid:Insert(position)
    end

    local supportPointGrid = {}

    SupportPointGenerator._generateMainlandSupports(supportPointGrid, islandGrid, supportSettings)
    SupportPointGenerator._generateStarterIslandSupports(supportPointGrid, starterIslandGrid)

    return supportPointGrid
end

return SupportPointGenerator