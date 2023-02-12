-- Author: 4812571

local Main = require(script:WaitForChild("Main"))

local Humanoid = script.Parent:WaitForChild("Humanoid")

local function OnDeath()
	Main.Enable()
end

Humanoid.Died:Connect(OnDeath)
