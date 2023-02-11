local function Command(player, arguments)
	if not arguments.Player then return "No target player specified!" end
	arguments.AdminRemote:FireClient(player, "Watch", {Player = arguments.Player})
end

return Command
