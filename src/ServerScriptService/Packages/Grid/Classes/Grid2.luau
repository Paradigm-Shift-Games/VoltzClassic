-- Author: n0pa

local BinaryTree = require(game.ServerScriptService.Classes.Datastructure.BinaryTree)

local DEBUG = false

local module = {}
module.__index = module

local function hasElements(tab)
	for _, _ in pairs(tab) do return true end
	
	return false
end

local function positionToSector(self, position)
	local x = math.floor(0.5 + position.X/self.SectorSize.X)
	local y = math.floor(0.5 + position.Y/self.SectorSize.Y)
	local z = math.floor(0.5 + position.Z/self.SectorSize.Z)
	
	return x, y, z
end

local function addSectorPart(self, x, y, z)	
	if not DEBUG then return end
	
	local part = Instance.new("Part")
	part.Name = x.."-"..y.."-"..z
	part.Size = Vector3.new(1, 1, 1)*self.SectorSize
	part.Position = Vector3.new(x, y ,z)*self.SectorSize
	part.Anchored = true
	part.CanCollide = false
	part.Color = Color3.fromRGB(197, 30, 1)
	part.Transparency = 0.6
	part.Material = Enum.Material.Plastic
	part.Parent = workspace.Effects
end

local function removeSectorPart(x, y, z)
	local part = workspace.Effects:FindFirstChild(x.."-"..y.."-"..z)
	if part then part:Destroy() end
end

local function allocate(self, x, y, z)	
	local Mx = self.Matrix[x]
	if not Mx then
		self.Matrix[x] = {[z] = {[y] = {}}}
		addSectorPart(self, x, y, z)
		return
	end
	
	local Mz = Mx[z]
	if not Mz then
		Mx[z] = {[y] = {}}
		addSectorPart(self, x, y, z)
		return
	end
	
	if not Mz[y] then
		Mz[y] = {}
		addSectorPart(self, x, y, z)
		return
	end
end

local function deallcoate(self, x, y, z)
	local Mx = self.Matrix[x]
	local Mz = Mx[z]
	
	removeSectorPart(x, y, z)
	Mz[y] = nil
	
	if hasElements(Mz) then return end
	Mz = nil
	
	if hasElements(Mx) then return end
	Mx = nil
end

function module.New(sectorSize)
	local self = setmetatable({}, module)
	
	self.SectorSize = sectorSize
	
	self.Sectors = {}
	self.Matrix = {}
	
	return self
end

function module.Insert(self, object, position, _x, _y, _z)
	if not object or (not position and not _x) then return end

	local x, y, z = _x, _y, _z
	if not x then x, y, z = positionToSector(self, position) end
	
	allocate(self, x, y, z)
	
	local sectorIndices = {x, z, y}
	self.Sectors[object] = sectorIndices
	self.Matrix[x][z][y][object] = position
	
	return sectorIndices
end

function module.Remove(self, object)
	local sectorIndex = self.Sectors[object]
	if not sectorIndex then return end
	
	self.Sectors[object] = nil
	
	local x, z, y = unpack(sectorIndex)
	local sector = self.Matrix[x][z][y]
	sector[object] = nil
	
	deallcoate(self, x, y, z)
	
	return sectorIndex
end

function module.GetElements(self)
	return self.Sectors
end

function module.GetInRadius(self, position, radius)
	local sx = math.ceil(radius/self.SectorSize.X)
	local sy = math.ceil(radius/self.SectorSize.Y)
	local sz = math.ceil(radius/self.SectorSize.Z)
	
	local px = math.floor(0.5 + position.X/self.SectorSize.X)
	local py = math.floor(0.5 + position.Y/self.SectorSize.Y)
	local pz = math.floor(0.5 + position.Z/self.SectorSize.Z)
	
	local returnTable = {}
	for i = px - sx, px + sx do
		local matrixI = self.Matrix[i]
		if not matrixI then continue end

		for j = pz - sz, pz + sz do
			local matrixIJ = matrixI[j]
			if not matrixIJ then continue end

			for k = py - sy, py + sy do
				local matrixIJK = matrixIJ[k]
				if not matrixIJK then continue end
				
				for object, objectPosition in pairs(matrixIJK) do
					if (objectPosition - position).Magnitude > radius then continue end
					table.insert(returnTable, object)
				end
			end
		end
	end
	
	return returnTable
end

function module.GetClosestInRadius(self, position, radius)
	local sx = math.ceil(radius/self.SectorSize.X)
	local sy = math.ceil(radius/self.SectorSize.Y)
	local sz = math.ceil(radius/self.SectorSize.Z)
	
	local px = math.floor(0.5 + position.X/self.SectorSize.X)
	local py = math.floor(0.5 + position.Y/self.SectorSize.Y)
	local pz = math.floor(0.5 + position.Z/self.SectorSize.Z)
	
	local minObject, min = nil, math.huge
	for i = px - sx, px + sx do
		local matrixI = self.Matrix[i]
		if not matrixI then continue end

		for j = pz - sz, pz + sz do
			local matrixIJ = matrixI[j]
			if not matrixIJ then continue end

			for k = py - sy, py + sy do
				local matrixIJK = matrixIJ[k]
				if not matrixIJK then continue end
				
				for object, objectPosition in pairs(matrixIJK) do
					local distance = (objectPosition - position).Magnitude
					if distance > radius then continue end
					if distance >= min then continue end
					
					minObject, min = object, distance
				end
			end
		end
	end
	
	return minObject
end

function module.GetPriorityInRadius(self, position, radius, priorityFunc)
	local sx = math.ceil(radius/self.SectorSize.X)
	local sy = math.ceil(radius/self.SectorSize.Y)
	local sz = math.ceil(radius/self.SectorSize.Z)

	local px = math.floor(0.5 + position.X/self.SectorSize.X)
	local py = math.floor(0.5 + position.Y/self.SectorSize.Y)
	local pz = math.floor(0.5 + position.Z/self.SectorSize.Z)

	local returnTable = BinaryTree.New(priorityFunc)
	for i = px - sx, px + sx do
		local matrixI = self.Matrix[i]
		if not matrixI then continue end

		for j = pz - sz, pz + sz do
			local matrixIJ = matrixI[j]
			if not matrixIJ then continue end

			for k = py - sy, py + sy do
				local matrixIJK = matrixIJ[k]
				if not matrixIJK then continue end

				for object, objectPosition in pairs(matrixIJK) do
					if (objectPosition - position).Magnitude > radius then continue end
					returnTable:Insert(object, objectPosition)
				end
			end
		end
	end

	return returnTable
end

function module.Update(self, object, position)
	if not position then return end
	
	local x, y, z = positionToSector(self, position)
	if {x, y, z} == self.Sectors[object] then self.Matrix[x][z][y][object] = position return end
	
	module.Remove(self, object)
	module.Insert(self, object, position, x, y, z)
end

return module
