local Renderer = {}

function Renderer._renderCells(config, cellGrid, templates, cellModels)
    local cellSize = config.CellSize

    local templateModels = templates.Models
    local templatePositions = templates.Positions

    for cellId, templateModel in templateModels do
        local model = templateModel:Clone()
        model:PivotTo(templatePositions[cellId] * cellSize)
        cellModels[cellId] = model
    end
end

function Renderer.Render(config, cellGrid, largeTemplates, smallTemplates)
    local cellModels = {}

    -- Render Cells
    Renderer._renderCells(cellGrid, largeTemplates, cellModels)
    Renderer._renderCells(cellGrid, smallTemplates, cellModels)

    return cellModels
end

return Renderer