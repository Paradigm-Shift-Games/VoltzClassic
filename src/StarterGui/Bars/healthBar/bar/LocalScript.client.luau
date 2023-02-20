local Players = game:GetService("Players")

local parent = script.Parent
local Humanoid = Players.LocalPlayer.Character:WaitForChild("Humanoid")
local percentText = script.Parent.Parent:WaitForChild("Percent")
local function onChange()
	local percent = Humanoid.Health/Humanoid.MaxHealth
	percentText.Text = math.floor(percent*100).."%"
	script.Parent.Size = UDim2.fromScale(percent, 1)
end
Humanoid.Changed:Connect(onChange)
onChange()