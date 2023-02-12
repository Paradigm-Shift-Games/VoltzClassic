local RunService = game:GetService("RunService")

local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local mouse = localPlayer:GetMouse()
local contextUi = script:WaitForChild("ContextUi")
local hintDataFrame = contextUi:WaitForChild("hintData")
local contextTextLabel = hintDataFrame:WaitForChild("contentText")
local keyTextLabel = hintDataFrame:WaitForChild("keyText")
contextUi.Parent = playerGui
local mousexOffSet = 45
local mouseyOffset = 20
local Hints = {}
local HintOrder = {
	--Builder
	"Pull";
	"Push";
	"Destroy";
	"Upgrade";
	--Button
	"Button";
	--Placer
	"Place";
	"Cancel";
	"HardRotate";
	"SmoothRotate";
	"ChangeSnap";
}
local ContextHint = {}
local function updateGui()
	local keyText = ""
	local contentText = ""
	for _, tag in ipairs(HintOrder) do
		if Hints[tag] then--Append the text
			keyText = keyText..Hints[tag][1]..":\n"
			contentText = contentText..Hints[tag][2].."\n"
		end
	end
	
	contextTextLabel.Text = contentText
	keyTextLabel.Text = keyText
	hintDataFrame.Size = UDim2.new(0, contextTextLabel.TextBounds.X, 0, contextTextLabel.TextBounds.Y)--Resize the frame to account for the text
	hintDataFrame.Position = UDim2.new(0, mouse.X + mousexOffSet, 0, mouse.Y + mouseyOffset)
end
ContextHint.AddHint = function(name, Hint)
	Hints[name] = Hint
end
ContextHint.RemoveHint = function(name)
	Hints[name] = nil
end
RunService:BindToRenderStep("contextHint", 200, updateGui)
return ContextHint