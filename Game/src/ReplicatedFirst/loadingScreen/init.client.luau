local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local tips = require(script:WaitForChild("Tips"))

local loadingScreenData = workspace:WaitForChild("loadingScreenData")
local messageValue = loadingScreenData:WaitForChild("Message")
local percentValue = loadingScreenData:WaitForChild("Percent")
local loadingUi = script:WaitForChild("loadingScreen")
local text = loadingUi:WaitForChild("text")
local tip = loadingUi:WaitForChild("tip")
local bar = loadingUi:WaitForChild("loadingBar"):WaitForChild("percentBar")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local tipUpdateTime = 3--How often the tip is switched.
local currentTip = tips[math.random(1, #tips)]
local count = 0
local function onRenderStepped(delta)
	count = count + delta--I really love to count https://www.youtube.com/watch?v=fMrr6s8CSDo
	if messageValue.Value ~= "" then
		loadingUi.Parent = PlayerGui
		bar.Size = UDim2.fromScale(percentValue.Value, 1)
		text.Text = messageValue.Value
		tip.Text = currentTip
		if count >= tipUpdateTime then
			count = 0
			currentTip = tips[math.random(1, #tips)]
		end
		--set the camera stuff probably
	else
		loadingUi.Parent = script
	end
end

RunService:BindToRenderStep("loadingScreen", 200, onRenderStepped)