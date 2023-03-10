-- Author: 4812571

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Matrix = require(script.Parent.Matrix)
local Picker = require(script.Parent.Picker)
local GameStats = require(ReplicatedStorage.Stats.Game)
local DamageService = require(ServerScriptService.Services.DamageService)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)
local ElectricNode = require(ServerScriptService.Packages.Electricity.Classes.Node)
local ElectricHook = require(ServerScriptService.Packages.Electricity.Classes.NetworkObjects.Hook)

local Render = {}
local Map = workspace.Map
local MapCells = workspace.MapCells
local CellOffsets = {}
local CellSize = 12

local sleepCount = 0
function Sleep(frequency)
    sleepCount = sleepCount + 1
    if sleepCount > frequency then
        wait(0.03333333)
        sleepCount = 0
    end
end

function Render.Initialize()
	for _, v in MapCells:GetChildren() do
		for _, g in v:GetChildren() do
			for _, j in g:GetChildren() do
				if not j:FindFirstChild("Main") then error(j:GetFullName().." has no main part!") end
				CellOffsets[j] = j.Main.CFrame:ToObjectSpace(j.PrimaryPart.CFrame)
			end
		end
	end
end

function RenderCell(cell)
	if cell.isReference then return end
	Sleep(1024)
	if cell.isLarge then
		local x, z, y = cell.X, cell.Z, cell.Y
		local chosen = cell.Model
		cell.Model = cell.Model:Clone()
		cell.Model:SetPrimaryPartCFrame(CFrame.new(cell.Position * CellSize) * CellOffsets[chosen])
		cell.Model.Parent = Map
		for dx = 0, cell.Size.X - 1 do
			for dz = 0, cell.Size.Z - 1 do
				for dy = 0, cell.Size.Y - 1 do
					Matrix.AddReference(x + dx, z + dz, y + dy, x, z, y	)
				end
			end
		end
	else
		local chosen = Picker.GetCell(cell.Type)
		cell.Model = chosen:Clone()
		cell.Model:SetPrimaryPartCFrame(CFrame.new(cell.Position * CellSize) * CellOffsets[chosen])
		cell.Model.Parent = Map
	end
	
	if cell.Model.Name == "Crystal" then
		CollectionService:AddTag(cell.Model, "Crystal")
		CollectionService:AddTag(cell.Model, "NoLeaks")
		
		local node = ElectricNode.New()
		node.charge = math.random(GameStats["Crystal"]["MinCapacity"], GameStats["Crystal"]["MaxCapacity"])
		node.storage = GameStats["Crystal"]["MaxCapacity"]
		
		local updatedHook = ElectricHook.New("ChargeUpdated")
		updatedHook:Connect(function(node, charge, chargeDelta) local toScale = charge / (charge - chargeDelta) cell.Model.MeshPart.Size *= toScale end)
		updatedHook:BindNode(node)
		
		local emptiedHook = ElectricHook.New("Emptied")
		emptiedHook:Connect(function() DamageService.Destroy(cell.Model) end)
		emptiedHook:BindNode(node)
		
		
		cell.Model.MeshPart.Size = cell.Model.MeshPart.Size * (node.charge / GameStats["Crystal"]["MaxCapacity"])
		Electricity.BindStructure(cell.Model, node)
	else
		CollectionService:AddTag(cell.Model, "Terrain")
	end
end

function Render.Render()
	Matrix.SmartInterate(RenderCell)
end

return Render