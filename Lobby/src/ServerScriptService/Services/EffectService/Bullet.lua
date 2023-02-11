local EffectRemote = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Effect")
local module = {}

module.Fire = function(...) EffectRemote:FireAllClients(script.Name, ...) end

return module
