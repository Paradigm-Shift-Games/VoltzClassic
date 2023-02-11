--Author: 4812571

local module = {}

local CollectionService = game:GetService("CollectionService")
local Electricity = require(game.ServerScriptService.Packages.Electricity.Interface)
local EffectService = require(game.ServerScriptService.Services.EffectService)
local Stats = require(game.ReplicatedStorage.Stats.Structure)
local objectStats = Stats[script.Name]
local objectData = {}

function onAdded(object)
	objectData[object] = {}
	objectData[object].NextConnectionTime = tick()
end

function onRemoved(object)
	objectData[object] = nil
end

function Raycast(object1, object2)
	local p1, p2 = object1.Point.Position, object2.Point.Position
	local ray = Ray.new(p1, p2 - p1)
	local part, pos, normal = workspace:FindPartOnRayWithIgnoreList(ray, {object1, object2})
	return part
end

function runObject(object, delta)
	--Cooldown
	if tick() < objectData[object].NextConnectionTime then return end
	objectData[object].NextConnectionTime = tick() + objectStats.Cooldown
	
	--Connect
	for _, v in pairs(CollectionService:GetTagged(script.Name)) do
		if object == v then continue end
		if Raycast(object, v) then continue end
		--Determine Direction and Transfer, 
		if Electricity.GetChargePercent(object) > Electricity.GetChargePercent(v) then
			--Percent Balancing Math
			local chargeTotal = Electricity.GetCharge(object) + Electricity.GetCharge(v)
			local storageTotal = Electricity.GetStorage(object) + Electricity.GetStorage(v)
			local targetConnectedCharge = (chargeTotal / storageTotal) * Electricity.GetStorage(v)
			local transferDifference = (targetConnectedCharge - Electricity.GetCharge(v)) / 2
			local flux = math.min(transferDifference, objectStats.TransferAmount)
			if flux < 0 then continue end
			Electricity.Transfer(object, v, flux)
			EffectService.FireEffect("TransceiverBeam", object.Point.Attachment, v.Point.Attachment)
		end
	end
end

module.Run = function(delta)
	for _, v in pairs(CollectionService:GetTagged(script.Name)) do
		runObject(v, delta)
	end
end

CollectionService:GetInstanceAddedSignal(script.Name):Connect(onAdded)
CollectionService:GetInstanceRemovedSignal(script.Name):Connect(onRemoved)

return module
