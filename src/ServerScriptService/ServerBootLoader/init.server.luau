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
local DiscordService = require(Services.DiscordService)
local SnapDataService = require(Services.SnapDataService)
local WeldService = require(Services.WeldService)
local UpgradeDataService = require(Services.UpgradeDataService)
local BackpackService = require(Services.BackpackService)
local GameService = require(Services.GameService)
local BargeService = require(Services.BargeService)
local CleanupService = require(Services.CleanupService)
local ArsenalService = require(Services.ArsenalService)
local LogService = require(Services.LogService)
local TickManagerService = require(Services.TickManagerService)
local SpawnService = require(Services.SpawnService)
local EffectService = require(Services.EffectService)
local SimulationService = require(Services.SimulationService)
local ActionService = require(Services.ActionService)
local ButtonService = require(Services.ButtonService)
local RatingService = require(Services.RatingService)
local WeaponService = require(Services.WeaponService)
local FallDamageService = require(Services.FallDamageService)

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
UpgradeDataService.Generate()
Map.Generate()
TickManagerService.Activate()

-- These are all services that have a proper start method.
ArsenalService:Start()
BargeService:Start()
EffectService:Start()
GameService:Start()
SimulationService:Start()
ActionService:Start()
BackpackService:Start()
ButtonService:Start()
RatingService:Start()
LogService:Start()
SnapDataService:Start()
SpawnService:Start()
WeaponService:Start()
FallDamageService:Start()