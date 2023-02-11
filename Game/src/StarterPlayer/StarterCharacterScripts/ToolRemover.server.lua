--Author: Styx
local Humanoid = script.Parent:WaitForChild("Humanoid")
Humanoid.Died:Connect(function()
	for _,v in ipairs(script.Parent:GetChildren()) do
		if v:IsA("Tool") then
			v:Destroy()
		end
	end
	for _,v in ipairs(game.Players:GetPlayerFromCharacter(script.Parent).Backpack:GetChildren()) do
		v:Destroy()
	end
end)