local module = {}
local camera = workspace.CurrentCamera


function AxisLocked(axis)
	local upVector = axis
	local charVector = -camera.CFrame.LookVector
	local rightVector = charVector:Cross(upVector).unit
	local frontVector = rightVector:Cross(upVector).unit
	return CFrame.fromMatrix(Vector3.new(0, 0, 0), rightVector, upVector, frontVector)
end

function Surface(position, normal)
	return CFrame.new(position, position + normal):ToWorldSpace(CFrame.Angles(math.rad(-90), 0, 0))
end

function snapCFrame(cframe)
	local increment = 15
	local increments, degrees
	local x, y, z = cframe:toEulerAnglesXYZ()
	local function snap(angle)
		local d = math.deg(angle)
		local i = d / increment
		i = math.floor(i + 0.5)
		return math.rad(i * increment)
	end
	return CFrame.new(cframe.p) * CFrame.Angles(snap(x), snap(y), snap(z))
end

local SnapEvent = game.ReplicatedStorage.Events.SnapData
local SnapData = SnapEvent:InvokeServer()


module.Rotation = 0

module.Rotate = function(deg)
	module.Rotation = (module.Rotation + math.rad(deg)) % math.rad(360)
end

module.Standard = function(Model, part, position, normal)
	local rotation = AxisLocked(normal)
	local Cf = CFrame.new(position) * rotation
	local SurfaceCF = Surface(position, normal)
	local Difference = SurfaceCF:ToObjectSpace(Cf)
	Difference = Difference:ToWorldSpace(CFrame.Angles(0, module.Rotation, 0))
	local Cf = SurfaceCF:ToWorldSpace(snapCFrame(Difference))
	Cf = Cf:ToWorldSpace(SnapData[Model.Name].Position)
	return part.CFrame:ToObjectSpace(Cf)
end

module.Snapped = function(primary, rootSnap, targetSnap, Invert)
	local rotation = AxisLocked(targetSnap.CFrame.UpVector)
	local ModelCF = CFrame.new(targetSnap.Position) * rotation
	if Invert then
		ModelCF = ModelCF * CFrame.Angles(0, -math.rad(90), math.rad(180))
	end
	local fromPart = targetSnap.CFrame:ToObjectSpace(ModelCF)
	fromPart = snapCFrame(fromPart) * CFrame.Angles(0, module.Rotation, 0)
	ModelCF = targetSnap.CFrame:ToWorldSpace(fromPart)
	local SnapOffset = rootSnap.CFrame:ToObjectSpace(primary.CFrame)
	return targetSnap.CFrame:ToObjectSpace(ModelCF * SnapOffset)
end

module.Wire = function(primary, rootSnap, targetSnap)
	local rotation = AxisLocked(targetSnap.CFrame.UpVector)
	local ModelCF = CFrame.new(targetSnap.Position) * rotation
	ModelCF = ModelCF * CFrame.Angles(0, -math.rad(90), math.rad(180))
	local fromPart = targetSnap.CFrame:ToObjectSpace(ModelCF)
	fromPart = snapCFrame(fromPart) * CFrame.Angles(0, module.Rotation, 0)
	fromPart = fromPart:ToObjectSpace(CFrame.new(0, -targetSnap.Size.Y, 0))
	ModelCF = targetSnap.CFrame:ToWorldSpace(fromPart)
	local SnapOffset = rootSnap.CFrame:ToObjectSpace(primary.CFrame)
	return targetSnap.CFrame:ToObjectSpace(ModelCF * SnapOffset)
end


return module
