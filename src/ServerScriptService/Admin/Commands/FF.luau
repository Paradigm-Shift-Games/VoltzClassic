local function Command(player, parameter, target)
	if not target then print("Cannot create Force Field: No target specified!") return end
	
	if target.Character:FindFirstChild("ForceField") then
		target.Character.ForceField:Destroy()
	else
		Instance.new("ForceField", target.Character)
	end	
end

return Command
