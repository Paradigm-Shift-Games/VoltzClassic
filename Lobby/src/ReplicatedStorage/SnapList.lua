local module = {}

module["Wall"] = {"Wall", "Keep", "Gate"}
module["Keep"] = {"Wall", "Keep", "Gate"}
module["Gate"] = {"Wall", "Keep", "Gate"}

module["Full Block"] = {"Full Block"}
module["Geothermal Pump"] = {"Well Top"}
module["Wire"] = {"Connector"}
module["T-Junction"] = {"Connector"}
module["Elbow"] = {"Connector"}
module["Four-Way"] = {"Connector"}
module["Cap"] = {"Connector"}
module["Distributor Cap"] = {"Connector"}


return module
