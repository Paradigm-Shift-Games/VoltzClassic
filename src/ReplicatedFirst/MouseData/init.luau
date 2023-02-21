local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MouseData = {}
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local SelectedEvent = game:GetService("RunService").RenderStepped
local Events = ReplicatedStorage:WaitForChild("Events")
local MouseDataRemote = Events:WaitForChild("MouseData")
local ActionRemote = Events:WaitForChild("Action")
local TargetedNames = {"RefillConsole", "CrystalApproximator"}
local IgnoredNames = {}
local Hit, HitPosition, Normal

local function CanHit(HitPart)
	if HitPart == nil then return true end --Nil 
	if table.find(TargetedNames, HitPart.Name) then return true end --Filter 
	if table.find(IgnoredNames, HitPart.Name) then return false end -- Filter
	if HitPart.Name == "ShieldDome" then if HitPart.Parent.Team.Value == LocalPlayer.Team then return false else return true end end --Shield
	if HitPart:IsDescendantOf(workspace.Effects) then return false end --Effects
	if HitPart:IsA("Terrain") then return true end --Terrain
	if HitPart.Transparency < 1 then return true end -- Visibility
	if HitPart.CanCollide then return true end --Collision
	if HitPart.Parent:FindFirstChild("Humanoid") then return true end --Character
	return false
end

local function OnRun(delta)
	local ScreenPoint = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
	local NewRay = Ray.new(ScreenPoint.Origin, ScreenPoint.Direction*1024)
	local IgnoreList = {LocalPlayer.Character}
	local hit, hitPosition, normal
	while true do
		hit, hitPosition, normal = workspace:FindPartOnRayWithIgnoreList(NewRay, IgnoreList)
		if CanHit(hit) then break end
		table.insert(IgnoreList, hit)
	end
	Hit, HitPosition, Normal = hit, hitPosition, normal
	MouseDataRemote:FireServer(Hit, HitPosition, Normal)
end

function MouseData.GetMouseData()
	return Hit, HitPosition, Normal
end

SelectedEvent:Connect(OnRun)

return MouseData