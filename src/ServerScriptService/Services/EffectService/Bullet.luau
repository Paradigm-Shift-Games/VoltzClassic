local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EffectRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Effect")
local module = {}

module.Fire = function(...) EffectRemote:FireAllClients(script.Name, ...) end

return module
