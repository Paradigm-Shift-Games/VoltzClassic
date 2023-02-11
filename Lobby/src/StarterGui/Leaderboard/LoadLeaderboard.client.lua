local Players = game.Players
local LocalPlayer = Players.LocalPlayer

local TopColours = {
	Color3.fromRGB(207, 154, 19);
	Color3.fromRGB(163, 185, 185);
	Color3.fromRGB(136, 103, 51);
}

local TopColoursLength = #TopColours
local SelfColour = Color3.fromRGB(255, 68, 102)
local DefaultColour = Color3.fromRGB(6, 207, 201)
local PlayerTemplate = script.PlayerTemplate

local PlayerContainer = script.Parent.Leaderboard.Content

local RequestLeaderboard = game.ReplicatedStorage.Remotes.RequestLeaderboard

local function updateLeaderboardGui()
	PlayerContainer:ClearAllChildren()
	
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft  = UDim.new(0, 05)
	padding.PaddingTop   = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 20)
	padding.Parent = PlayerContainer
	
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 10)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = PlayerContainer
	
	local leaderboard = RequestLeaderboard:InvokeServer()
	PlayerContainer.CanvasSize = UDim2.new(0, 0, 0, #leaderboard * (PlayerTemplate.AbsoluteSize.Y + 10) + 10)
	
	for position, data in ipairs(leaderboard) do
		local username = Players:GetNameFromUserIdAsync(data[1])
		local avatar = Players:GetUserThumbnailAsync(data[1], Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		local rating = data[2]
		local colour = TopColours[position] or DefaultColour

		local index = PlayerTemplate:Clone()
		if data[1] == LocalPlayer.UserId then index.BackgroundColor3 = SelfColour end
		index.Name = username
		index.Medal.ImageColor3 = colour
		index.Medal.Number.Text = position
		if position > TopColoursLength then index.Medal.Number.TextColor3 = Color3.new(0, 0, 0) end
		index.Username.Text = username
		index.Username.TextColor3 = colour
		index.Rating.Text = rating
		index.Rating.TextColor3 = colour
		index.Avatar.Ring.BackgroundColor3 = colour
		index.Avatar.Ring.Avatar.Image = avatar

		index.Parent = PlayerContainer
	end
end

repeat updateLeaderboardGui() until not wait(60)