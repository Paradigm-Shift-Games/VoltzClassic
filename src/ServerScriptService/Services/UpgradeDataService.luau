local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpgradeDataService = {}

UpgradeDataService = {}

function UpgradeDataService:Start()
	for _, v in ipairs(ReplicatedStorage.Objects:GetChildren()) do
		local upgradeFolder = v:FindFirstChild("Upgrades")
		if upgradeFolder then
			UpgradeDataService[v.Name] = {}
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
				UpgradeDataService[v.Name][tonumber(g.Name)] = {model = g, offset = offset}
			end
			upgradeFolder.Name = v.Name
			upgradeFolder.Parent = ReplicatedStorage.Upgrades
		end
	end
end

function UpgradeDataService.GetUpgrade(model, upgradeNumber)
	return UpgradeDataService[model.Name][upgradeNumber]
end

return UpgradeDataService
