local Tools = game.ReplicatedStorage.Guns

local function FindChildFromPartialName(parent, partial)
	if parent:FindFirstChild(partial) then return parent[partial] end
	
	for _, child in ipairs(parent:GetChildren()) do
		if child.Name:lower():sub(1, partial:len()) == partial:lower() then return child end
	end
	
	for _, child in ipairs(parent:GetChildren()) do
		if child.Name:lower():gmatch(partial)() then return child end
	end
end

local function Command(player, arguments)
	local target = player
	if arguments.Player then target = arguments.Player end
	
	local tool = arguments.Tool
	if not tool then return "No tool was specified to be given!" end
	
	tool = FindChildFromPartialName(Tools, tool)
	if not tool then return "No tool matched name supplied (" .. arguments.Tool .. ")!" end
	
	tool = tool:Clone()
	tool.Parent = target.Character:FindFirstChildOfClass("Tool") and target.Backpack or target.Character
	warn(player.Name .. " gave " .. tool.Name .. " to " .. target.Name .. "!")
end

return Command
