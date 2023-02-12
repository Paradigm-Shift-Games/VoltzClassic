-- Author: Accedo


script.Parent.MouseButton1Click:Connect(function()
	
	for _, v in pairs(workspace.Ocean:GetDescendants()) do
		if v:IsA("ParticleEmitter") then v.Enabled = false end
	end
	-- At some point replace leak particles with a color change effect
	wait(0.5)
	script.Parent.Parent.Parent:Destroy()
	
end)