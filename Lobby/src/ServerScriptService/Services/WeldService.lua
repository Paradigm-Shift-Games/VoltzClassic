--Author: 4812571

--Use Weld function! no manual welds!
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

module.Unanchor = function(Object)
	for _, v in pairs(Object:GetDescendants()) do
		if v:IsA("BasePart") then v.Anchored = false end
	end
end

module.WeldModel = function(Object)
	for _, v in pairs(Object:GetDescendants()) do
		if Object:IsA("Model") and v == Object.PrimaryPart then continue end
		if v:IsA("BasePart") and not WeldIgnore[v.Name] then
			Weld(Object, Object.PrimaryPart, v)
		end
	end
end

module.WeldTool = function(tool)
	local handle = tool:FindFirstChild("Handle")
	if not handle then warn(tool.Name, "has no handle!") return end
	for _, v in pairs(tool:GetDescendants()) do
		if v == handle then continue end
		if v:IsA("BasePart") then
			local newMotor6 = Instance.new("Motor6D")
			newMotor6.Parent = handle
			newMotor6.C0 = handle.CFrame:Inverse() * v.CFrame
			newMotor6.Part0 = handle
			newMotor6.Part1 = v
		end
	end
end

module.WeldAssembly = function(Object)
	--Weld Models
	for _, v in pairs(Object:GetChildren()) do
		if v:IsA("Model") then
			local Primary = v.PrimaryPart
			for _, g in pairs(v:GetDescendants()) do
				if g:IsA("BasePart") then
					local newWeld = Instance.new("WeldConstraint")
					newWeld.Part0 = Primary
					newWeld.Part1 = g
					newWeld.Parent = v
				end
			end
		end
	end	
	for _, v in pairs(Object:GetChildren()) do
		if v.Name == "Snaps" or v.Name == "Connectors" then
			for _, g in pairs(v:GetChildren()) do
				local newWeld = Instance.new("WeldConstraint")
				newWeld.Part0 = Object.PrimaryPart
				newWeld.Part1 = g
				newWeld.Parent = Object 				
			end
 		end
	end
	--Weld Hinges
	for _, v in pairs(Object:GetDescendants()) do
		if v.Name == "Hinge1" then
			local newWeld = Instance.new("Motor6D")
			newWeld.Part0 = v
			newWeld.Part1 = v.Attach.Value
			newWeld.Name = "HingeMotor"
			newWeld.Parent = v.Parent
		end
	end
end

module.WeldModels = function(Object1, Object2)
	if Object1 == Object2 then return end
--	print("Welding:", Object1:GetFullName(), "To", Object2:GetFullName())
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
--	print("Unwelding")
	for Other, weld in pairs(WeldGraph[Object]) do
		WeldGraph[Other][Object] = nil
		weld:Destroy()
	end
	WeldGraph[Object] = nil
end

CleanupService.Bind("Weld", module.Unweld)

return module

