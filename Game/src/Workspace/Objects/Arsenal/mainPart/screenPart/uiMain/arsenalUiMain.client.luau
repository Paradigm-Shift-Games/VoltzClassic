local ButtonRemote = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("ArsenalButton")
local container = script.Parent:WaitForChild("container")
local CategoryContainer = container:WaitForChild("CategoryContainer")
local WeaponContainer = container:WaitForChild("WeaponContainer")
local OriginalArsenal = script.Parent:WaitForChild("OriginalArsenal")
for _, button in ipairs(CategoryContainer:GetChildren()) do
	if button:IsA("TextButton") then 
		button.MouseButton1Click:Connect(function()
			ButtonRemote:FireServer(button)
		end)
	end
end
WeaponContainer.ChildAdded:Connect(function(child)
	if child:IsA("TextButton") then
		child.MouseButton1Click:Connect(function()
			ButtonRemote:FireServer(child)
		end)
		
	end
end)
OriginalArsenal.Value.Changed:Connect(function()
	if OriginalArsenal.Value == nil or OriginalArsenal.Value.Parent == nil then
		script.Parent:Destroy()
	end
end)


