--Authors: 4812571, Styx, n0pa
local Version = "0.4.2"

--Object Reference
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local Storage = workspace.Storage
local Objects = workspace:WaitForChild("Objects")
local Extras = workspace:WaitForChild("Extras")
local Services = ServerScriptService:WaitForChild("Services")
local Packages = ServerScriptService:WaitForChild("Packages")

--
require(Packages.Grid.Grids)
--

local DiscordService = require(Services:WaitForChild("DiscordService"))
local SnapData = require(Services:WaitForChild("SnapData"))
local UpgradeData = require(Services:WaitForChild("UpgradeData"))
local BackpackService = require(Services:WaitForChild("BackpackService"))
local GameService = require(Services:WaitForChild("GameService"))
local BargeService = require(Services:WaitForChild("BargeService"))
local CleanupService = require(Services:WaitForChild("CleanupService"))
local ArsenalService = require(Services:WaitForChild("ArsenalService"))
local LogService = require(Services:WaitForChild("LogService"))
local TickManager = require(Services:WaitForChild("TickManager"))

local Map = require(script.Map)
--
require(game.ReplicatedStorage.Stats.Structure)
require(game.ReplicatedStorage.Stats.Weapon)
--
Storage:Destroy()
Objects.Parent = ReplicatedStorage
Extras.Parent = ReplicatedStorage
--

print("Server Starting", "Version:", Version)
--
PlayersService.PlayerAdded:Connect(function(player) LogService.MessageClient(player, "Startup", "Game Version: "..Version) end)
--
SnapData.Generate()
UpgradeData.Generate()
Map.Generate()
TickManager.Activate()
--