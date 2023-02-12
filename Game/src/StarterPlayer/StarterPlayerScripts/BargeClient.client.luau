local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")

local Remotes = game.ReplicatedStorage:WaitForChild("Events")
local BargeRemote = Remotes:WaitForChild("Barge")
local LocalPlayer = game.Players.LocalPlayer
local localCharacter, localHumanoid
local currentBargePart, bodyPosition, driverSeat
local BargeSpeed = 48
local SteerSpeed = 2
local isEDown = false
local isQDown = false
local function onEKey(_, InputState, _)
	if InputState == Enum.UserInputState.Begin then
		isEDown = true
	end
end
local function onQKey(_, InputState, _)
	if InputState == Enum.UserInputState.Begin then
		isQDown = true
	end
end
local function onOccupantChange(bargeModel, newOccupant)
	if newOccupant ~= nil and game.Players:GetPlayerFromCharacter(newOccupant.Parent) == LocalPlayer then
		ContextActionService:BindAction("bargeUp", onEKey, false, Enum.KeyCode.E)
		ContextActionService:BindAction("bargeDown", onQKey, false, Enum.KeyCode.Q)
		currentBargePart = bargeModel.PrimaryPart
		bodyPosition = currentBargePart:WaitForChild("BodyPosition")
		driverSeat = bargeModel:WaitForChild("DriversSeat")
	elseif bargeModel.PrimaryPart == currentBargePart then
		ContextActionService:UnbindAction("bargeUp")
		ContextActionService:UnbindAction("bargeDown")
		currentBargePart = nil
	end
end
local function onBargeTagAdded(barge)
	local seat = barge:WaitForChild("DriversSeat")
	seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		onOccupantChange(barge, seat.Occupant)
	end)
end
local function onRenderStepped(delta)
	if currentBargePart then
		local currentVelocity = currentBargePart.Velocity
		local magnitudeOfVelocity = currentVelocity.Magnitude
		local currentSpeed = BargeSpeed
		local velocityToApply = (-currentBargePart.CFrame.LookVector) * (currentSpeed * driverSeat.Throttle) * delta
		if driverSeat.Throttle == 0 then--We need to slow it down slowly.
			local currentSpeedThisFrame = 24 * delta;
			if magnitudeOfVelocity < currentSpeedThisFrame then
				velocityToApply = -currentBargePart.Velocity;
			else
				velocityToApply = -currentBargePart.Velocity.unit * currentSpeedThisFrame;
			end;
		end
		local newVelocity = currentVelocity + Vector3.new(velocityToApply.X, 0, velocityToApply.Z)
		local newVelocityMagnitude = newVelocity.magnitude
		if currentSpeed < newVelocityMagnitude then
			if magnitudeOfVelocity < newVelocityMagnitude then
				newVelocity = newVelocity.unit * currentSpeed
			end
		end
		if isEDown then
			isEDown = false
			BargeRemote:FireServer(currentBargePart.Parent, true)
		end
		if isQDown then
			isQDown = false
			BargeRemote:FireServer(currentBargePart.Parent, false)
		end
		currentBargePart.Velocity = newVelocity
		
		local yRot = currentBargePart.RotVelocity.Y
		local absyRot = math.abs(yRot)
		local directionToSteer = -driverSeat.Steer * SteerSpeed * delta
		if bodyPosition.MaxForce.Y <= 0 then
			directionToSteer = 0--The barge isn't hovering again.
		end
		if driverSeat.Steer == 0 then--0'd out again
			local steerSpeedThisFrame = SteerSpeed*delta
			if absyRot < steerSpeedThisFrame then
				directionToSteer = -yRot
			else--unitize and multiply :sunglasses:
				directionToSteer = -math.sign(yRot) * steerSpeedThisFrame
			end
		end
		directionToSteer = yRot + directionToSteer
		local absDirectionToSteer = math.abs(directionToSteer)
		if SteerSpeed/2 < absDirectionToSteer and absyRot < absDirectionToSteer then
			directionToSteer = (SteerSpeed/2)*math.sign(directionToSteer)
		end
		currentBargePart.RotVelocity = Vector3.new(0, directionToSteer, 0)
	end
end
RunService.Heartbeat:Connect(onRenderStepped)
CollectionService:GetInstanceAddedSignal("Barge"):Connect(onBargeTagAdded)
for _,v in ipairs(CollectionService:GetTagged("Barge")) do
	onBargeTagAdded(v)
end