-- Author: n0pa

local Grid = require(game.ServerScriptService.Packages.Grid.Classes.Grid)

local module = {}

local Grids = {}

local function getPosition(object)
	return object.Position or object.PrimaryPart.Position
end

function module.CreateGrid(name, position1, position2, dimensions)
	local grid = Grid.New(position1, position2, dimensions)
	Grids[name] = grid
	
	return grid
end

function module.DeleteGrid(name)
	Grids[name] = nil
end

function module.GetGrid(name)
	return Grids[name]
end

function module.Insert(name, element)
	return Grids[name]:Insert(element, getPosition(element))
end

function module.Remove(name, element)
	return Grids[name]:Remove(element)
end

function module.Update(name, element)
	local grid = Grids[name]
	grid:Remove(element)
	
	return grid:Insert(element, getPosition(element))
end

function module.GetElements(name)
	return Grids[name]:GetElements()
end

function module.GetElementsInRadius(name, position, radius)
	return Grids[name]:GetElementsInRadius(position, radius)
end

return module