--Author: 4812571

local module = {}
local WeldGraph = {}
local CleanupService = require(game.ServerScriptService.Services.CleanupService)
local Welds = workspace.Welds
local WeldIgnore = {WeldPad = true}

function Weld(parent, part1, part2)
	local constraint = Instance.new("WeldConstraint")
	constraint.Part0 = part1
	constraint.Part1 = part2
	constraint.Parent = parent
	return constraint	
end

function WeldMotor6D(parent, part1, part2, name)
	local newMotor6 = Instance.new("Motor6D")
	if name then newMotor6.Name = name end
	newMotor6.Parent = parent
	newMotor6.C0 = part1.CFrame:Inverse() * part2.CFrame
	newMotor6.Part0 = part1
	newMotor6.Part1 = part2
end

module.Unanchor = function(Object)
	for _, v in pairs(Object:GetDescendants()) do
		if v:IsA("BasePart") then v.Anchored = false end
	end
end

module.WeldModel = function(Object)
	for _, v in pairs(Object:GetDescendants()) do
		if Object:IsA("Model") and v == Object.PrimaryPart then continue end
		if v:IsA("BasePart") and not WeldIgnore[v.Name] then
			if v.Name == "ChargeBar" then WeldMotor6D(v, v, Object.PrimaryPart) else Weld(Object, Object.PrimaryPart, v) end
		end
	end
end

module.WeldTool = function(tool)
	local handle = tool:FindFirstChild("Handle")
	if not handle then warn(tool.Name, "has no handle!") return end
	for _, v in pairs(tool:GetDescendants()) do
		if v == handle then continue end
		if v:IsA("BasePart") then WeldMotor6D(handle, handle, v) end
	end
end

module.WeldAssembly = function(Object)
	
	--Weld Models
	for _, v in pairs(Object:GetChildren()) do
		if v:IsA("Model") then
			local Primary = v.PrimaryPart
			for _, g in pairs(v:GetDescendants()) do
				if g:IsA("BasePart") then Weld(v, Primary, g) end
			end
		end
	end
	for _, v in pairs(Object:GetChildren()) do
		if v.Name == "Snaps" or v.Name == "Connectors" then
			for _, g in pairs(v:GetChildren()) do Weld(Object, g, Object.PrimaryPart) end
 		end
	end
	
	--Weld Hinges
	for _, v in pairs(Object:GetDescendants()) do
		if v.Name == "Hinge1" then WeldMotor6D(v.Parent, v, v.Attach.Value, "HingeMotor") end
	end
end

module.WeldModels = function(Object1, Object2)
	if Object1 == Object2 then return end
	if not WeldGraph[Object1] then
		CleanupService.Reserve(Object1, "Weld")
		WeldGraph[Object1] = {}	
	end
	if not WeldGraph[Object2] then
		CleanupService.Reserve(Object2, "Weld")
		WeldGraph[Object2] = {}
	end
	local weld = Weld(Welds, Object1.PrimaryPart, Object2.PrimaryPart)
	WeldGraph[Object1][Object2] = weld
	WeldGraph[Object2][Object1] = weld
end

module.Unweld = function(Object)
	for Other, weld in pairs(WeldGraph[Object]) do
		WeldGraph[Other][Object] = nil
		weld:Destroy()
	end
	WeldGraph[Object] = nil
end

CleanupService.Bind("Weld", module.Unweld)

return module

