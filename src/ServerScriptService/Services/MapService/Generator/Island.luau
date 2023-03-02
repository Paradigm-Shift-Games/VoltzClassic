local IslandGenerator = {}

IslandGenerator.Dependencies = {

}

function IslandGenerator.Generate(config, randomizers, grids)
	-- Settings
	local islandSettings = config.Island
	
	-- Randomizers
	local gapNoise = randomizers.IslandGaps
	local depthNoise = randomizers.IslandDepth

	local islandGrid = {}

	for x = -islandSettings.MainlandSize, islandSettings.MainlandSize do
		for z = -islandSettings.MainlandSize, islandSettings.MainlandSize do
			-- Circle
			if math.sqrt(x*x + z*z) > islandSettings.MainlandSize then
				continue
			end

			-- Gaps
			if gapNoise:Range(x, z, islandSettings.Gaps.Scale, islandSettings.Gaps.Weight) then
				continue
			end

			-- Depth
			local depth = math.floor(depthNoise:UnitNoise(x, z, islandSettings.Depth.Scale) * islandSettings.Depth.Magnitude)

			-- Grid
			islandGrid[Vector3.new(x, 0, z)] = depth
		end
	end

	return islandGrid
end

return IslandGenerator