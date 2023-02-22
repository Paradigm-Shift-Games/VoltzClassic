local Structure = {}

-- Building Structures
Structure["Full Block"] = {
	Cost = 50;
	Health = 600;
}

Structure["Hollow Block"] = {
	Cost = 50;
	Health = 450;
}

Structure["Wedge30"] = {
	Cost = 30;
	Health = 500;
}

Structure["Wedge45"] = {
	Cost = 45;
	Health = 450;
}

Structure["Slab"] = {
	Cost = 25;
	Health = 100;
}

Structure["Explosive Charge"] = {
	Cost = 25;
	Health = 25;
}

Structure["Side Platform"] = {
	Cost = 30;
	Health = 250;
}

Structure["Bridge"] = {
	Cost = 30;
	Health = 600;
}

-- Wiring

Structure["Wire"] = {
	Cost = 5;
	Health = 400;
}

Structure["T-Junction"] = {
	Cost = 10;
	Health = 400;
}

Structure["Elbow"] = {
	Cost = 10;
	Health = 400;
}

Structure["Four-Way"] = {
	Cost = 10;
	Health = 400;
}

Structure["Guage"] = {
	Cost = 15;
	Health = 400;
}

Structure["Cap"] = {
	Cost = 5;
	Health = 300;
}

Structure["Distributor Cap"] = {
	Cost = 15;
	Health = 300;
	Storage = 50;
}


-- Producers

Structure["Atmospheric Generator"] = {
	Cost = 100;
	Health = 350;
	isProducer = true;
	MinHeight = 10;
	MaxHeight = 200;
	MinProduction = 1;
	MaxProduction = 5;
	Storage = 15;
	-- Sound =
}

Structure["Geothermal Generator"] = {
	Cost = 100;
	Health = 500;
	isProducer = true;
	ConstantProduction = 5;
	Storage = 50;
	-- Sound =
	Upgrades = {
		[1] = {
			Cost = 200;
		};
		[2] = {
			Cost = 200;
		};
		[3] = {
			Cost = 200;
		};
	};
}

Structure["Pump Fabricator"] = {
	Tags = {"Fabricator"};
	Range = 75;
}

Structure["Pump Distributor"] = {
	Tags = {"Distributor"};
	Range = 50;
}

Structure["Pump Producer"] = {
	isProducer = true;
	ConstantProduction = 10;
}

Structure["Submersible"] = {
	Cost = 300;
	Health = 400;
	isProducer = true;
	Storage = 20;
	-- Sound = 
}

-- Batteries

Structure["Small Battery"] = {
	Cost = 30;
	Health = 450;
	Storage = 350;
}

Structure["Standard Battery"] = {
	Cost = 100;
	Health = 650;
	Storage = 650;
}

Structure["Large Battery"] = {
	Cost = 400;
	Health = 1000;
	Storage = 1200;
}

-- Electrical Structures
Structure["Arsenal"] = {
	Cost = 125;
	Health = 650;
	-- Sound =
}

Structure["Garage"] = {
	Cost = 125;
	Health = 750;
	Consumption = 100;
	-- Sound =
}

Structure["Charge Station"] = {
	Cost = 25;
	Health = 350;
	Storage = 15;
}

Structure["Spawn"] = {
	Cost = 100;
	Health = 700;
	Storage = 350;
	SpawnConsumption = 100;
	TeleportConsumption = 50;
	-- Sound =
}

Structure["Fabricator"] = {
	Cost = 15;
	Health = 300;
	Range = 128;
	TransferRate = 20;
	BeamCount = 3;
	-- Sound =
}

Structure["Automech"] = {
	Cost = 700;
	Health = 300;
	Range = 20;
	RepairRate = 20;
	-- Sound =
}

Structure["Distributor"] = {
	Cost = 225;
	Health = 300;
	Range = 48;
	TransferRate = 25;
	-- Sound =
}

Structure["DistributorSLOW"] = {
	Cost = 225;
	Health = 300;
	Range = 48;
	TransferRate = 25;
	-- Sound =
}

Structure["Transceiver"] = {
	Cost = 300;
	Health = 300;
	Storage = 15;
	Cooldown = 1;
	TransferAmount = 100;
}

Structure["Gravity Displacer"] = {
	Cost = 350;
	Health = 300;
	Storage = 100;
	Consumption = 10;
	-- Sound =
}

--[[
Structure["DebugLamp"] = {}
Structure["DebugLamp"].Cost = 100
Structure["DebugLamp"].Health = 100
Structure["DebugLamp"].Consumption = 2
]]--

-- Defensive Structures
Structure["Wall"] = {
	Cost = 70;
	Health = 1200;
}

Structure["Gate"] = {
	Cost = 200;
	Health = 1200;
	-- Sound =
}

Structure["Keep"] = {
	Cost = 65;
	Health = 1000;
}

Structure["Shield Generator"] = {
	Cost = 200;
	Health = 200;
	Sizes = {
		Large = 105;
		Medium = 85;
		Small = 65;
	};
	Drain = 0;
	Consumption = 10;
	ChargeRate = 5;
	MaxCharge = 2000;
	
}

Structure["Turret"] = {
	Cost = 120;
	Health = 700;
	Damage = 15;
	ReloadTime = 0.5;
	Range = 150;
	ShotCost = 2;
	Spread = 7.5; -- degrees
	SpreadWeight = 4;
	-- Sound =
}

Structure["Laser Turret"] = {
	Cost = 1500;
	Health = 1500;
	Damage = 20;
	Range = 250;
	ShotCost = 10;
	Spread = 1;
	-- Sound =
}

Structure["Tesla Turret"] = {
	Cost = 200;
	Health = 300;
	Damage = 20;-- dps -- 20;
	-- ReloadTime = 1;
	Range = 30; -- 50;
	ShotCost = 80;-- e/s -- 30;
	-- Sound =
}

Structure["Artillery"] = {
	Cost = 500;
	Health = 550;
	Damage = 350;
	BlastRadius = 25;
	ReloadTime = 1;
	YawSpeed = math.rad(20); -- ^ per second v
	PitchSpeed = math.rad(20); -- < per second >
	InitialVelocity = 150;
	ShotCost = 10;
	-- Sound =
}

Structure["AATurret"] = {
	Cost = 500;
	Health = 550;
	Damage = 350;
	BlastRadius = 25;
	ReloadTime = 1;
	YawSpeed = math.rad(20); -- ^ per second v
	PitchSpeed = math.rad(20); -- < per second >
	InitialVelocity = 150;
	ShotCost = 10;
	-- Sound =
}

-- local RunService = game:GetService("RunService")
-- if RunService:IsStudio() then
--	for _, v in pairs(Structure) do
--		if v.Cost then
--			v.Cost = 1
--		end
--	end
-- end

return Structure
