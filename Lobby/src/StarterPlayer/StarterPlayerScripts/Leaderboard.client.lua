local ContextActionService= game:GetService("ContextActionService")

local RaycastParameters = RaycastParams.new()

local MaxDistance = 64

local Player = game.Players.LocalPlayer
local Camera =  game.Workspace.CurrentCamera

ContextActionService:BindAction("OpenLeaderboard", function(name, state, input)
	if state ~= Enum.UserInputState.Begin then return end
	local result = game.Workspace:Raycast(Camera.CFrame.Position, Camera:ScreenPointToRay(input.Position.X, input.Position.Y, 0).Direction * MaxDistance, RaycastParameters)
	if not result or result.Instance.Name ~= "Leaderboard" then return end
	Player.PlayerGui.Leaderboard.Open:Fire()
end, false, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)