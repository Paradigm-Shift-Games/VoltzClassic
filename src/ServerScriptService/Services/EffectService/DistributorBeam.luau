local DistributorBeam = {}

function DistributorBeam.Create(attachment0, attachment1)
	local effect = {}
	--Beam
	effect.beam = script.Beam:Clone()
	effect.beam.Attachment0 = attachment0 
	effect.beam.Attachment1 = attachment1
	effect.beam.Parent = workspace.Effects
	
	--Change Color
	function effect.SetColor(colorSequence)
		effect.beam.Color = colorSequence
	end
	
	--Destructor
	effect.End = function()
		effect.beam:Destroy()
	end
	
	return effect
end

return DistributorBeam
