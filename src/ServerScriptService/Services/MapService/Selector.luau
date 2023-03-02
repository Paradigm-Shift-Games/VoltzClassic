local Selector = {}

function Selector._selectSmallCells(selectors, smallCells)
    local models = {}

    for cellId, cellType in smallCells.Types do
        models[cellId] = selectors[cellType]:Sample()
    end

    local smallTemplates = {
        Models = models,
        Positions = smallCells.Positions,
    }

    return smallTemplates
end

function Selector._selectLargeCells(selectors, largeCells)
    local models = {}
    local positions = {}

    for cellId, cellType in largeCells.Types do
        models[cellId] = selectors[cellType]:Sample()
        positions[cellId] = largeCells.Positions[cellId] + largeCells.Extents[cellId] / 2
    end

    local largeTemplates = {
        Models = models,
        Positions = positions,
    }

    return largeTemplates
end

function Selector.Select(selectors, largeCells, smallCells)
    local selectionGrid = {}

    -- Select Cells
    local smallTemplates = Selector._selectSmallCells(selectors, smallCells)
    local largeTemplates = Selector._selectLargeCells(selectors, largeCells)

    local selectionData = {
        LargeTemplates = largeTemplates,
        SmallTemplates = smallTemplates,
        SelectionGrid = selectionGrid,
    }

    return selectionData
end

