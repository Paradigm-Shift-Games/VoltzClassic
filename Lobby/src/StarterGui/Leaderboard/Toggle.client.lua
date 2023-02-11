local TweenService = game:GetService("TweenService")

local leaderboard = script.Parent.Leaderboard
local overlay = script.Parent.Overlay
local blur = game.Lighting.Blur

local blurScreen  = TweenService:Create(blur, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In , 0, false, 0), {Size = 24})
local clearScreen = TweenService:Create(blur, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {Size = 0 })

local showOverlay = TweenService:Create(overlay, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In , 0, false, 0), {BackgroundTransparency = 0.6})
local hideOverlay = TweenService:Create(overlay, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {BackgroundTransparency = 1.0})

local pushLeaderboard = TweenService:Create(leaderboard, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In , 0, false, 0), {Position = UDim2.new(0.1, 0, 0.05, 0)})
local pullLeaderboard = TweenService:Create(leaderboard, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {Position = UDim2.new(0.1, 0, 1.05, 0)})

local visible = false

local OpenEvent = script.Parent.Open

local CloseButton = leaderboard.Header.Close

function OpenLeaderboard()
	visible = true
	blurScreen:Play()
	showOverlay:Play()
	pushLeaderboard:Play()
end

function CloseLeaderboard()
	visible = false
	clearScreen:Play()
	hideOverlay:Play()
	pullLeaderboard:Play()
end

OpenEvent.Event:Connect(function()
	OpenLeaderboard()
end)

CloseButton.MouseButton1Click:Connect(function()
	CloseLeaderboard()
end)

game.ContextActionService:BindAction("ToggleLeaderboard", function(name, state, input)
	if state ~= Enum.UserInputState.Begin then return end
	print("Toggling Leaderboard: State => " .. (visible and "off" or "on"))
	
	if visible then CloseLeaderboard()
	else OpenLeaderboard() end
end, false, Enum.KeyCode.F)