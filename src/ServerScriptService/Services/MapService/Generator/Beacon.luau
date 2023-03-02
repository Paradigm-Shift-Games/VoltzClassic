local Beacon = {}

Beacon.Dependencies = {
    
}

function Beacon.Generate(config, randomizers, grids)
    -- Settings
    local beaconSettings = config.Beacon
    
    local beaconGrid = {}

    if beaconSettings.CentralBeacon then
        beaconGrid[Vector3.new(0, 0, 0)] = true 
    end

    local beaconAngleDifference = math.rad(360 / beaconSettings.BeaconCount)

    for i = 1, beaconSettings.BeaconCount do
        local unitX = math.cos(beaconAngleDifference * i)
        local unitY = math.sin(beaconAngleDifference * i)

        local scaledX = math.round(unitX * beaconSettings.Offset)
        local scaledY = math.round(unitY * beaconSettings.Offset)

        beaconGrid[Vector3.new(scaledX, 0, scaledY)] = true
    end

    return beaconGrid
end

return Beacon