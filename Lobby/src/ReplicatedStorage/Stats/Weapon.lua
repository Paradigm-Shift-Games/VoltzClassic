local weaponStats = {}
local weaponeffects = {}
--local SFX = game.ReplicatedStorage:WaitForChild("Soundeffects")

--[[ effects ]]--
weaponeffects["Pistol"] = {
	Speed = 512;
	Size = 0.25;
	BrickColor = BrickColor.new("Electric blue");
	Material = Enum.Material.Neon;
	Transparency = 0;
}

weaponeffects["Physical"] = {
	Speed = 768;
	Size = 0.25;
	BrickColor = BrickColor.new("Gold");
    Material = Enum.Material.Neon;
    Transparency = 0;
}

weaponeffects["Laser"] = {
	Speed = 192; 
	Size = 0.35;
	BrickColor = BrickColor.new("Bright red");
	Material = Enum.Material.Neon;
	Transparency = 0.25;
}

weaponeffects["BoopLaser"] = {
	Speed = 192;
	Size = 3.5;
	Material = Enum.Material.Neon;
	BrickColor = BrickColor.new("Really red");
}

--[[ Stats ]]--
weaponStats["Pistol"] = {
	FireMode = "manual";
	FireType = "Bullet";
	DamageType = "Bullet";
	Effect = weaponeffects["Pistol"];
	Consumption = 1;	
	Damage = 12.5;
	Range = 128;
	FireRate = 4;
	Spread = 0.5;
}

weaponStats["SMG"] = {
	FireMode = "automatic";
	FireType = "Bullet";
	DamageType = "Bullet";
	Effect = weaponeffects["Physical"];
	Consumption = 1;
	Damage = 15;
	Range = 96;
	FireRate = 25;
	Spread = 3.5;
}

weaponStats["Assault Rifle"] = {
	FireMode = "automatic";
	FireType = "Bullet";
	DamageType = "Bullet";
	Effect = weaponeffects["Physical"];
	Consumption = 1;
	Damage = 15;
	Range = 196;
	FireRate = 12;
	Spread = 2;
}

weaponStats["Laser Drill"] = {
	FireMode = "automatic";
	FireType = "Bullet";
	DamageType = "Laser";
	Effect = weaponeffects["Laser"];
	Consumption = 0.2;
	Damage = 10;
	Range = 20;
	FireRate = 30;
	Spread = 0.2;
}

weaponStats["Rocket Launcher"] = {
	FireMode = "manual";
	FireType = "Rocket";
	Projectile = workspace.Extras.Projectiles.Rocket;
	Consumption = 30;
	Damage = 175;
	BlastRadius = 25;
	ThrustTime = 0.25;
	InitialSpeed = 115;
	FireRate = 1/2;
}

weaponStats["MRCLEAN"] = {
	FireMode = "automatic";
	FireType = "Rocket";
	Projectile = workspace.Extras.Projectiles.Rocket;
	Damage = 9001;
	BlastRadius = 2;
	InitialSpeed = 115;
	FireRate = 30;
}

weaponStats["Hyper Nuke"] = {
	FireMode = "manual";
	FireType = "Rocket";
	Projectile = workspace.Extras.Projectiles.Nuke;
	Damage = 15000;
	BlastRadius = 120;
	InitialSpeed = 5;
	FireRate = 1/2;
}

weaponStats["Boop"] = {
	FireMode = "automatic";
	FireType = "Bullet";
	DamageType = "Bullet";
	Effect = weaponeffects["BoopLaser"];
	Damage = 9999;
	Range = 999;
	FireRate = 30;
	Spread = 0;
}

weaponStats["HPPL"] = {
	FireMode = "manual";
	FireType = "Rocket";
	Projectile = workspace.Extras.Projectiles.Photon;
	Damage = 999999999999;
	BlastRadius = 25;
	InitialSpeed = 299792458;
	FireRate = 1;
}


--weaponStats["Pistol"] = {}
--weaponStats["Pistol"].DamageToPlayer = 15
--weaponStats["Pistol"].Spread = 0
--weaponStats["Pistol"].DamageToBuilding = 2
--weaponStats["Pistol"].FiringInterval = .25
--weaponStats["Pistol"].ShotCost = 1
--weaponStats["Pistol"].FireMode = 0
--weaponStats["Pistol"].HeadMulti = 2.5
--weaponStats["Pistol"].ShootFunction = "StandardShot"
--weaponStats["Pistol"].ShotDistance = 125
--weaponStats["Pistol"].Sound = {
--	ShotSound = SFX:WaitForChild("PistolSound");
--}
--
--weaponStats["SMG"] = {}
--weaponStats["SMG"].DamageToPlayer = 9
--weaponStats["SMG"].Spread = 3.5
--weaponStats["SMG"].DamageToBuilding = 1
--weaponStats["SMG"].FiringInterval = 1 / 25
--weaponStats["SMG"].ShotCost = .5
--weaponStats["SMG"].FireMode = 1 --change this to whichever one is automatic
--weaponStats["SMG"].HeadMulti = 1.01
--weaponStats["SMG"].ShootFunction = "StandardShot" --whichever one is automatic
--weaponStats["SMG"].ShotDistance = 96
--weaponStats["SMG"].Sound = {
--	ShotSound = SFX:WaitForChild("ARSound"); 	
--}
--
--weaponStats["Assault Rifle"] = {}
--weaponStats["Assault Rifle"].DamageToPlayer = 10
--weaponStats["Assault Rifle"].Spread = .2
--weaponStats["Assault Rifle"].DamageToBuilding = 1.5
--weaponStats["Assault Rifle"].FiringInterval = .1
--weaponStats["Assault Rifle"].ShotCost = 2
--weaponStats["Assault Rifle"].FireMode = 1 --automatic pls
--weaponStats["Assault Rifle"].HeadMulti = 1.2
--weaponStats["Assault Rifle"].ShootFunction = "StandardShot" --automatic pls
--weaponStats["Assault Rifle"].ShotDistance = 50
--weaponStats["Assault Rifle"].Sound = {
--	ShotSound = SFX:WaitForChild("ARSound");
--}
--
--weaponStats["Rocket Launcher"] = {}
--weaponStats["Rocket Launcher"].DamageToPlayer = 200
--weaponStats["Rocket Launcher"].Spread = .01
--weaponStats["Rocket Launcher"].DamageToBuilding = 50
--weaponStats["Rocket Launcher"].FiringInterval = 2.5
--weaponStats["Rocket Launcher"].ShotCost = 30
--weaponStats["Rocket Launcher"].FireMode = 0 --explosive pls
--weaponStats["Rocket Launcher"].HeadMulti = 1 --it's already a one shot, headshots don't matter
--weaponStats["Rocket Launcher"].ShootFunction = "RocketShot" --explosive pls
--weaponStats["Rocket Launcher"].ShotDistance = 100
--weaponStats["Rocket Launcher"].ShotVelocity = 50
--weaponStats["Rocket Launcher"].BlastRadius = 10
--weaponStats["Rocket Launcher"].BlastPressure = 1000000000 --you HAVE to use astronomical numbers or there is no knockback Effect
--weaponStats["Rocket Launcher"].Sound = {
--	ShotSound = SFX:WaitForChild("RocketSound");
--}
--
--weaponStats["Grenade Launcher"] = {}
--weaponStats["Grenade Launcher"].DamageToPlayer = 30
--weaponStats["Grenade Launcher"].Spread = .05
--weaponStats["Grenade Launcher"].DamageToBuilding = 25
--weaponStats["Grenade Launcher"].FiringInterval = 1
--weaponStats["Grenade Launcher"].ShotCost = 10
--weaponStats["Grenade Launcher"].FireMode = 0 --explosive pls
--weaponStats["Grenade Launcher"].HeadMulti = 1
--weaponStats["Grenade Launcher"].ShootFunction = "GrenadeShot" --explosive pls
--weaponStats["Grenade Launcher"].ShotDistance = 30
--weaponStats["Grenade Launcher"].BlastRadius = 25
--weaponStats["Grenade Launcher"].BlastPressure = 1000000000 --you HAVE to use astronomical numbers or there is no knockback Effect
--weaponStats["Grenade Launcher"].Sound = {
--	ShotSound = SFX:WaitForChild("GrenadeSound");
--}
--
--weaponStats["Sniper Rifle"] = {}
--weaponStats["Sniper Rifle"].DamageToPlayer = 50.1
--weaponStats["Sniper Rifle"].Spread = 0
--weaponStats["Sniper Rifle"].DamageStoBuilding = 8
--weaponStats["Sniper Rifle"].FiringInterval = 3
--weaponStats["Sniper Rifle"].ShotCost = 15
--weaponStats["Sniper Rifle"].FireMode = 0
--weaponStats["Sniper Rifle"].HeadMulti = 2
--weaponStats["Sniper Rifle"].ShootFunction = "StandardShot" --standard shot maybe..?
--weaponStats["Sniper Rifle"].ShotDistance = 150
--weaponStats["Sniper Rifle"].Sound = {
--	ShotSound = SFX:WaitForChild("SniperSound");
--}


return weaponStats
