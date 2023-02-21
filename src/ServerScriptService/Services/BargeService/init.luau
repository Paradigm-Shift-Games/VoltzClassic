-- Author: Styx

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage:WaitForChild("Events")
local bargeEvent = Events:WaitForChild("Barge")
local HeightPerLevel = 10
local HeightDecreasePerSecond = 10 --1
local BargeService = {}
local currentBargeData = {}
local function onOccupantChanged(barge, NewOccupant)
	if NewOccupant then
		local Player = Players:GetPlayerFromCharacter(NewOccupant.Parent)
		currentBargeData[barge].Occupant = Player
		barge.PrimaryPart:SetNetworkOwner(Player)--Very important so that the client can set the velocity
	else
		currentBargeData[barge].Occupant = nil
		barge.PrimaryPart:SetNetworkOwner(nil)--Make it so no one can set the velocity anymore :D because no one is sitting in it
		--Network ownership
		--https://developer.roblox.com/en-us/articles/Network-Ownership
	end
end
local maxForce = Vector3.new(0, 5000000, 0)
local function onBargeTagAdded(Barge)
	local BodyMover = Instance.new("BodyPosition");
	BodyMover.Parent = Barge.PrimaryPart
	BodyMover.MaxForce = maxForce;
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.Parent = Barge.PrimaryPart
	currentBargeData[Barge] = {
		Occupant = nil;
		CurrentHoverHeight = 1;
		BodyMover = BodyMover;
		CastParts = Barge:WaitForChild("castParts"):GetChildren()
	}
	local DriversSeat = Barge:WaitForChild("DriversSeat")
	DriversSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
		onOccupantChanged(Barge, DriversSeat.Occupant)
	end)
end
local function onBargeTagRemoved(Barge)
	currentBargeData[Barge] = nil
end
function BargeService.OnServerEvent(player, barge, isGoingUp)
	if currentBargeData[barge] and currentBargeData[barge].Occupant == player then
		local amount = 0
		if isGoingUp then
			amount = 1
		else
			amount = -1
		end
		currentBargeData[barge].CurrentHoverHeight = math.clamp(currentBargeData[barge].CurrentHoverHeight + amount, 0, 3)
	end
end
local down = Vector3.new(0, -1, 0)
local baseHighestPosition = Vector3.new(0, -5000, 0)
local function onHeartBeat(delta)
	for barge, data in pairs(currentBargeData) do
		local thisPosition = barge.PrimaryPart.Position
		local direction = down*(data.CurrentHoverHeight*HeightPerLevel)
		if data.CurrentHoverHeight ~= 0 then
			local highestPosition = baseHighestPosition
			local didFindAPosition = false
			for _, castPart in ipairs(data.CastParts) do
				local newRay = Ray.new(castPart.Position, direction)
				local foundPart, pos = workspace:FindPartOnRay(newRay, barge)
				if foundPart and foundPart:IsGrounded()then
					if pos.Y > highestPosition.Y then
						highestPosition = pos
						didFindAPosition = true
					end
				elseif foundPart ~= nil and foundPart.Name == "Terrain" then
					if pos.Y > highestPosition.Y then
						highestPosition = pos
						didFindAPosition = true
					end
				end
			end
			data.BodyMover.MaxForce = maxForce
			if didFindAPosition then
				data.BodyMover.Position = highestPosition - direction
			else
				data.BodyMover.Position = Vector3.new(0, data.BodyMover.Position.Y-(delta*HeightDecreasePerSecond), 0)
			end
		else
			data.BodyMover.MaxForce = Vector3.new()--Make it not control the barge physics anymore!
		end
	end
end
RunService.Heartbeat:Connect(onHeartBeat)
--Your code errors too much, please fix it. <3 - 4812571
CollectionService:GetInstanceAddedSignal("Barge"):Connect(onBargeTagAdded)
CollectionService:GetInstanceRemovedSignal("Barge"):Connect(onBargeTagRemoved)
bargeEvent.OnServerEvent:Connect(BargeService.OnServerEvent)
return BargeService