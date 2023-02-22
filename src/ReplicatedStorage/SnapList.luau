local SnapList = {}

-- Wall Snaps
SnapList["Wall"] = {"Wall", "Keep", "Gate"}
SnapList["Keep"] = {"Wall", "Keep", "Gate"}
SnapList["Gate"] = {"Wall", "Keep", "Gate"}

-- Block Snaps
SnapList["Full Block"] = {"Full Block"}

-- Pump Snaps
SnapList["Geothermal Pump"] = {"Well Top"}

-- Connector Snaps
SnapList["Wire"] = {"Connector"}
SnapList["T-Junction"] = {"Connector"}
SnapList["Elbow"] = {"Connector"}
SnapList["Four-Way"] = {"Connector"}
SnapList["Cap"] = {"Connector"}
SnapList["Distributor Cap"] = {"Connector"}

return SnapList