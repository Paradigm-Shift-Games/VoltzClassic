local function Command(player, parameter, target)
	if not target then print("Cannot Kill Player: No target specified!") return end
	
	if target.Character then target.Character:BreakJoints() end	
end

return Command
