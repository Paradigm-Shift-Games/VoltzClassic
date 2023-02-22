-- Author: Sheikh
local TweenService = game:GetService("TweenService")

local ANIMATION_SPEED = 0.5 -- 0.5 studs per second

-- BarAnimator Class
local BarAnimator = {}
BarAnimator.__index = BarAnimator

function BarAnimator:SetFill(percentage)
	-- percentage is a 0-1 unit value

	-- Interpolate from current size to target size
	local targetOffset = self.emptyOffset:Inverse() * self.emptyOffset:Lerp(self.fullOffset, percentage) 
	local targetSize = self.emptySize + Vector3.new(0, self.fullHeight * percentage, 0)

	-- Set the bar size and Motor6D CFrame offset
	self.bar.Size = targetSize
	self.motor6D.C0 = self.emptyOffset:ToWorldSpace(targetOffset)
end

function BarAnimator:AnimateFill(percentage)
	-- percentage is a 0-1 unit value
	
	-- Interpolate from current size to target size
	local targetOffset = self.emptyOffset:Inverse() * self.emptyOffset:Lerp(self.fullOffset, percentage) 
	local targetSize = self.emptySize + Vector3.new(0, self.fullHeight * percentage, 0)
	
	-- Calculate the difference for speed calculations
	local difference = math.abs(self.bar.Size.Y - targetSize.Y)

	-- Tween the size and CFrame
	TweenService:Create(self.motor6D, TweenInfo.new(difference / ANIMATION_SPEED), {C0 = self.emptyOffset:ToWorldSpace(targetOffset)}):Play()
	TweenService:Create(self.bar    , TweenInfo.new(difference / ANIMATION_SPEED), {Size = targetSize}):Play()
end

-- Service
local module = {}

function module.New(bar, weldedTo)
	local object = {
		bar = bar;
		motor6D = bar:FindFirstChildOfClass("Motor6D");
		fullHeight = bar.Size.Y;
		emptySize = Vector3.new(bar.Size.X, 0, bar.Size.Z);
		fullOffset = bar.CFrame:ToObjectSpace(weldedTo.CFrame);
		emptyOffset = (bar.CFrame - (bar.Size.Y / 2 * bar.CFrame.UpVector)):ToObjectSpace(weldedTo.CFrame);
	}

	return setmetatable(object, BarAnimator)
end

return module