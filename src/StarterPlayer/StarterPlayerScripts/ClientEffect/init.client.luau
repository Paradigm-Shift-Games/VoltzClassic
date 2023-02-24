local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage:WaitForChild("Events")
local EffectRemote = Events:WaitForChild("Effect")
local RegisteredEffects = {}
for _, ClientEffect in script:GetChildren() do
	RegisteredEffects[ClientEffect.Name] = require(ClientEffect)
end
local function OnEffectRequest(Effect, ...)
	if RegisteredEffects[Effect] then
		RegisteredEffects[Effect](...)
	else
		warn(Effect, "is not a valid effect!")
	end
end
EffectRemote.OnClientEvent:Connect(OnEffectRequest)