-- Author: Accedo
local GroupID = 5444195
local AdminRank = 253
local whitelist = {}
-- add members as needed
local LocalPlayer = game.Players.LocalPlayer

function NoHarmonica(player)
	if player:GetRankInGroup(GroupID) >= AdminRank then 
		print(player.Name.." is whitelisted.")
	elseif not table.find(whitelist, player) then 
		print(player.Name.." is not whitelisted.") 
		return
	else
		print(player.Name.." is whitelisted.")
	end
	print("Destroying harmonica scripts...")
	for harmonicas, harmonicascript in pairs(workspace:GetDescendants()) do
		if harmonicascript:IsA("Script") and harmonicascript.Name == "HarmonicaSounds" then
			harmonicascript:Destroy()
		end
	end
end

function playerAdded(plr)
	plr.CharacterAppearanceLoaded:Connect(NoHarmonica(plr))
end

NoHarmonica(LocalPlayer)
game.Players.PlayerAdded:Connect(playerAdded)