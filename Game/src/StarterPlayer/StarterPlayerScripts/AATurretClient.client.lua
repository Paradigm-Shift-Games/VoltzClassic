--Author n0pa

local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")
local AATurretRemote = Events:WaitForChild("AATurretRemote")

local AATurretData = {}

local currentAATurret = nil

-- These are multipliers for the summed net rotations on the server, using 0 and 1 because LUA does not support boolean arithmetic
local PitchRotationArray = { 
	[1] = 0; --Pitch Up 1
	[2] = 0; --Pitch Down -1
}

local YawRotationArray = {
	[1] = 0; --Yaw Right -1
	[2] = 0; --Yaw Left 1
}

-- These are the keys that access the rotations
local PitchKeys = {
	[Enum.KeyCode.W] = 1; --RotationArray index stored with each key
	[Enum.KeyCode.S] = 2; --Allows for multiple keys to have same rotation
}

local YawKeys = {
	[Enum.KeyCode.D] = 1;
	[Enum.KeyCode.A] = 2;
}

local function onPitchKeyDown(name, inputState, inputObject)
	local rotationIndex = PitchKeys[inputObject.KeyCode]
	
	if rotationIndex == nil then return end
	
	PitchRotationArray[rotationIndex] = (inputState ~= Enum.UserInputState.End and 1) or 0
		
	AATurretRemote:FireServer(currentAATurret, "Pitch", PitchRotationArray)
end

local function onYawKeyDown(name, inputState, inputObject)
	local rotationIndex = YawKeys[inputObject.KeyCode]
	
	if rotationIndex == nil then return end
	
	YawRotationArray[rotationIndex] = (inputState ~= Enum.UserInputState.End and 1) or 0
	
	AATurretRemote:FireServer(currentAATurret, "Yaw", YawRotationArray)
end

local function onFireKey(name, inputState, inputObject)
	if inputState ~= Enum.UserInputState.Begin then return end
	AATurretRemote:FireServer(currentAATurret, "Fire")
end

local function bindControlKeys()
	warn("Binding Control Keys!")
	for yawKey, _ in pairs(YawKeys) do
		ContextActionService:BindAction("AATurretYaw-"..tostring(yawKey), onYawKeyDown, false, yawKey)
	end
	
	for pitchKey, _ in pairs(PitchKeys) do
		ContextActionService:BindAction("AATurretPitch-"..tostring(pitchKey), onPitchKeyDown, false, pitchKey)
	end
	ContextActionService:BindAction("AATurretFire", onFireKey, false, Enum.UserInputType.MouseButton1)
end

local function unbindControlKeys()
	warn("Unbinding Control Keys!")
	for yawKey, _ in pairs(YawKeys) do
		ContextActionService:UnbindAction("AATurretYaw-"..tostring(yawKey))
	end
	
	for pitchKey, _ in pairs(PitchKeys) do
		ContextActionService:UnbindAction("AATurretPitch-"..tostring(pitchKey))
	end
	ContextActionService:UnbindAction("AATurretFire")
end

local function onAATurretTagAdded(AATurret)
	warn("AATurret ADDED", AATurret)
	
	AATurretData[AATurret] = true
	
	local Head = AATurret:WaitForChild("Head")
	local Seat = Head:WaitForChild("Seat")
	
	local function onOccupancyChanged()
		if AATurret == currentAATurret then
			unbindControlKeys()
			currentAATurret = nil --We obviously aren't in this AATurret anymore. -Styx
			return
		end
		
		local Humanoid = Seat.Occupant
		if not Humanoid then return end
			
		local player = game.Players:GetPlayerFromCharacter(Humanoid.Parent)
		if player ~= game.Players.LocalPlayer then return end
				
		currentAATurret = AATurret
		bindControlKeys()	
	end
	
	Seat:GetPropertyChangedSignal("Occupant"):Connect(onOccupancyChanged)
end

local function onArtileryTagRemoved(Object)
	warn("AATurret REMOVED", Object)
	
	AATurretData[Object] = nil
end

CollectionService:GetInstanceAddedSignal("AATurret"):Connect(onAATurretTagAdded)
CollectionService:GetInstanceRemovedSignal("AATurret"):Connect(onArtileryTagRemoved)

for _,v in ipairs(CollectionService:GetTagged("AATurret")) do
	onAATurretTagAdded(v)
end
