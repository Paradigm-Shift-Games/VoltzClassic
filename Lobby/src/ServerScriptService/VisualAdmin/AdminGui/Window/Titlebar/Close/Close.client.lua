local screenGUI = script:FindFirstAncestorOfClass("ScreenGui");

local button = script.Parent;

button.MouseEnter:Connect(function()
	button.ImageColor3 = Color3.new(1, 0.13, 0.13);
end)

button.MouseLeave:Connect(function()
	button.ImageColor3 = Color3.new(1, 1, 1);
end)

button.MouseButton1Click:Connect(function()
	screenGUI.Enabled = false;
	button.ImageColor3 = Color3.new(1, 1, 1);
end)