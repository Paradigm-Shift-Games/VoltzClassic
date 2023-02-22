-- Author: n0pa

local RunService = game:GetService("RunService")
local Grid = require(game.ServerScriptService.Packages.Grid.Classes.Grid2)

local module = {}

local Grids = {}
local Connections = {}

local function getPosition(object)
	if object:IsA("Model") then return object.PrimaryPart and object.PrimaryPart.Position end
	
	return object.Position
end

function module.Create(name, sectorSize)
	local grid = Grids[name]
	if grid then return grid end
	
	grid = Grid.New(sectorSize)
	Grids[name] = grid
	
	Connections[name] = RunService.Heartbeat:Connect(function()
		for element, _ in pairs(grid.Sectors) do grid:Update(element, getPosition(element)) end
	end)
	
	return grid
end

function module.Delete(name)
	Grids[name] = nil
	
	Connections[name]:Disconnect()
	Connections[name] = nil
end

function module.Get(name)
	return Grids[name]
end

function module.Insert(name, element, _grid)
	warn(name, element, _grid)
	return (_grid or Grids[name]):Insert(element, getPosition(element))
end

function module.Remove(name, element, _grid)
	return (_grid or Grids[name]):Remove(element)
end

function module.Update(name, element, _grid)
	_grid = _grid or Grids[name]
	_grid:Remove(element)
	
	local position = getPosition(element)
	return position and _grid:Insert(element, position)
end

function module.GetElements(name, _grid)
	return (_grid or Grids[name]):GetElements()
end

function module.GetInRadius(name, position, radius, _grid)
	return (_grid or Grids[name]):GetInRadius(position, radius)
end

function module.GetClosestInRadius(name, position, radius, _grid)
	return (_grid or Grids[name]):GetClosestInRadius(position, radius)
end

function module.GetPriorityInRadius(name, position, radius, priorityFunc, _grid)
	return (_grid or Grids[name]):GetPriorityInRadius(position, radius, priorityFunc)
end

return module