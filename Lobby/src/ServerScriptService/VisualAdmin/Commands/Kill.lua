local function Command(player, arguments)
	if not arguments.Player then return "No target player specified!" end
	local character = arguments.Player.Character or arguments.Player.CharacterAdded:Wait()
	character:BreakJoints()
end

return Command
