--Author: 4812571

local module = {}
local Colorizer = require(game.ServerScriptService.Services.Colorizer)
local CollectionService = game:GetService("CollectionService")
local Stats = require(game.ReplicatedStorage.Stats.Structure)
local AssemblyService = require(game.ServerScriptService.Services.AssemblyService)
local Electricity = require(game.ServerScriptService.Packages.Electricity.Interface)
local StructureUtil = require(game.ReplicatedStorage.StructureUtility)

function PromoteUpgrade(Object)
	--Clear Blueprint Data
	CollectionService:RemoveTag(Object, "Blueprint")
	CollectionService:RemoveTag(Object, "NoLeaks")
	Colorizer.RevertColors(Object)
	
	--Clear Blueprint Electrical Data
	Electricity.RemoveStructure(Object)

	--Add New Electrical Data
	Electricity.AddStructure(Object)
	Electricity.ConnectStructures(Object, Object.UpgradeRoot.Value)
	
	--Handle Upgrade
	AssemblyService.SetAttachmentType(Object, "Merge")
	Object.UpgradeRoot.Value.Upgrading:Destroy()	
	
	--Add New Tags
	CollectionService:AddTag(Object, "Structure")
	CollectionService:AddTag(Object, Object.Name)
	if Stats[Object.Name].Tags then for _, v in pairs(Stats[Object.Name].Tags) do CollectionService:AddTag(Object, v) end end
end

module.Promote = function(Object)	
	--Offload Upgrades
	if CollectionService:HasTag(Object, "Upgrade") then PromoteUpgrade(Object) return end
	
	--Clear Blueprint Data
	CollectionService:RemoveTag(Object, "Blueprint")
	CollectionService:RemoveTag(Object, "NoLeaks")
	Colorizer.RevertColors(Object)
	
	--Clear Blueprint Electrical Data
	Electricity.RemoveStructure(Object)
	
	--Insert Health
	local health = Instance.new("NumberValue")
	health.Name = "Health"
	health.Value = Stats[Object.Name].Health
	health.Parent = Object
	
	--Handle Connectors
	local connectors = {}
	for _, v in pairs(Object:GetChildren()) do
		if v.Name == "Snaps" or v.Name == "Connectors" then
			for _, g in pairs(v:GetChildren()) do
				g.Name = string.gsub(g.Name, "Disabled", "")
				if g.Name == "Connector" then table.insert(connectors, g) end
			end
		end 	
	end	
	
	--Add New Electrical Data
	if #connectors > 0 then
		Electricity.AddStructure(Object)

		for _, v in pairs(connectors) do
			local otherStructure = StructureUtil.GetModel(v.Object.Value)
			if otherStructure and CollectionService:HasTag(otherStructure, "Structure") then
				Electricity.ConnectStructures(Object, otherStructure)
			end
		end
	end
	
	--Add New Tags
	CollectionService:AddTag(Object, "Structure")
	CollectionService:AddTag(Object, Object.Name)
end

return module