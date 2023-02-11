--Author: 4812571


local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Electricity = require(game.ServerScriptService.Packages.Electricity.Interface)
local EffectService = require(game.ServerScriptService.Services.EffectService)
local ActionService = require(game.ServerScriptService.Services.ActionService)
local StructureUtil = require(game.ReplicatedStorage.StructureUtility)
local MouseData = require(game.ServerScriptService.MouseData)
local InteractRange = 30
local Multiplier = 30 * (RunService:IsStudio() and 1000 or 1) --n0pa
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
	builderTool.PullSound.Playing = true
	
	--Create Effect
	local effectID = EffectService.CreateEffect("BuilderPullBeam", builderTool.Handle.Attachment, position)
	beams[player] = effectID
end

function RemovePlayer(player)
	if not beams[player] then return end
	
	--End Sound
	tools[player].PullSound.Playing = false
	
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
		local beamStartPosition = builder.Handle.Attachment.WorldPosition
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
		Electricity.Transfer(target, player.Character.Backpack, delta * Multiplier)

		--Check Full
		if Electricity.GetChargePercent(player.Character.Backpack) == 1 then builder.ClickSound:Play() RemovePlayer(player) end
	end
end	

ActionService.Bind("Pull", function(player, state) if state == true then AddPlayer(player) else RemovePlayer(player) end end)
RunService.Heartbeat:Connect(Run)