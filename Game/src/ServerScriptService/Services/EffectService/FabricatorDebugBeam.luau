local module = {}

module.Create = function(attachment, part)
	local effect = {}
	--Attachment
	effect.attachment = Instance.new("Attachment")
	effect.attachment.Name = "FabricatorAttachment"
	effect.attachment.Parent = part

	--Beam
	effect.beam = script.Beam:Clone()
	effect.beam.Attachment0 = attachment 
	effect.beam.Attachment1 = effect.attachment
	effect.beam.Parent = workspace.Effects

	--Change Color
	effect.SetColor = function(colorSequence)
		effect.beam.Color = colorSequence
	end

	--Destructor
	effect.End = function()
		effect.beam:Destroy()
		effect.attachment:Destroy()
	end
	return effect
end

return module
