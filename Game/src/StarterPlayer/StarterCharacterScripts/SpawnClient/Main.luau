local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Stats = require(ReplicatedStorage.Stats.Structure)



local module = {}
local SpawnGuiAssets = ReplicatedFirst.RespawnGui
local SpawnRemote = ReplicatedStorage.Events.RequestSpawn
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local teleporting = false
local selectedSpawn
local Gui

LocalPlayer.CharacterAdded:Connect(function() camera.CameraType = Enum.CameraType.Custom end)

local function FocusCamera(spawnPad)
	local cameraPos = (spawnPad.Point.CFrame * CFrame.new(Vector3.new(0, 10, 20))).Position
	camera.CFrame = CFrame.new(cameraPos, spawnPad.Point.Position)
end

local function OnSpawnButtonClick(button)
	selectedSpawn = button.Spawn.Value
	FocusCamera(selectedSpawn)
end

local function OnConfirmButtonClick()
	if not selectedSpawn then return end
	SpawnRemote:FireServer(selectedSpawn)
end

local function UpdateButton(button)
	--Calculate Cost
	local cost
	if teleporting then
		cost = Stats.Spawn.TeleportConsumption
	else
		cost = Stats.Spawn.SpawnConsumption
	end
	
	--Update Meter
	local percent = math.clamp(button.Spawn.Value:WaitForChild("Charge").Value / cost, 0, 1)
	button.Fill.Position = UDim2.fromScale(0, 1 - percent)
	button.Fill.Size = UDim2.fromScale(1, percent)
end

local function UpdateGui()
	--Update Buttons
	for _, v in pairs(Gui.Spawns:GetChildren()) do
		if v.Name == "UIGridLayout" then continue end
		UpdateButton(v)
	end
	
	--Update Confirm Button  
	if selectedSpawn then 
		if selectedSpawn.Charge.Value >= Stats.Spawn.SpawnConsumption then
			Gui.Buttons.ConfirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			Gui.Buttons.ConfirmButton.bg2.ImageColor3 = Color3.fromRGB(85, 255, 255)
		else
			Gui.Buttons.ConfirmButton.TextColor3 = Color3.fromRGB(77, 77, 77)
			Gui.Buttons.ConfirmButton.bg2.ImageColor3 = Color3.fromRGB(53, 161, 161)
		end
	end
end

local function CreateSpawnButton(spawnPad)
	--TeamChecking
	local team = LocalPlayer.Team
	if spawnPad.Team.Value ~= team then return end

	--Build Button
	local function BuildButton()
		local spawnButton = SpawnGuiAssets.Spawn:Clone()
		spawnButton.Spawn.Value = spawnPad
		while spawnPad.Number.Value == 0 do wait() end
		spawnButton.Name, spawnButton.Number.Text = tostring(spawnPad.Number.Value), tostring(spawnPad.Number.Value)
		spawnButton.LayoutOrder = spawnPad.Number.Value
		spawnButton.MouseButton1Click:Connect(function() OnSpawnButtonClick(spawnButton) end)
		UpdateButton(spawnButton)
		spawnButton.Parent = Gui.Spawns
	end
	coroutine.wrap(BuildButton)()
end

local function BuildGui()
	Gui = SpawnGuiAssets.RespawnGui:Clone()
	for _, v in pairs(CollectionService:GetTagged("Spawn")) do CreateSpawnButton(v) end
	CollectionService:GetInstanceAddedSignal("Spawn"):Connect(function(spawnPad) CreateSpawnButton(spawnPad) end)
	CollectionService:GetInstanceRemovedSignal("Spawn"):Connect(function(spawnPad) local button = Gui.Spawns:FindFirstChild(tostring(spawnPad.Number.Value)):Destroy() end)
	Gui.Parent = LocalPlayer.PlayerGui
end

module.Enable = function()
	camera.CameraType = Enum.CameraType.Scriptable
	BuildGui()
	Gui.Buttons.ConfirmButton.MouseButton1Click:Connect(OnConfirmButtonClick)
	RunService:BindToRenderStep("SpawnDisplay", 255, UpdateGui)
end

return module
