wait(3)
local effect = script.Effect

local character = game.Players.LocalPlayer.Character
local charPrimary = character.PrimaryPart

for i = 1, 1000 do
	effect:Clone().Parent = charPrimary
end