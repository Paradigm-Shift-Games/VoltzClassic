local Debris = game:GetService("Debris")

local module = {}

function module.Fire(attachment0, attachment1) 
	local beam = script.Beam:Clone()
	beam.Attachment0 = attachment0 
	beam.Attachment1 = attachment1
	beam.Parent = workspace.Effects
	Debris:AddItem(beam, 0.2)
end

return module
