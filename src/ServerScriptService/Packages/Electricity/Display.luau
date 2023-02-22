local precision = 2
local precisionFactor = 10 ^ precision

local module = {}

function module.SetDisplay(Structure, amount)
	local amount = math.floor(amount * precisionFactor) / precisionFactor
	Structure.Display.Production.DisplayText.TextLabel.Text = tostring(amount).."/s"
end

return module
