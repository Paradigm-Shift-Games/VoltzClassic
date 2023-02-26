local Teams = game:GetService("Teams")

local function Command(player, parameter)
	for _, v in Teams:GetChildren() do
		print(v)
	end
end

return Command
