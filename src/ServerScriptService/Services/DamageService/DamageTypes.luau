local module = {}

module["Bullet"] = {
	Player = 1;
	Shield = 0.05;
	Crystal = 0;
	Terrain = 0.1;
	Blueprint = 0.3;
	Structure = 0.1;

}

module["Laser"] = {
	Player = 0.01;
	Shield = 0.05;
	Crystal = 1;
	Terrain = 1.5;
	Blueprint = 1;
	Structure = 2;
}

module["BuilderBreak"] = {
	Player = 0;
	Shield = 1;
	Crystal = 0.15;
	Terrain = 0;
	Blueprint = 1;
	Structure = 1;
}

module["Explosive"] = {
	Player = 1;
	Shield = 1.15;
	Crystal = 0;
	Terrain = 0.1;
	Blueprint = 1;
	Structure = 1;
}

return module