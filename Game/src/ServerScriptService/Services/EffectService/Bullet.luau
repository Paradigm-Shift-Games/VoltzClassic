local EffectRemote = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("Effect")
local module = {}

module.Fire = function(...) EffectRemote:FireAllClients(script.Name, ...) end

return module
