local function Command(player, parameters, target)
	if not target then print("Cannot Kick Player: No target specified!") return end
	
	if #parameters == 0 then
		target:Kick()
	else
		table.remove(parameters, 1)
		target:Kick(table.concat(parameters, " "))
	end
end

return Command
