local function Command(player, arguments)
	if not arguments.Player then return "No target player specified!" end
	local character = arguments.Player.Character or arguments.Player.CharacterAdded:Wait()
	character:SetPrimaryPartCFrame(CFrame.new(player.Character.PrimaryPart.CFrame.Position + player.Character.PrimaryPart.CFrame.LookVector, player.Character.PrimaryPart.CFrame.Position))
end

return Command
