local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FabricatorBeam = {}

function FabricatorBeam.Create(attachment, part)
	local effect = {}
	-- Attachment
	effect.attachment = Instance.new("Attachment")
	effect.attachment.Name = "FabricatorAttachment"
	effect.attachment.Parent = part
	
	-- Beam
	effect.beam = ReplicatedStorage:WaitForChild("Beams"):WaitForChild("FabricatorBeam"):Clone()
	effect.beam.Attachment0 = attachment 
	effect.beam.Attachment1 = effect.attachment
	effect.beam.Parent = workspace.Effects
	
	-- Change Color
	function effect.SetColor(colorSequence)
		effect.beam.Color = colorSequence
	end
	
	-- Destructor
	function effect.End()
		effect.beam:Destroy()
		effect.attachment:Destroy()
	end
	return effect
end

return FabricatorBeam
