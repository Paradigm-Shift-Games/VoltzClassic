local parent = script.Parent
local backpack = game.Players.LocalPlayer.Character:WaitForChild("Backpack")
local chargeValue = backpack:WaitForChild("Charge")
local storageValue = backpack:WaitForChild("Storage")
local percentText = script.Parent.Parent:WaitForChild("Percent")
local function onChange()
	local percent = chargeValue.Value/storageValue.Value
	percentText.Text = math.floor(percent*100).."%"
	script.Parent.Size = UDim2.fromScale(percent, 1)
end
chargeValue.Changed:Connect(onChange)
onChange()