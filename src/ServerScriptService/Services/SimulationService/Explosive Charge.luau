-- Author: 4812571

local ServerScriptService = game:GetService("ServerScriptService")

local DamageService = require(ServerScriptService.Services.DamageService)
local ExplosionService = require(ServerScriptService.Services.ExplosionService)

objectData = {}

function onAdded(object)
	objectData[object] = {timePlaced = tick()}	
end

function onRemoved(object)
	objectData[object] = nil
end

function runObject(object, delta)
	local timeSincePlace = tick() - objectData[object].timePlaced
	if timeSincePlace > 0 and timeSincePlace < 1 then object.Bomb.BrickColor = BrickColor.new("Lime green") end
	if timeSincePlace > 1 and timeSincePlace < 2 then object.Bomb.BrickColor = BrickColor.new("Br. yellowish orange") end
	if timeSincePlace > 2 and timeSincePlace < 3 then object.Bomb.BrickColor = BrickColor.new("Bright red") end	
	if timeSincePlace > 3 and timeSincePlace < 4 then
		print("Exploding")
		ExplosionService.Explode(object.Bomb.Position, 5, 350)
		DamageService.Destroy(object)
		objectData[object] = nil
		print("Exploded")
	end
end

local ExplosiveChargeServer = {}
ExplosiveChargeServer.__index = ExplosiveChargeServer

function ExplosiveChargeServer.new(instance)
	local self = setmetatable({}, ExplosiveChargeServer)
	self.Instance = instance

	-- Shim
	onAdded(instance)

	return self
end

function ExplosiveChargeServer:Update(deltaTime)
	-- Shim
	runObject(self.Instance, deltaTime)
end

function ExplosiveChargeServer:Destroy()
	-- Shim
	onRemoved(self.Instance)
end

return ExplosiveChargeServer
