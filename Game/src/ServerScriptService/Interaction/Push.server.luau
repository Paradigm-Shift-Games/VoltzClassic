-- Author: 4812571

local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local MouseData = require(ServerScriptService.MouseData)
local StructureUtil = require(ReplicatedStorage.StructureUtility)
local EffectService = require(ServerScriptService.Services.EffectService)
local ActionService = require(ServerScriptService.Services.ActionService)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)

local InteractRange = 30
local Multiplier = 30 *(RunService:IsStudio() and 1000 or 1) --n0pa
local beams = {} 
local tools = {}

function AddPlayer(player)
	if beams[player] then return end

	--Get Builder
	local builderTool = player.Character:FindFirstChild("Builder")
	if not builderTool then return end
	tools[player] = builderTool

	--Get Mouse
	local part, position, normal = MouseData.GetMouse(player)
	
	--Start Sound
	builderTool.PushSound.Playing = true
	
	--Create Effect
	local effectID = EffectService.CreateEffect("BuilderPushBeam", builderTool.Handle.Attachment, position)
	beams[player] = effectID
end

function RemovePlayer(player)
	if not beams[player] then return end

	--End Sound
	tools[player].PushSound.Playing = false

	--Remove Effect
	EffectService.EndEffect(beams[player])
	tools[player] = nil
	beams[player] = nil
end

function Run(delta)
	for player, effectID in pairs(beams) do
		local part, position, normal = MouseData.GetMouse(player)
		local builder = tools[player]
		local target = StructureUtil.GetModel(part)

		--Update Effect
		local handle = builder:FindFirstChild("Handle")
		if not handle then continue end
		
		local beamStartPosition = handle.Attachment.WorldPosition
		local beamDirection = (position - beamStartPosition)
		local beamDistance = beamDirection.Magnitude
		local beamUnit = beamDirection.Unit
		beamDirection = beamUnit * math.min(beamDistance, InteractRange)
		EffectService.SignalEffect(effectID, "UpdatePosition", beamStartPosition + beamDirection)

		--Checks
		if not target then continue end
		if not (player.Character and player.Character:FindFirstChild("Backpack")) then continue end
		if not (CollectionService:HasTag(target, "Blueprint") or CollectionService:HasTag(target, "Crystal") or part.Name == "RefillConsole") then continue end
		if target:FindFirstChild("Team") and player.Team ~= target.Team.Value then continue end
		if beamDistance > InteractRange then continue end

		--Transfer
		Electricity.Transfer(player.Character.Backpack, target, delta * Multiplier)
		if Electricity.GetChargePercent(player.Character.Backpack) == 0 then builder.ClickSound:Play() RemovePlayer(player) end
	end
end	

ActionService.Bind("Push", function(player, state) if state == true then AddPlayer(player) else RemovePlayer(player) end end)
RunService.Heartbeat:Connect(Run)