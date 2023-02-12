local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage:WaitForChild("Events")
local EffectRemote = Events:WaitForChild("Effect")
local RegisteredEffects = {}
for _, module in ipairs(script:GetChildren()) do
	RegisteredEffects[module.Name] = require(module)
end
local function OnEffectRequest(Effect, ...)
	if RegisteredEffects[Effect] then
		RegisteredEffects[Effect](...)
	else
		warn(Effect, "is not a valid effect!")
	end
end
EffectRemote.OnClientEvent:Connect(OnEffectRequest)