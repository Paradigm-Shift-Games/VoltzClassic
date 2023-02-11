local FreeCamera = script.FreeCamera

local function Command(player, arguments)
	if not player.PlayerGui:FindFirstChild("FreeCamera") then
		local freeCamera = FreeCamera:Clone()
		freeCamera.Parent = player.PlayerGui
	end
	arguments.AdminRemote:FireClient(player, "Free Camera")
end

return Command
