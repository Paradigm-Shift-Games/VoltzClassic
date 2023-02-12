--Author: 4812571

local module = {}
local Weights = {}
local Tree = {}
local CellOffsets = {}
local CellSize = 12
local CellSizes = {}
local MapCells = workspace.MapCells

function WeightedChoice(weight)
	local rand = math.random()
	local k = 0
	for i, v in pairs(weight.distribution) do
		k = k + v
		if k > rand then
			return weight.items[i]
		end
	end
end

function roundVector(vector)
	return Vector3.new(math.floor(vector.X + 0.5), math.floor(vector.Y + 0.5), math.floor(vector.Z + 0.5))
end

module.Initialize = function()
	for _, v in pairs(MapCells:GetChildren()) do
		for _, g in pairs(v:GetChildren()) do
			Tree[v.Name..' '..g.Name] = {normal = {}, large = {}}
			Weights[v.Name..' '..g.Name] = {normal = {items = {}, distribution = {}}, large = {items = {}, distribution = {}}}
			for _, j in pairs(g:GetChildren()) do 
				CellSizes[j] = roundVector(j.Main.Size / CellSize)
				if CellSizes[j] == Vector3.new(1, 1, 1) then
					table.insert(Tree[v.Name..' '..g.Name].normal, j)
					local i = #Weights[v.Name..' '..g.Name].normal.items + 1
					Weights[v.Name..' '..g.Name].normal.items[i] = j
					Weights[v.Name..' '..g.Name].normal.distribution[i] = j.Weight.Value
					j.Weight:Destroy()
				else
					table.insert(Tree[v.Name..' '..g.Name].large, j)
					local i = #Weights[v.Name..' '..g.Name].large.items + 1
					Weights[v.Name..' '..g.Name].large.items[i] = j
					Weights[v.Name..' '..g.Name].large.distribution[i] = j.Weight.Value
					j.Weight:Destroy() 
				end
				j.Main:Destroy()
			end
			for _, j in pairs(Weights[v.Name..' '..g.Name]) do
				local total = 0
				for _, g in pairs(j.distribution) do
					total = total + g
				end
				for i, _ in pairs(j.distribution) do
					j.distribution[i] = j.distribution[i]/total
				end
			end
		end
	end
end

module.GetCell = function(cellType)
	if not Weights[cellType] then
		warn("Ivalid Cell Type!", cellType)
	end
	return WeightedChoice(Weights[cellType].normal)
end

module.GetLargeCell = function(cellType)
	if not Weights[cellType] then
		warn("Ivalid Cell Type!", cellType)
	end
	local chosen = WeightedChoice(Weights[cellType].large)
	return chosen, CellSizes[chosen]
end


return module
