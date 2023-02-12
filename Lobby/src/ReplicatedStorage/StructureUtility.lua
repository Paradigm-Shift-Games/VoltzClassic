local module = {}
local SnapList = require(game.ReplicatedStorage.SnapList)

module.Flag = function(model, brickcolor)
	brickcolor = brickcolor or BrickColor.Random()
	for _, v in pairs(model:GetChildren()) do
		if v:IsA("BasePart") then
			v.BrickColor = brickcolor
		end
	end
end

module.CanSnap = function(Source, Target)
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

module.GetTouchingModels = function(part)
	local connection = part.Touched:Connect(function() end)
	local touching = part:GetTouchingParts()
	connection:Disconnect()
	local modelsHash = {}
	for _, v in pairs(touching) do
		local model = module.GetModel(v)
		if model and not modelsHash[model] then
			modelsHash[model] = true 
		end	
	end
	local touchingModels = {}
	for v, _ in pairs(modelsHash) do
		table.insert(touchingModels, v)
	end
	return touchingModels
end

module.GetModel = function(part)
	if not part then return nil end
	local parent = part.Parent
	local object = part
	while true do
		if parent == nil then return nil end
		if parent == workspace then return nil end
		if parent == game then return nil end
		if parent == workspace.Structures then return object end
		if parent == workspace.Lobby then return object end
		object = parent
		parent = object.Parent
	end
end

module.IsDetector = function(snapPart)
	if not snapPart then return nil end
	return snapPart.Name == "Snap" or snapPart.Name == "Connector"
end

module.DetectorParent = function(snapPart)
	if not snapPart then return nil end
	if not snapPart.Parent then return nil end
	return snapPart.Parent.ParentStructure.Value
end

module.DetectorType = function(snapPart)
	return module.DetectorParent(snapPart).Name
end

return module
