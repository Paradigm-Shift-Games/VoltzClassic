local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local function onArsenalTagAdded(Arsenal)
	local mainPart = Arsenal:WaitForChild("mainPart")
	local ScreenPart = mainPart:WaitForChild("screenPart")
	local uiMain = ScreenPart:WaitForChild("uiMain")
	local OriginalArsenalValue = uiMain:WaitForChild("OriginalArsenal")
	OriginalArsenalValue.Value = Arsenal
	uiMain.Parent = Players.LocalPlayer.PlayerGui
end
CollectionService:GetInstanceAddedSignal("Arsenal"):Connect(onArsenalTagAdded)
for _, Arsenal in ipairs(CollectionService:GetTagged("Arsenal")) do
	onArsenalTagAdded(Arsenal)
end