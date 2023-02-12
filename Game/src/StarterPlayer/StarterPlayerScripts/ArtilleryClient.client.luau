-- Author n0pa

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")




local Events = ReplicatedStorage:WaitForChild("Events")
local ArtilleryRemote = Events:WaitForChild("ArtilleryRemote")

local ArtilleryData = {}

local currentArtillery = nil

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
		
	ArtilleryRemote:FireServer(currentArtillery, "Pitch", PitchRotationArray)
end

local function onYawKeyDown(name, inputState, inputObject)
	local rotationIndex = YawKeys[inputObject.KeyCode]
	
	if rotationIndex == nil then return end
	
	YawRotationArray[rotationIndex] = (inputState ~= Enum.UserInputState.End and 1) or 0
	
	ArtilleryRemote:FireServer(currentArtillery, "Yaw", YawRotationArray)
end

local function onFireKey(name, inputState, inputObject)
	if inputState ~= Enum.UserInputState.Begin then return end
	ArtilleryRemote:FireServer(currentArtillery, "Fire")
end

local function bindControlKeys()
	warn("Binding Control Keys!")
	for yawKey, _ in pairs(YawKeys) do
		ContextActionService:BindAction("ArtilleryYaw-"..tostring(yawKey), onYawKeyDown, false, yawKey)
	end
	
	for pitchKey, _ in pairs(PitchKeys) do
		ContextActionService:BindAction("ArtilleryPitch-"..tostring(pitchKey), onPitchKeyDown, false, pitchKey)
	end
	ContextActionService:BindAction("ArtilleryFire", onFireKey, false, Enum.UserInputType.MouseButton1)
end

local function unbindControlKeys()
	warn("Unbinding Control Keys!")
	for yawKey, _ in pairs(YawKeys) do
		ContextActionService:UnbindAction("ArtilleryYaw-"..tostring(yawKey))
	end
	
	for pitchKey, _ in pairs(PitchKeys) do
		ContextActionService:UnbindAction("ArtilleryPitch-"..tostring(pitchKey))
	end
	ContextActionService:UnbindAction("ArtilleryFire")
end

local function onArtilleryTagAdded(artillery)
	ArtilleryData[artillery] = true
	
	local Head = artillery:WaitForChild("Head")
	local Seat = Head:WaitForChild("Seat")
	
	local function onOccupancyChanged()
		if artillery == currentArtillery then
			unbindControlKeys()
			currentArtillery = nil --We obviously aren't in this artillery anymore. -Styx
			return
		end
		
		local Humanoid = Seat.Occupant
		if not Humanoid then return end
			
		local player = Players:GetPlayerFromCharacter(Humanoid.Parent)
		if player ~= Players.LocalPlayer then return end
				
		currentArtillery = artillery
		bindControlKeys()	
	end
	
	Seat:GetPropertyChangedSignal("Occupant"):Connect(onOccupancyChanged)
end

local function onArtileryTagRemoved(Object)
	ArtilleryData[Object] = nil
end

CollectionService:GetInstanceAddedSignal("Artillery"):Connect(onArtilleryTagAdded)
CollectionService:GetInstanceRemovedSignal("Artillery"):Connect(onArtileryTagRemoved)

for _,v in ipairs(CollectionService:GetTagged("Artillery")) do
	onArtilleryTagAdded(v)
end
