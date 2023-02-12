-- Author: n0pa

local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerScriptService:WaitForChild("Services"):WaitForChild("ButtonService") = game:GetService("ServerScriptService:WaitForChild("Services"):WaitForChild("ButtonService")")

local ArsenalHeiarchy = require(ReplicatedStorage.ArsenalWeapons)
local StructureUtil = require(ReplicatedStorage.StructureUtility)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)
local ButtonService = require(ServerScriptService:WaitForChild("Services"):WaitForChild("ButtonService"))

--This code is going to be changed -Styx
local Events = ReplicatedStorage:WaitForChild("Events")
local uiMain = script:WaitForChild("uiMain")
local button = uiMain:WaitForChild("container"):WaitForChild("CategoryContainer"):WaitForChild("1"):Clone()
local ArsenalButtonRemote = Events:WaitForChild("ArsenalButton")

local ArsenalData = {} --Arsenal models as keys, table data as values

local ArsenalService = {}

local onArsenalTagAdded = function(arsenal)
	ArsenalData[arsenal] = {
		CurrentlyProducingWeapon = nil; --nil | weapon model
		TimeToProduce = 0; -- 0 | weapon's timeToProduce
		CurrentProductionTime = 0; --time from start of production
		CurrentTween = nil;
	}
end

local onArsenalTagRemoved = function(arsenal)
	ArsenalData[arsenal] = nil
end

local onHeartBeat = function(delta)
	for arsenal, data in pairs(ArsenalData) do
		if arsenal.Parent == nil or data == nil then continue end
		if not data.CurrentlyProducing or data.CurrentProductionTime >= data.TimeToProduce then continue end
		
		data.CurrentProductionTime += delta
		
		if data.CurrentProductionTime < data.TimeToProduce then continue end
		
		local rotationPart = arsenal:WaitForChild("Rotation")
		local buttonPart = rotationPart:WaitForChild("button")
		local hinge = rotationPart:WaitForChild("HingeMotor")
		
		buttonPart.Text.Value = data.CurrentlyProducing.Name
		
		TweenService:Create(hinge, TweenInfo.new(1), {
			C1 = CFrame.Angles(0, 0, math.rad(180))
		}):Play()
		
		local onButtonClick = function(player)
			local newTool = data.CurrentlyProducing:Clone()
			newTool.Parent = player.Backpack
			arsenal:WaitForChild(newTool.Name):Destroy()
			
			data.CurrentlyProducing = nil
			data.CurrentProductionTime = 0
			ButtonService.UnBind(buttonPart)
			
			TweenService:Create(hinge, TweenInfo.new(1), {
				C1 = CFrame.Angles(0, 0, 0)
			}):Play()
		end
		ButtonService.Bind(arsenal, buttonPart, onButtonClick)
	end
end

ArsenalService.ButtonInteraction = function(player, button)
	local uiContainer = button.Parent.Parent
	local arsenal = StructureUtil.GetModel(button)
	--if not arsenal then return end--
	local container = button.Parent
	local selectedCategoryValue = uiContainer.Parent:WaitForChild("SelectedCategory", 0.1) or Instance.new("StringValue")
	
	local buttonID = tonumber(button.Name)
	
	if not selectedCategoryValue then return end
	
	if container.Name == "CategoryContainer" then
		local weaponContainer = uiContainer:WaitForChild("WeaponContainer")
		
		for _, weaponContainerChild in ipairs(weaponContainer:GetChildren()) do			
			if weaponContainerChild:IsA("TextButton") then				
				weaponContainerChild:Destroy() 
			end
		end
		
		selectedCategoryValue.Value = buttonID
				
		for gunName, gunData in ipairs(ArsenalHeiarchy[buttonID]) do
			local newButton = button:Clone()
			newButton.Text = gunData.text
			newButton.Parent = weaponContainer
			newButton.Name = gunName			
		end
	elseif container.Name == "WeaponContainer" and ArsenalData[arsenal].CurrentlyProducing == nil then
		local requestedWeapon = ArsenalHeiarchy[tonumber(selectedCategoryValue.Value)][buttonID]
		
		if not requestedWeapon then return end
		if not Electricity.Pull(arsenal, requestedWeapon.cost) then return end
		
		local newWeaponTemplate = requestedWeapon.weaponModel:Clone()
		local newModel = Instance.new("Model")
		
		for _, newWeaponChildren in ipairs(newWeaponTemplate:GetChildren()) do
			newWeaponChildren.Parent = newModel
		end
		
		newWeaponTemplate:Destroy() -- move children from template to model
		
		local handle = newModel:WaitForChild("Handle")
		local weld = Instance.new("WeldConstraint")
		local rotPart = arsenal.Rotation.weldPart
		
		newModel.PrimaryPart = handle
		newModel:SetPrimaryPartCFrame(rotPart.CFrame)
		newModel.Name = requestedWeapon.weaponModel.Name
		newModel.Parent = arsenal
		
		weld.Parent = handle
		weld.Part0 = handle
		weld.Part1 = rotPart
		
		local arsenalData = ArsenalData[arsenal]
		arsenalData.CurrentlyProducing = requestedWeapon.weaponModel
		arsenalData.TimeToProduce = requestedWeapon.timeToProduce
		--arsenalData.CurrentTime = 0
	end
end

game:GetService("RunService").Heartbeat:Connect(onHeartBeat)

CollectionService:GetInstanceAddedSignal("Arsenal"):Connect(onArsenalTagAdded)
CollectionService:GetInstanceRemovedSignal("Arsenal"):Connect(onArsenalTagRemoved)

ArsenalButtonRemote.OnServerEvent:Connect(ArsenalService.ButtonInteraction)

return ArsenalService