local function Command(player, arguments)
	if not arguments.Player then return "No target player specified!" end
	local character = arguments.Player.Character or arguments.Player.CharacterAdded:Wait()
	player.Character:SetPrimaryPartCFrame(CFrame.new(character.PrimaryPart.CFrame.Position + character.PrimaryPart.CFrame.LookVector, character.PrimaryPart.CFrame.Position))
end

return Command
