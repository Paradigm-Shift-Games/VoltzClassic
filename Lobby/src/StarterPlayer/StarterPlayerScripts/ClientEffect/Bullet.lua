local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local module = function(Attachment, EndPosition, parameters)
	RunService.Heartbeat:Wait()
	--Cut Custom Parameters
	local size = parameters.Size
	parameters.Size = nil
	local speed = parameters.Speed
	parameters.Speed = nil
	--Apply Remaining Parameters
	local NewProjectile = script:WaitForChild("Part"):Clone()
	for i, v in pairs(parameters) do
		NewProjectile[i] = v
	end
	--Set Positioning
	local WorldPosition = Attachment.WorldPosition
	local magnitude = (WorldPosition-EndPosition).Magnitude
	NewProjectile.Size = Vector3.new(size, size, magnitude)
	local angle = CFrame.new(WorldPosition, EndPosition)
	angle = angle-angle.Position
	local cf = CFrame.new(WorldPosition, EndPosition):Lerp(CFrame.new(EndPosition)*angle, .5)
	NewProjectile.CFrame = cf
	NewProjectile.Parent = workspace.Effects
	--Tween
	wait()
	local Tween = TweenService:Create(NewProjectile, TweenInfo.new(magnitude/speed), 
	{
		Size = Vector3.new(size, size, 0),
		Position = EndPosition
	})
	Tween:Play()
	wait(magnitude/speed)
	NewProjectile:Destroy()
end

return module