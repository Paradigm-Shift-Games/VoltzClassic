local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EffectRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Effect")
local Bullet = {}

function Bullet.Fire(...) EffectRemote:FireAllClients(script.Name, ...) end

return Bullet
