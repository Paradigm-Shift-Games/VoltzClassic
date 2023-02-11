print("Gun Script Injected! Watching...")
local Mouse = game.Players.LocalPlayer:GetMouse()
local Equipped = false
local Events = game.ReplicatedStorage:WaitForChild("Remotes")
local ActionRemote = Events:WaitForChild("Action")
local function OnMouseDown()
	if Equipped then
		ActionRemote:FireServer("GunFire", true)
	end
end
local function OnMouseUp()
	if Equipped then
		ActionRemote:FireServer("GunFire", false)
	end
end
local function OnEquip()
	Equipped = true
end
local function OnUnequip()
	OnMouseUp()
	Equipped = false
end
Mouse.Button1Down:Connect(OnMouseDown)
Mouse.Button1Up:Connect(OnMouseUp)
script.Parent.Equipped:Connect(OnEquip)
script.Parent.Unequipped:Connect(OnUnequip)