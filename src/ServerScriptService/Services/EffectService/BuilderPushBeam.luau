local module = {}

function module.Create(attachment0, position)
	local effect = {}
	--Create Attachment
	effect.attachment = Instance.new("Attachment")
	effect.attachment.Position = position
	effect.attachment.Parent = workspace.Origin
	
	--Beam
	effect.beam = script.Beam:Clone()
	effect.beam.Attachment0 = attachment0
	effect.beam.Attachment1 = effect.attachment
	effect.beam.Parent = workspace.Effects
	
	--UpdatePosition
	function effect.UpdatePosition(position)
		effect.attachment.Position = position
	end	
	
	--Destructor
	effect.End = function()
		effect.beam:Destroy()
	end
	
	return effect
end

return module
