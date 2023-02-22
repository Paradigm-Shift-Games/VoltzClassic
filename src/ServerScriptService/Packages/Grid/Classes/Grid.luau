-- Author: n0pa

local module = {}
module.__index = module

-- local function areBoxesColliding(center1, size1, center2, size2)
--	if  center1.X + 0.5*size1.X < center2.X - 0.5*size2.X or
--		center1.Z + 0.5*size1.Z < center2.Z - 0.5*size2.Z or
--		center1.Y + 0.5*size1.Y < center2.Y - 0.5*size2.Y then return false end

--	return true
-- end

local function sectorIndexFromCoords(self, x, y, z)
	local dimensions = self.Dimensions
	return 1 + x + dimensions.X*z + dimensions.X*dimensions.Z*y
end

local function sectorIndexFromPoint(self, point)
	local pointDelta = point - self.Position1
	local sectorX = math.floor(pointDelta.X/self.SectorSize.X)
	local sectorY = math.floor(pointDelta.Y/self.SectorSize.Y)
	local sectorZ = math.floor(pointDelta.Z/self.SectorSize.Z)

	return sectorIndexFromCoords(self, sectorX, sectorY, sectorZ)
end

local function getNeighboringSectorIndices(self, position, radius)
	local index = sectorIndexFromPoint(self, position)

	local dx = 1 + math.floor(radius/self.SectorSize.X)
	local dz = 1 + math.floor(radius/self.SectorSize.Z)
	local dy = 1 + math.floor(radius/self.SectorSize.Y)

	local intersectingSectorIndices = {}

	local dimensions = self.Dimensions
	local maxIndex = dimensions.X*dimensions.Y*dimensions.Z
	for i = -dy, dy do
		for j = -dz, dz do
			for k = -dx, dx do
				local sectorIndex = index + k + dimensions.X*j + dimensions.X*dimensions.Z*i
				if sectorIndex < 1 or sectorIndex > maxIndex then continue end

				table.insert(intersectingSectorIndices, sectorIndex)
			end
		end
	end

	return intersectingSectorIndices
end

function module.New(position1, position2, dimensions)
	local self = setmetatable({}, module)

	self.Position1 = position1
	self.Position2 = position2
	self.Dimensions = dimensions

	self.Center = 0.5*(position1 + position2)
	self.Size = position2 - position1
	self.SectorSize = self.Size/dimensions

	self.Elements = {}
	self.Sectors = {}
	for i = 1, dimensions.X*dimensions.Y*dimensions.Z do self.Sectors[i] = {} end

	return self
end

function module.Insert(self, element, position)
	local index = sectorIndexFromPoint(self, position)

	self.Sectors[index][element] = position
	self.Elements[element] = index

	return position
end

function module.Remove(self, element)
	local index = self.Elements[element]
	if not index then return end

	self.Sectors[index][element] = nil
	self.Elements[element] = nil
end

function module.Update(self, element, position)
	module.Remove(self, element)
	return module.Insert(self, element, position)
end

function module.GetElements(self)
	local returnTable = {}
	for element, _ in pairs(self.Elements) do table.insert(returnTable, element) end

	return returnTable
end

function module.GetElementsInRadius(self, position, radius)
	local elementsInRadius = {}

	local neighboringIndices = getNeighboringSectorIndices(self, position, radius)
	for _, index in ipairs(neighboringIndices) do
		for element, elementPosition in pairs(self.Sectors[index]) do
			if (elementPosition - position).Magnitude > radius then continue end

			table.insert(elementsInRadius, element)
		end
	end

	return elementsInRadius
end

return module