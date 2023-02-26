-- Authors: 4812571, Styx, n0pa
local Version = "0.4.2"

-- Object Reference
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Storage = workspace.Storage
local Objects = workspace:WaitForChild("Objects")
local Extras = workspace:WaitForChild("Extras")
local VoltzPackages = ServerScriptService:WaitForChild("Packages")
local Packages = ReplicatedStorage:WaitForChild("Packages")

-- Import Packages
local Loader = require(Packages.Loader)

-- Move Instances
Storage:Destroy()
Objects.Parent = ReplicatedStorage
Extras.Parent = ReplicatedStorage

-- Load Stats
require(game.ReplicatedStorage.Stats.Structure)
require(game.ReplicatedStorage.Stats.Weapon)

-- Load Grids
require(VoltzPackages.Grid.Grids)

-- Import Services
local services = Loader.LoadChildren(ServerScriptService:WaitForChild("Services"))

-- Start Services
Loader.SpawnAll(services, "Start")

-- Generate Map
services.MapService:Generate()

-- Message the client with the version of the game.
Players.PlayerAdded:Connect(function(player)
    services.LogService:MessageClient(player, "Startup", "Game Version: " .. Version)
end)

print("Server Started", "Version:", Version)