local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TeslaBeam = {}

function TeslaBeam.Create(attachment, part)
	local effect = {}
	-- Attachment
	effect.attachment = Instance.new("Attachment")
	effect.attachment.Name = "FabricatorAttachment"
	effect.attachment.Parent = part

	-- Beam
	effect.beam = ReplicatedStorage:WaitForChild("Beams"):WaitForChild("TeslaBeam"):Clone()
	effect.beam.Attachment0 = attachment 
	effect.beam.Attachment1 = effect.attachment
	effect.beam.Parent = workspace.Effects

	-- Destructor
	function effect.End()
		effect.beam:Destroy()
		effect.attachment:Destroy()
	end
	return effect
end

return TeslaBeam
