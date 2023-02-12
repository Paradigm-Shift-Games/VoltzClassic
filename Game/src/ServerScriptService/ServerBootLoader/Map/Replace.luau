-- Author: 4812571

local Matrix = require(script.Parent.Matrix)
local Picker = require(script.Parent.Picker)
local Settings = require(script.Parent.Settings.selectedSettings.Value)


local module = {}
local Masks = {}
local LargeTypes = {}
local MatrixContents = {}
local CellSize = 12
local CellFolder = workspace.MapCells

function roundVector(vector)
	return Vector3.new(math.floor(vector.X + 0.5), math.floor(vector.Y + 0.5), math.floor(vector.Z + 0.5))
end

module.Intitialize = function()
	for _, v in pairs(CellFolder:GetChildren()) do
		for _, g in pairs(v:GetChildren()) do
			for _, j in pairs(g:GetChildren()) do
				if j:FindFirstChild("ReplacementMatrix") then
					Masks[j] = {}
					LargeTypes[v.Name..' '..g.Name] = true
					local cornerPos = j.Main.Position - (j.Main.Size / 2) + (Vector3.new(CellSize, CellSize, CellSize) / 2)
					for _, k in pairs(j.ReplacementMatrix:GetChildren()) do
						local relPos = roundVector((k.Position - cornerPos) / CellSize)
						if not Masks[j][relPos.X] then
							Masks[j][relPos.X] = {}		
						end
						if not Masks[j][relPos.X][relPos.Z] then
							Masks[j][relPos.X][relPos.Z] = {}
						end
						Masks[j][relPos.X][relPos.Z][relPos.Y] = k.Name
					end
					j.ReplacementMatrix:Destroy()
				end
			end
		end
	end	
	local tab = {}
	local i = 1
	for v, _ in pairs(LargeTypes) do
		tab[i] = v
		i = i + 1
	end
	LargeTypes = tab
end

function GetRandomCell()
	return MatrixContents[math.random(1, #MatrixContents)]
end

function GetRandomCellType()
	return LargeTypes[math.random(1, #LargeTypes)]
end

function Try(model, modelType, modelSize, position)
	local x, z, y = position.X, position.Z, position.Y
	for dx, _ in pairs(Masks[model]) do
		for dz, _ in pairs(Masks[model][dx]) do
			for dy, v in pairs(Masks[model][dx][dz]) do
				local data = Matrix.GetData(x + dx, z + dz, y + dy)
				if not data then return false end
				if data.isLarge then return false end
				if data.Anchored then return false end
				if v == "Match" then
					if modelType ~= data.Type then
						return false
					end
				elseif v ~= "Solid" then
					warn("Incorrect mask type!:", v)
				end
			end 
		end
	end
	for dx = 0, modelSize.X - 1 do
		for dz = 0, modelSize.Z - 1 do
			for dy = 0, modelSize.Y - 1 do
				Matrix.ClearCell(x + dx, z + dz, y + dy)
			end
		end
	end
	Matrix.AddLargeCell(x, z, y, model, modelType, modelSize, (position - Vector3.new(0.5, 0.5, 0.5) + (modelSize/2)))
	return true
end

function PlaceCell(cellType)
	local cell, cellSize = Picker.GetLargeCell(cellType)
	for _ = 1, 32 do
		local replacing = GetRandomCell() 
		if Try(cell, cellType, cellSize, replacing.Position) then return end
	end
end

module.Replace = function()
	if #MatrixContents == 0 then
		Matrix.Interate(function(v) table.insert(MatrixContents, v) end)
	else
		warn("Attempt to repeat replacement")
	end
	for i = 1, math.floor(#MatrixContents * Settings.ReplacerIntensity) do
		PlaceCell(GetRandomCellType())
	end
end




































return module