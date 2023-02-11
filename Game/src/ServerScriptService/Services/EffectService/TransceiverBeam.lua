local DebrisService = game:GetService("Debris")
local module = {}

module.Fire = function(attachment0, attachment1) 
	local beam = script.Beam:Clone()
	beam.Attachment0 = attachment0 
	beam.Attachment1 = attachment1
	beam.Parent = workspace.Effects
	DebrisService:AddItem(beam, 0.2)
end

return module
