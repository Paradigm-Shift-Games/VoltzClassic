-- Author: 4812571

local Matrix = require(script.Parent.Matrix)
local Settings = require(script.Parent.Settings.selectedSettings.Value)

local module = {}
local ColumnCount = 0
local cellSelection = {items = {}, distribution = {}}
local selectionTotal = 1 + Settings.WellPipeWeight + Settings.LadderWeight
cellSelection.items = {"Support Fill", "Support Well", "Support Ladder"}
cellSelection.distribution = {1/selectionTotal, Settings.WellPipeWeight/selectionTotal, Settings.LadderWeight/selectionTotal}
module.Supports = {}

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

function module.CanGenerate(x, z)
	local minDistance = Settings.SupportSpacing
	for _, support in pairs(module.Supports) do
		local distance = math.sqrt((support.X-x)^2 + (support.Z-z)^2)
		if distance < minDistance then return false end
	end
	return true
end

local function Generate(x, z, isCircular, size, isStarter)
	--if isStarter then print(";)") end
	local isCircular = isCircular or math.random(1, 2) == 1
	local size = size or math.random(0, 1)
	for dx = -size, size do
		for dz = -size, size do
			if math.sqrt(dx*dx + dz*dz) <= size or not isCircular then
				ColumnCount = ColumnCount + 1
				local cellType
				if not isStarter then
					cellType = WeightedChoice(cellSelection)
				else
					if dx == 0 and dz == 0 and Settings.StarterWell then
						cellType = "Support Well"
					else
						cellType = "Support Fill"
					end
				end
				for y = -Settings.SupportHeight, 0 do
					if not (y == 0 and cellType == "Support Fill") then
						Matrix.ClearCell(x + dx, z + dz, y)
						if y == 0 and cellType == "Support Well" then
							Matrix.CreateCell(x + dx, z + dz, y, "Support WellTop")
						else 
							Matrix.CreateCell(x + dx, z + dz, y, cellType, y == -Settings.SupportHeight)
						end	
					end
				end
				if Matrix.GetData(x + dx, z + dz, 1) and Matrix.GetData(x + dx, z + dz, 1).Type == "Resource Crystal" and (cellType == "Support Ladder" or cellType == "Support Well") then
					Matrix.ClearCell(x + dx, z + dz, 1)
				end
			end
		end
	end
end

module.Generate = function()
	for _, v in pairs(module.Supports) do
		Generate(v.X, v.Z, v.isCircular, v.size, v.isStarter)
	end
end

function module.Add(x, z, isCircular, size, isStarter)
	table.insert(module.Supports, {X = x, Z = z, isCircular = isCircular, size = size, isStarter = isStarter})
end

return module