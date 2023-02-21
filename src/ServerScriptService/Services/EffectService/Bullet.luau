local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EffectRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Effect")
local Bullet = {}

Bullet.Fire = function(...) EffectRemote:FireAllClients(script.Name, ...) end

return Bullet
