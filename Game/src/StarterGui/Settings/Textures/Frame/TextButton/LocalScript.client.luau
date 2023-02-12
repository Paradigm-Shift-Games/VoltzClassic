-- Author: Accedo


script.Parent.MouseButton1Click:Connect(function()
	
	for _, v in pairs(workspace.Map:GetDescendants()) do
		if v:IsA("Texture") then v:Destroy() end
		
		if v:IsA("MeshPart") then v.TextureID = "" end
		
		if v:IsA("Part") or v:IsA("MeshPart") and v.Material == Enum.Material.Slate then v.Material = Enum.Material.Plastic end -- it looks **really** weird when the grass is slate, people will think it's a texture
		if v:IsA("MeshPart") and v.BrickColor == BrickColor.new("Really black") then v.Color = Color3.fromRGB(79, 76, 78) v.Material = Enum.Material.Plastic end
		if v:IsA("MeshPart") and v.BrickColor == BrickColor.new("Rust") then v.BrickColor = BrickColor.new("Dirt brown") v.Material = Enum.Material.Plastic end
	end
	wait(0.5)
	script.Parent.Parent.Parent:Destroy()
	
end)