local weaponStats = {}
local weaponEffects = {}
-- local SFX = game.ReplicatedStorage:WaitForChild("Soundeffects")

--[[ Effects ]]--
weaponEffects["Pistol"] = {
	Speed = 512;
	Size = 0.25;
	BrickColor = BrickColor.new("Electric blue");
	Material = Enum.Material.Neon;
	Transparency = 0;
}

weaponEffects["Physical_s"] = {
	Speed = 768;
	Size = 0.25;
	BrickColor = BrickColor.new("Gold");
    Material = Enum.Material.Neon;
    Transparency = 0;
}

weaponEffects["Physical_l"] = {
	Speed = 768;
	Size = 0.3;
	BrickColor = BrickColor.new("Gold");
	Material = Enum.Material.Neon;
	Transparency = 0;
}

weaponEffects["Laser"] = {
	Speed = 192; 
	Size = 0.35;
	BrickColor = BrickColor.new("Bright red");
	Material = Enum.Material.Neon;
	Transparency = 0.25;
}

weaponEffects["BoopLaser"] = {
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
	Effect = weaponEffects["Pistol"];
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
	Effect = weaponEffects["Physical_s"];
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
	Effect = weaponEffects["Physical_l"];
	Consumption = 2;
	Damage = 15;
	Range = 196;
	FireRate = 8.5;
	Spread = 1.5;
}

weaponStats["Laser Drill"] = {
	FireMode = "automatic";
	FireType = "Bullet";
	DamageType = "Laser";
	Effect = weaponEffects["Laser"];
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

weaponStats["Emergency Pistol"] = {
	FireMode = "automatic";
	FireType = "Rocket";
	Projectile = workspace.Extras.Projectiles.Bullet;
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
	InitialSpeed = 10;
	FireRate = 1/2;
}

weaponStats["Boop"] = {
	FireMode = "automatic";
	FireType = "Bullet";
	DamageType = "Bullet";
	Effect = weaponEffects["BoopLaser"];
	Damage = 9999;
	Range = 999;
	FireRate = 30;
	Spread = 0;
}

weaponStats["HPPL"] = {
	FireMode = "manual";
	FireType = "Rocket";
	Projectile = workspace.Extras.Projectiles.Proton;
	Damage = 999999999999;
	BlastRadius = 25;
	InitialSpeed = 299792458;
	FireRate = 1;
}

weaponStats.Effects = weaponEffects

return weaponStats
