-- Author: n0pa

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Stats = require(ReplicatedStorage.Stats.Structure)
local ExplosionService = require(ServerScriptService.Services.ExplosionService)
local Electricity = require(ServerScriptService.Packages.Electricity.Interface)
local ProjectileService = require(ServerScriptService.Services.ProjectileService)

local ArtilleryStats = Stats.Artillery
local Events = ReplicatedStorage:WaitForChild("Events")
local ArtilleryRemote = Events:WaitForChild("ArtilleryRemote")
local RocketTemplate = workspace.Extras.Projectiles.Rocket

--Constants
local MAXPITCH = 0.7 --These are radians from the horizontal
local MINPITCH = -0.55 --These are radians from the horizontal

local ArtilleryData = {}

local function Explode(projectileData)
	ExplosionService.Explode(projectileData.directions[1], ArtilleryStats.BlastRadius, ArtilleryStats.Damage)
	projectileData.projectile:Destroy()
end

local function onAdded(artillery)
	ArtilleryData[artillery] = {
		NetPitch = 0;
		NetYaw = 0;
		CurrentReloadingTime = 0;
		Consumed = false;
		Occupant = nil;
	}
	
	local head = artillery:WaitForChild("Head");
	local seat = head:WaitForChild("Seat");
	seat.Disabled = false
	
	local onOccupancyChanged = function()
		if not ArtilleryData[artillery] then return end
		
		local humanoid = seat.Occupant
		local artilleryData = ArtilleryData[artillery]
		
		if humanoid then
			artilleryData.Occupant = Players:GetPlayerFromCharacter(humanoid.Parent)
			
		else
			artilleryData.NetPitch = 0;
			artilleryData.NetYaw = 0;
			artilleryData.Occupant = nil;
		end
	end
	
	seat:GetPropertyChangedSignal("Occupant"):Connect(onOccupancyChanged)
end

local function onRemoved(artillery)
	ArtilleryData[artillery] = nil
end

local function onServerEvent(player, artillery, mode, rotationArray)
	local artilleryData = ArtilleryData[artillery]
	if not artilleryData or ArtilleryData[artillery].Occupant ~= player then return end
		
	if mode == "Fire" then --Needs to be finished @NPA
		print(artilleryData.CurrentReloadingTime, ArtilleryStats.ReloadTime);
		if artilleryData.CurrentReloadingTime < ArtilleryStats.ReloadTime then return end
		
		artilleryData.Consumed = false
		artilleryData.CurrentReloadingTime = 0
		
		local fireAttachment = artillery.Barrel.Barrel.Attachment
		local fireDirection = (fireAttachment.WorldPosition - artillery.Barrel.Barrel.Position).Unit
		local projectileParameters = {owner = player, stats = ArtilleryStats, ignore = {artillery}}
		local projectileDirections = {fireAttachment.WorldPosition, fireDirection * ArtilleryStats.InitialVelocity, Vector3.new(0, -workspace.Gravity, 0)}
		local projectile = ProjectileService.New(RocketTemplate, projectileDirections, projectileParameters)
		ProjectileService.Bind(projectile, Explode)
		
		return
	end
		
	if mode == "Pitch" then
		ArtilleryData[artillery].NetPitch = 1 * rotationArray[1] + -1 * rotationArray[2] --Refer to the client script for the indices
		
	elseif mode == "Yaw" then
		ArtilleryData[artillery].NetYaw = -1 * rotationArray[1] + 1 * rotationArray[2] --Refer to the client script for the indices
	end
end

local function runObject(delta, artillery) --Not named to "runArtillery" for the sake of Artillery.Run errors
	local artilleryData = ArtilleryData[artillery]
	
	if artilleryData.Consumed then
		artilleryData.CurrentReloadingTime = math.min(artilleryData.CurrentReloadingTime + delta, ArtilleryStats.ReloadTime) --Increases until reload time is reached
		--Update the part maybe?
	else
		artilleryData.Consumed = Electricity.Pull(artillery, ArtilleryStats.ShotCost)
	end
		
	local head = artillery:WaitForChild("Head");
	local base = artillery:WaitForChild("Base");
	if not head or not base then warn(artillery, "is missing either Head or Base") return end
	
	local barrelHingeMotor = head:FindFirstChild("HingeMotor")
	local headHingeMotor = base:FindFirstChild("HingeMotor")
	if not barrelHingeMotor or not headHingeMotor then warn(artillery, "is missing either Head or Base HingeMotors") return end
		
	local _, _, pitch = barrelHingeMotor.C0:ToEulerAnglesYXZ()
	pitch += ArtilleryStats.PitchSpeed * artilleryData.NetPitch * delta
	barrelHingeMotor.C0 = CFrame.Angles(0, 0, math.clamp(pitch, MINPITCH, MAXPITCH)) --pitch needs a clamp otherwise it clips through the base / head
	
	local _, yaw, _ = headHingeMotor.C0:ToEulerAnglesYXZ()
	yaw += ArtilleryStats.YawSpeed * artilleryData.NetYaw * delta
	headHingeMotor.C0 = CFrame.Angles(0, yaw, 0)
end

ArtilleryRemote.OnServerEvent:Connect(onServerEvent)

local ArtilleryServer = {}
ArtilleryServer.__index = ArtilleryServer

function ArtilleryServer.new(instance)
	local self = setmetatable({}, ArtilleryServer)
	self.Instance = instance

	-- Shim
	onAdded(instance)

	return self
end

function ArtilleryServer:Update(deltaTime)
	-- Shim
	runObject(deltaTime, self.instance)
end

function ArtilleryServer:Destroy()
	-- Shim
	onRemoved(self.instance)
end

return ArtilleryServer