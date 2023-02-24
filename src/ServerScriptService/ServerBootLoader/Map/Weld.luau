-- Author: 4812571

local ServerScriptService = game:GetService("ServerScriptService")

local Matrix = require(script.Parent.Matrix)
local WeldService = require(ServerScriptService.Services.WeldService)

local Weld = {}
local CellFolder = workspace.MapCells

function WeldNeighbors(cell)
	local x, z, y = cell.X, cell.Z, cell.Y
	local neighbors = Matrix.GetNeighbors(x, z, y)
	for _, v in pairs(neighbors) do
		if cell.Model.Name == "Crystal" and v.Model.Name == "Crystal" then continue end
		WeldService.WeldModels(cell.Model, v.Model)
	end
end

function UnanchorCell(cell)
	if not cell.Anchored then
		cell.Model.PrimaryPart.Anchored = false
	end
end

function Weld.Weld()
	Matrix.Interate(WeldNeighbors)
	Matrix.Interate(UnanchorCell)
end

function Weld.Initialize()
	for _, v in CellFolder:GetChildren() do
		for _, g in v:GetChildren() do
			for _, j in g:GetChildren() do
				for _, k in pairs(j:GetDescendants()) do
					if j.PrimaryPart.Anchored == false then
						warn(j:GetFullName().." :PrimaryPart is not anchored!")
					end
					if k:IsA("BasePart") and k ~= j.PrimaryPart or k.Name == "Main" then
						local weld = Instance.new("WeldConstraint")
						weld.Parent = j
						weld.Part0 = j.PrimaryPart
						weld.Part1 = k
						k.Anchored = false
					end
				end
				j.PrimaryPart.Anchored = true
			end
		end
	end
end

return Weld
