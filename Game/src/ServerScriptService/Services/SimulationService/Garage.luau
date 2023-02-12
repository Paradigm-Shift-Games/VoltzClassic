-- Author: NPA

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Stats = require(ReplicatedStorage.Stats.Structure)
local ButtonService = require(ServerScriptService.Services.ButtonService)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)





local module = {}

local objectStats = Stats[script.Name]
local bargeRoot = workspace.Extras:WaitForChild("barge")
local spawnHeight = 7
local objectData = {}

function onAdded(object)
	objectData[object] = {}
	
	ButtonService.Bind(object, object.Button, function() spawnBarge(object) end)
end

function onRemoved(object)
	objectData[object] = nil
end


function spawnBarge(object)
	if not Electricity.Pull(object, objectStats.Consumption) then return end
	
	local newBarge = bargeRoot:Clone()
	newBarge:SetPrimaryPartCFrame(object.Spawner.CFrame * CFrame.new(0, spawnHeight, 0))
	newBarge.Parent = workspace.Structures
	
	CollectionService:AddTag(newBarge, "Barge")
end



CollectionService:GetInstanceAddedSignal(script.Name):Connect(onAdded)
CollectionService:GetInstanceRemovedSignal(script.Name):Connect(onRemoved)

return module
