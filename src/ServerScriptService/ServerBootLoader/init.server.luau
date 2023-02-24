-- Authors: 4812571, Styx, n0pa
local Version = "0.4.2"

-- Object Reference
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Storage = workspace.Storage
local Objects = workspace:WaitForChild("Objects")
local Extras = workspace:WaitForChild("Extras")
local Services = ServerScriptService:WaitForChild("Services")
local Packages = ServerScriptService:WaitForChild("Packages")

--
require(Packages.Grid.Grids)
--

-- These are required so they actually load. They should have start methods, but who am I to disagree with the original author?
local DiscordService = require(Services:WaitForChild("DiscordService"))
local SnapData = require(Services:WaitForChild("SnapData"))
local WeldService = require(Services:WaitForChild("WeldService"))
local UpgradeData = require(Services:WaitForChild("UpgradeData"))
local BackpackService = require(Services:WaitForChild("BackpackService"))
local GameService = require(Services:WaitForChild("GameService"))
local BargeService = require(Services:WaitForChild("BargeService"))
local CleanupService = require(Services:WaitForChild("CleanupService"))
local ArsenalService = require(Services:WaitForChild("ArsenalService"))
local LogService = require(Services:WaitForChild("LogService"))
local TickManager = require(Services:WaitForChild("TickManager"))
local SpawnService = require(Services:WaitForChild("SpawnService"))

-- There's no need to require the map in any specific order - it has a start method.
local Map = require(script.Map)

-- Stats used to have a bit of behavior. If they're just data now, we can remove the require()s.
require(game.ReplicatedStorage.Stats.Structure)
require(game.ReplicatedStorage.Stats.Weapon)

-- The game moves these instances before requiring any scripts, so we need to do this task first.
Storage:Destroy()
Objects.Parent = ReplicatedStorage
Extras.Parent = ReplicatedStorage

-- This prints the version to the console and to the client.
-- It's not critical to the game, but it is of some utility.
print("Server Starting", "Version:", Version)
Players.PlayerAdded:Connect(function(player) LogService.MessageClient(player, "Startup", "Game Version: "..Version) end)

-- These calls are all starting up services. 
-- They may be order-dependent, but I'm not sure.
SnapData.Generate()
UpgradeData.Generate()
Map.Generate()
TickManager.Activate()

-- These are all services that have a proper start method.
ArsenalService:Start()
BargeService:Start()