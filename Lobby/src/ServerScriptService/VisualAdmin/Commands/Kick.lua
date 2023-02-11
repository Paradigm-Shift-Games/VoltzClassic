local function Command(player, arguments)
	if not arguments.Player then return "No target player specified!" end
	arguments.Player:Kick(arguments.Reason)
end

return Command
