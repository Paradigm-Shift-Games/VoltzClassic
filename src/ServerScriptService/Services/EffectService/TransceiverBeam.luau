local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Debris = game:GetService("Debris")

local TransceiverBeam = {}

function TransceiverBeam.Fire(attachment0, attachment1) 
	local beam = ReplicatedStorage:WaitForChild("Beams"):WaitForChild("TransceiverBeam"):Clone()
	beam.Attachment0 = attachment0 
	beam.Attachment1 = attachment1
	beam.Parent = workspace.Effects
	Debris:AddItem(beam, 0.2)
end

return TransceiverBeam
