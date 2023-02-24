local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BuilderPushBeam = {}

function BuilderPushBeam.Create(attachment0, position)
	local effect = {}
	-- Create Attachment
	effect.attachment = Instance.new("Attachment")
	effect.attachment.Position = position
	effect.attachment.Parent = workspace.Origin
	
	-- Beam
	effect.beam = ReplicatedStorage:WaitForChild("Beams"):WaitForChild("BuilderPushBeam"):Clone()
	effect.beam.Attachment0 = attachment0
	effect.beam.Attachment1 = effect.attachment
	effect.beam.Parent = workspace.Effects
	
	-- UpdatePosition
	function effect.UpdatePosition(position)
		effect.attachment.Position = position
	end	
	
	-- Destructor
	function effect.End()
		effect.beam:Destroy()
	end
	
	return effect
end

return BuilderPushBeam
