--Author: 4812571

--Initialization
local tweenService = game:GetService("TweenService")
local Lobby = workspace:WaitForChild("Lobby")
local Pods = Lobby:WaitForChild("Pods")
local doors, doorStateInternal, doorStateExternal, doorPositionStates = {}, {}, {}, {}
local doorOpenOffset = CFrame.new(2.25, 0, 0)

--Initialize the doors table, doorIsClosed table and doorPositionStates table
for _, door in pairs(workspace.Lobby.Doors:GetChildren()) do
	local index = tonumber(door.Name)
	doors[index] = {outerDoor = door, innerDoor = nil}
	local innerDoor = Pods:FindFirstChild(door.Name):WaitForChild("Door")
	doors[index].innerDoor = innerDoor
	doorStateInternal[index] = true
	doorStateExternal[index] = true
	doorPositionStates[index] =  {[false] = {}, [true] = {}}
	local doorParts = innerDoor:GetChildren()
	for _,v in pairs(door:GetChildren()) do
		table.insert(doorParts, v)
	end
	--Get the closed door CFrame and opened door CFrame
	for _, doorPart in pairs(doorParts) do 
		if doorPart.Name ~= "Button" then
			for _, part in pairs(doorPart:GetChildren()) do
				doorPositionStates[index][true][part] = part.CFrame
				doorPositionStates[index][false][part] = part.CFrame * doorOpenOffset
			end
		end
	end
end

--changeDoorState(index, state) Where state represents the state of the door being closed.
local function changeDoorState(index, state)
	--State Debounce
	if state == doorStateInternal[index] then return end
	
	
	--Tween Handling
	local tweens = {}
	for part, cframeInfo in pairs(doorPositionStates[index][state]) do
		table.insert(tweens, 
			tweenService:Create(part, TweenInfo.new(1), {CFrame = cframeInfo})
		)
	end
	
	--Play all tweens
	for _, tween in pairs(tweens) do
		tween:Play()
	end
	
	--State Handling
	doorStateInternal[index] = state
	local delayTime = (state == false) and 1 or 0
	delay(DateTime, function() doorStateExternal[index] = state end)
	Pods[tostring(index)].Door.Button:WaitForChild("Enabled").Value = state
end

function ParseInput(input)
	if type(input) == "number" then return input end
	if type(input) ==  "userdata" then
		if input:IsA("Team") then  return tonumber(input:FindFirstChild("Pod").Value.Name) end
		if input:IsA("Model") then return tonumber(input.Name) end
	end
end

--Actual module
local DoorService = {}

DoorService.OpenDoor = function(input)
	local index = ParseInput(input)
	changeDoorState(index, false)
end

DoorService.CloseDoor = function(input)
	local index = ParseInput(input)
	changeDoorState(index, true)
end

DoorService.ToggleDoorState = function(input)
	local index = ParseInput(input)
	changeDoorState(index, not doorStateInternal[index])
end

DoorService.IsDoorClosed = function(input)
	local index = ParseInput(input)
	return doorStateExternal[index]
end

DoorService.IsDoorOpen = function(input)
	local index = ParseInput(input)
	return not doorStateExternal[index]
end

return DoorService