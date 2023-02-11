local parent = script.Parent
local getData = game.Players.LocalPlayer.Character:WaitForChild("jetpackMain"):WaitForChild("Function")
local percentText = script.Parent.Parent:WaitForChild("Percent")
local function onChange()
	local maxthrust, currentThrust = getData:Invoke()
	local amount = maxthrust-currentThrust
	local percent = math.clamp((amount/maxthrust)*100, 0, 100)
	percent = percent/100
	percentText.Text = math.floor(percent*100).."%"
	script.Parent.Size = UDim2.fromScale(percent, 1)
end
onChange()
game:GetService("RunService").Heartbeat:Connect(function()
	onChange()
end)