-- Author: 4812571

local Matrix = {}
Matrix = {}
Matrix.LargeCells = {}

function Allocate(x, z, y, data)
	if not Matrix[x] then
		Matrix[x] = {}
	end
	if not Matrix[x][z] then
		Matrix[x][z] = {}
	end
	Matrix[x][z][y] = data
end

function Matrix.CreateCell(x, z, y, cellType, anchored)
	local cell = {X = x, Z = z, Y = y, Position = Vector3.new(x, y, z), Type = cellType, Anchored = anchored}
	if Matrix[x] and Matrix[x][z] and Matrix[x][z][y] then
		warn("Attempt to overrite Matrix!")
	end
	Allocate(x, z, y, cell)
end

function Matrix.AddLargeCell(x, z, y, model, modelType, modelSize, position)
	local cell = {X = x, Z = z, Y = y, isLarge = true, Size = modelSize, Model = model, Position = position, Type = modelType}
	Allocate(x, z, y, cell)
end

function Matrix.GetNeighbors(x, z, y)
	local neighbors = {}
	table.insert(neighbors, Matrix.GetData(x + 1, z, y))
	table.insert(neighbors, Matrix.GetData(x - 1, z, y))
	table.insert(neighbors, Matrix.GetData(x, z + 1, y))
	table.insert(neighbors, Matrix.GetData(x, z - 1, y))
	table.insert(neighbors, Matrix.GetData(x, z, y + 1))
	table.insert(neighbors, Matrix.GetData(x, z, y - 1))
	return neighbors
end

function Matrix.ClearCell(x, z, y)
	if not Matrix[x] then return end
	if not Matrix[x][z] then return end
	Matrix[x][z][y] = nil
	--Matrix.CreateCell(x, z, y, "Test Fill")
end

function Matrix.AddReference(x, z, y, xRef, zRef, yRef)
	local data = Matrix.GetData(xRef, zRef, yRef)
	data.isReference = true
	Allocate(x, z, y, data)
end

function Matrix.GetData(x, z, y)
	if not Matrix[x] then return nil end
	if not Matrix[x][z] then return nil end
	return Matrix[x][z][y]
end

function Matrix.Interate(func)
	for x, _ in pairs(Matrix) do
		for z, _ in pairs(Matrix[x]) do
			for y, v in pairs(Matrix[x][z]) do
				func(v)
			end
		end
	end
end

function Matrix.SmartInterate(func)
	local keys = {}
	for x, _ in pairs(Matrix) do
		table.insert(keys, x)
	end
	table.sort(keys)
	for _, x in ipairs(keys) do
		for z, _ in pairs(Matrix[x]) do
			for y, v in pairs(Matrix[x][z]) do
				func(v)
			end
		end
	end
end

return Matrix