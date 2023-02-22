local PlayersService = game:GetService("Players")
local GridInterface = require(script.Parent.Interface2)

local characterSectorSize = Vector3.new(75, 125, 75)
local CharacterGrid = GridInterface.Create("Characters", characterSectorSize)

local spatialSectorSize = Vector3.new(50, 100, 50)
local SpatialGrid = GridInterface.Create("Spatial", spatialSectorSize)

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		GridInterface.Insert(nil, character, CharacterGrid)

		character:WaitForChild("Humanoid").Died:Connect(function()
			GridInterface.Remove(nil, character, CharacterGrid)
		end)
	end)

	player.CharacterRemoving:Connect(function(character)
		GridInterface.Remove(nil, character, CharacterGrid)
	end)
end

PlayersService.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(game.Players:GetChildren()) do
	onPlayerAdded(player)
end

return 0