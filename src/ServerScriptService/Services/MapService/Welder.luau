local Welder = {}

local neighborOffsets = {
    Vector3.new(-1,  0,  0),
    Vector3.new( 1,  0,  0),
    Vector3.new( 0, -1,  0),
    Vector3.new( 0,  1,  0),
    Vector3.new( 0,  0, -1),
    Vector3.new( 0,  0,  1),
}

function Welder._getNeighbors(cellPosition, cellGrid)
    local neighbors = {}

    for _, offset in neighborOffsets do
        local neighborPosition = cellPosition + offset
        local neighborCellId = cellGrid[neighborPosition]

        if neighborCellId then
            table.insert(neighbors, neighborCellId)
        end
    end

    return neighbors
end

function Welder.Weld(cellGrid, cellModels)
    local weldGraph = {}

    for cellPosition, cellId in cellGrid do
        for _, neighborCellId in Welder._getNeighbors(cellPosition, cellGrid) do
            local cellModel = cellModels[cellId]
            local neighborCellModel = cellModels[neighborCellId]

            -- Skip Duplicate Welds
            if weldGraph:IsConnected(cellModel, neighborCellModel) then
                continue
            end

            -- Weld
            local weld = Welder._createWeld(cellModel, neighborCellModel)

            -- Record Weld
            weldGraph:Connect(cellModel, neighborCellModel, weld)
        end
    end

    return weldGraph
end

return Welder