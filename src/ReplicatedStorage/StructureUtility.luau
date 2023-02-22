local SnapList = require(game.ReplicatedStorage.SnapList)

local StructureUtility = {}

function StructureUtility.Flag(model, brickcolor)
	if not brickcolor then
		brickcolor = BrickColor.random()
	end

	for _, v in pairs(model:GetChildren()) do
		if v:IsA("BasePart") then
			v.BrickColor = brickcolor
		end
	end
end

function StructureUtility.CanSnap(Source, Target)
	if type(Source) == "userdata" then Source = Source.Name end
	if type(Target) == "userdata" then Target = Target.Name end
	if not SnapList[Source] then
		return
	end
	if table.find(SnapList[Source], Target) then
		return true
	end
	return false
end

function StructureUtility.GetModel(part)
	if not part then return nil end
	local parent = part.Parent
	local object = part
	while true do
		if parent == nil then return nil end
		if parent == workspace then return nil end
		if parent == game then return nil end
		if parent == workspace.Structures then return object end
		if parent == workspace.Map then return object end
		object = parent
		parent = object.Parent
	end
end

function StructureUtility.GetTouchingModels(part)
	-- Get all the parts touching the part
	local touchingParts = workspace:GetPartsInPart(part)

	-- Store the models
	local models = {}

	-- Get every model
	for _, part in touchingParts do
		local model = StructureUtility.GetModel(part)

		if model then
			models[model] = true
		end
	end

	-- Convert the set to an array.
	local modelsArray = {}

	for model, _ in pairs(models) do
		table.insert(modelsArray, model)
	end

	return modelsArray
end

function StructureUtility.IsDetector(snapPart)
	if not snapPart then return nil end
	return snapPart.Name == "Snap" or snapPart.Name == "Connector"
end

function StructureUtility.DetectorParent(snapPart)
	if not snapPart then return nil end
	if not snapPart.Parent then return nil end
	return snapPart.Parent.ParentStructure.Value
end

function StructureUtility.DetectorType(snapPart)
	return StructureUtility.DetectorParent(snapPart).Name
end

return StructureUtility