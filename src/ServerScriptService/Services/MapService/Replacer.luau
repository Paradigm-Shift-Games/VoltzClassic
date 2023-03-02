local Replacer = {}

function Replacer._reserveCells(position, extent, cellGrid, cellId)
    for x = 0, extent.X - 1 do
        for y = 0, extent.Y - 1 do
            for z = 0, extent.Z - 1 do
                local cellPosition = position + Vector3.new(x, y, z)
                cellGrid[cellPosition] = cellId
            end
        end
    end
end

function Replacer.LoadLargeCells(terrainGrid, replacers, cellGrid, idGenerator)
    local cellTypes = {}
    local cellPositions = {}
    local cellExtents = {}

    for position, _ in terrainGrid do
        -- Select Replacer
        local selectedReplacer = replacers:Sample()

        -- Large Cell Avoidance
        if selectedReplacer:Overlaps(position, cellGrid) then
            continue
        end
        
        -- Placement Check
        if not selectedReplacer:Matches(position, terrainGrid) then
            continue
        end

        -- Store Cell Data
        local cellId = idGenerator:Next()
        cellTypes[cellId] = selectedReplacer.CellType
        cellPositions[cellId] = position
        cellExtents[cellId] = selectedReplacer.Extent

        -- Reserve Cells
        Replacer._reserveCells(position, selectedReplacer.Extent, cellGrid, cellId)
    end

    local largeCells = {
        Types = cellTypes,
        Positions = cellPositions,
        Extents = cellExtents,
    }

    return largeCells
end

function Replacer.LoadSmallCells(terrainGrid, cellGrid, idGenerator)
    local cellTypes = {}
    local cellPositions = {}

    for position, cellType in terrainGrid do
        -- Ignore Large Celll Reservations
        if cellGrid[position] then
            continue
        end

        -- Store Cell Data
        local cellId = idGenerator:Next()
        cellTypes[cellId] = cellType
        cellPositions[cellId] = position

        -- Reserve Cell
        cellGrid[position] = cellId
    end
    
    local smallCells = {
        Types = cellTypes,
        Positions = cellPositions,
    }

    return smallCells
end

function Replacer.Replace(terrainGrid, replacers)
    local cellGrid = {}

    local idGenerator = IdGenerator.new()

    -- Load Cells
    local largeCells = Replacer.LoadLargeCells(terrainGrid, replacers, cellGrid, idGenerator)
    local smallCells = Replacer.LoadSmallCells(terrainGrid, cellGrid, idGenerator)

    local replacementData = {
        LargeCells = largeCells,
        SmallCells = smallCells,
        CellGrid = cellGrid,
    }

    return replacementData
end

return Replacer