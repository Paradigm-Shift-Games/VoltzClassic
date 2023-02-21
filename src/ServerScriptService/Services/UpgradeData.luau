local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpgradeData = {}

UpgradeData = {}

UpgradeData.Generate = function()
	for _, v in ipairs(ReplicatedStorage.Objects:GetChildren()) do
		local upgradeFolder = v:FindFirstChild("Upgrades")
		if upgradeFolder then
			UpgradeData[v.Name] = {}
			local upgradeState = Instance.new("NumberValue")
			local maxUpgrades = Instance.new("NumberValue")
			upgradeState.Name = "UpgradeState"
			maxUpgrades.Name = "MaxUpgrades"
			upgradeState.Value = 0
			maxUpgrades.Value = #v.Upgrades:GetChildren()
			upgradeState.Parent = v
			maxUpgrades.Parent = v
			for _, g in ipairs(v.Upgrades:GetChildren()) do
				local offset = v.PrimaryPart.CFrame:ToObjectSpace(g.PrimaryPart.CFrame)
				UpgradeData[v.Name][tonumber(g.Name)] = {model = g, offset = offset}
			end
			upgradeFolder.Name = v.Name
			upgradeFolder.Parent = ReplicatedStorage.Upgrades
		end
	end
end

function UpgradeData.GetUpgrade(model, upgradeNumber)
	return UpgradeData[model.Name][upgradeNumber]
end

return UpgradeData
