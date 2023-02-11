-- Author: Sheikh

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local teleport = game.ReplicatedStorage:WaitForChild("Remotes").Teleport
local player = game.Players.LocalPlayer

local function onLaunch()
	TweenService:Create(player.PlayerGui.TeleportGui.Screen, TweenInfo.new(3), {BackgroundTransparency = 0}):Play()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	--UserInputService.MouseIconEnabled = false
end

teleport.OnClientEvent:Connect(onLaunch)