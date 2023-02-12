--Author: Styx

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Events = ReplicatedStorage:WaitForChild("Events")
local thrusterRemote = Events:WaitForChild("thruster")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or script.Parent
local jetpack = character:WaitForChild("Backpack")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local JetpackEvent = game.ReplicatedStorage.Events.Jetpack
local localPlayer = Players.LocalPlayer
local maxThrustTime = 1.3
local currentThrustTime = 0
local lastThrustTime = 0
local accelerationRate = 17
local maxAcceleration = 17
local timeJumped = 0
local rechargePower = 2
local totalConsumption = 6
local timeStarted = 0
local isInAir = false
local spacePressed = true 
local effectState = false


local function getData()
	return maxThrustTime, currentThrustTime
end

local function effects(isEnabled)
	if effectState ~= isEnabled then
		if effectState == true then
			currentThrustTime = currentThrustTime + .1
		end
		thrusterRemote:FireServer(isEnabled)
		effectState = isEnabled
	end
end

local function onRenderStepped(delta)
	local consumption
	if RunService:IsStudio() then
		consumption = 0
	else
		consumption = delta * (totalConsumption / maxThrustTime)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) and isInAir and spacePressed and not (currentThrustTime > maxThrustTime) and tick()-timeJumped >= .25 and jetpack.Charge.Value >= consumption then
		JetpackEvent:FireServer(consumption)
		effects(true)
		currentThrustTime = currentThrustTime + delta
		local currentVelocity = humanoidRootPart.Velocity
		local xVelocity, yVelocity, zVelocity = currentVelocity.X, currentVelocity.Y, currentVelocity.Z
		humanoidRootPart.Velocity = Vector3.new(xVelocity, math.min(yVelocity+(accelerationRate*math.min(tick()-timeStarted, 1)), maxAcceleration), zVelocity)
		lastThrustTime = tick()
	elseif tick() - lastThrustTime > .15 and not isInAir then
		currentThrustTime = math.max(currentThrustTime-(delta* rechargePower), 0)
	else
		effects(false)
	end
end

local function onHumanoidStateChanged(oldState, newState)
	if newState == Enum.HumanoidStateType.Freefall then
		spacePressed = false
		isInAir = true
	elseif newState == Enum.HumanoidStateType.Jumping then
		timeJumped = tick()
	else
		isInAir = false
		effects(false)
	end
end

local function onInputBegan(input)
	if input.KeyCode == Enum.KeyCode.Space and spacePressed == false then
		spacePressed = true
		timeStarted = tick()
	end
end

UserInputService.InputBegan:Connect(onInputBegan)
humanoid.StateChanged:Connect(onHumanoidStateChanged)
RunService:BindToRenderStep("jetpack", 200, onRenderStepped)
script.Function.OnInvoke = getData