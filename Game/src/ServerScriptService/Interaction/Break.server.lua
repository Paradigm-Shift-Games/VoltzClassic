--Author: 4812571

local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ActionService = require(game.ServerScriptService.Services.ActionService)
local DamageService = require(game.ServerScriptService.Services.DamageService)
local StructureUtil = require(game.ReplicatedStorage.StructureUtility)
local MouseData = require(game.ServerScriptService.MouseData)
local InteractRange = 30
local Multiplier = 400
local players = {}

function Run(delta)
	for v, _ in pairs(players) do
		local part, position, normal = MouseData.GetMouse(v)
		local target = StructureUtil.GetModel(part)
		if not target then return nil end
		if (CollectionService:HasTag(target, "Structure") or CollectionService:HasTag(target, "Blueprint")) and v.Team ~= target.Team.Value then return end
		if v:DistanceFromCharacter(position) > InteractRange then return end
		if target.Name == "Cap" then DamageService.Damage(target, delta * Multiplier * 5, "BuilderBreak") continue end
		DamageService.Damage(target, delta * Multiplier, "BuilderBreak")
	end
end	

ActionService.Bind("Break", function(player, state) if state == true then players[player] = true else players[player] = nil end end)
RunService.Heartbeat:Connect(Run)