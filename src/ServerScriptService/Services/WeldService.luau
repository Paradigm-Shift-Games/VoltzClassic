-- Author: 4812571

local ServerScriptService = game:GetService("ServerScriptService")

local CleanupService = require(ServerScriptService.Services.CleanupService)

local WeldService = {}
local WeldGraph = {}
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

function WeldService.Unanchor(Object)
	for _, v in Object:GetDescendants() do
		if v:IsA("BasePart") then v.Anchored = false end
	end
end

function WeldService.WeldModel(Object)
	for _, v in Object:GetDescendants() do
		if Object:IsA("Model") and v == Object.PrimaryPart then continue end
		if v:IsA("BasePart") and not WeldIgnore[v.Name] then
			if v.Name == "ChargeBar" then WeldMotor6D(v, v, Object.PrimaryPart) else Weld(Object, Object.PrimaryPart, v) end
		end
	end
end

function WeldService.WeldTool(tool)
	local handle = tool:FindFirstChild("Handle")
	if not handle then warn(tool.Name, "has no handle!") return end
	for _, v in tool:GetDescendants() do
		if v == handle then continue end
		if v:IsA("BasePart") then WeldMotor6D(handle, handle, v) end
	end
end

function WeldService.WeldAssembly(Object)
	
	-- Weld Models
	for _, v in Object:GetChildren() do
		if v:IsA("Model") then
			local Primary = v.PrimaryPart
			for _, g in v:GetDescendants() do
				if g:IsA("BasePart") then Weld(v, Primary, g) end
			end
		end
	end
	for _, v in Object:GetChildren() do
		if v.Name == "Snaps" or v.Name == "Connectors" then
			for _, g in v:GetChildren() do Weld(Object, g, Object.PrimaryPart) end
 		end
	end
	
	-- Weld Hinges
	for _, v in Object:GetDescendants() do
		if v.Name == "Hinge1" then WeldMotor6D(v.Parent, v, v.Attach.Value, "HingeMotor") end
	end
end

function WeldService.WeldModels(Object1, Object2)
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

function WeldService.Unweld(Object)
	for Other, weld in pairs(WeldGraph[Object]) do
		WeldGraph[Other][Object] = nil
		weld:Destroy()
	end
	WeldGraph[Object] = nil
end

CleanupService.Bind("Weld", WeldService.Unweld)

return WeldService

