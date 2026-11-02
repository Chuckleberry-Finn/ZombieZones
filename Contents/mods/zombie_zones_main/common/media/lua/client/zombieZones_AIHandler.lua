local zombieZonesAIHandler = {}

--strength, toughness, transmission, cognition, sight, hearing
-- memory = 1 = 1250, 2 = 800, 3 = 500, 4 = 25

require "zoneEditor"
function zombieZonesAIHandler.getZone(zombie)
    if not zoneEditor.requestZone("ZombieZones") then return false end
    return zoneEditor.getZoneAt("ZombieZones", zombie:getX(), zombie:getY()) or false
end


zombieZonesAIHandler.walkTypes = { sprinter={id="sprint",rand=5}, fastShambler={id="",rand=5}, shambler={id="slow",rand=3}, }
---fixed order so every client rolls the same result from the same seed
zombieZonesAIHandler.speedOrder = {"sprinter", "fastShambler", "shambler"}


function zombieZonesAIHandler.seededRand(seed,upper)
    ---https://stackoverflow.com/questions/20154991/generating-uniform-random-numbers-in-lua
    local A1, A2 = 727595, 798405  -- 5^17=D20*A1+A2
    local D20, D40 = 1048576, 1099511627776  -- 2^20, 2^40
    seed = math.abs(seed)
    local X1, X2 = seed, 1
    local U = X2*A2
    local V = (X1*A2 + X2*A1) % D20
    V = (V*D20 + U) % D40
    X1 = math.floor(V/D20)
    X2 = V - X1*D20
    return (math.floor((V/D40)*upper) + 1)
end


function zombieZonesAIHandler.rollForSpeed(zone, zombie)
    if type(zone.speed) ~= "table" then return false end

    local weight = 0
    for _,speed in ipairs(zombieZonesAIHandler.speedOrder) do weight = weight + (tonumber(zone.speed[speed]) or 0) end
    if weight <= 0 then return false end

    local roll = zombieZonesAIHandler.seededRand(zombieZonesAIHandler.getTruePersistentOutfitID(zombie), weight)

    weight = 0
    for _,speed in ipairs(zombieZonesAIHandler.speedOrder) do
        weight = weight + (tonumber(zone.speed[speed]) or 0)
        local walkType = zombieZonesAIHandler.walkTypes[speed]
        if weight >= roll then return walkType.id..(ZombRand(walkType.rand)+1) end
    end
    return false
end


---Outfit IDs flip PersistentOutfits.NO_HAT_BIT (32768) when a hat falls off, strip it so the zombie keeps its roll.
---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
function zombieZonesAIHandler.getTruePersistentOutfitID(zombie)
    local pID = zombie:getPersistentOutfitID()
    if math.floor(pID / 32768) % 2 == 1 then pID = pID - 32768 end
    return pID
end


function zombieZonesAIHandler.isActiveHour(dayNightActivity)
    local start, stop = tonumber(dayNightActivity.start), tonumber(dayNightActivity.stop)
    if not start or not stop then return end
    local hour = getGameTime():getHour()
    if start >= stop then return (hour >= start or hour < stop) end
    return (hour >= start and hour < stop)
end


---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
function zombieZonesAIHandler.onUpdate(zombie)

    ---zombie mod data is not saved unless it's a reanimated player
    if zombie:isReanimatedPlayer() then return end
    ---only the owning client drives a zombie in MP, walk types are synced from the owner
    if isClient() and zombie:isRemoteZombie() then return end

    local zombieModData = zombie:getModData()
    local zone = zombieZonesAIHandler.getZone(zombie)

    if zone and zone.canCrawlUnderVehicle then
        zombieModData.inZone = true
        local canCrawlUnderVehicle = (zone.canCrawlUnderVehicle=="false" and false) or (zone.canCrawlUnderVehicle=="true" and true)
        if canCrawlUnderVehicle ~= nil then zombie:setCanCrawlUnderVehicle(canCrawlUnderVehicle) end
    elseif zombieModData.inZone then
        zombieModData.inZone = nil
        zombie:initCanCrawlUnderVehicle()
    end

    local trueID = zombieZonesAIHandler.getTruePersistentOutfitID(zombie)
    if zombieModData.ZombieZonesPersistentID and zombieModData.ZombieZonesPersistentID ~= trueID then zombieModData.ZombieZonesSpeed = nil end
    zombieModData.ZombieZonesPersistentID = trueID

    ---the game re-applies the sandbox activity phase every update, only override it inside a zone that disagrees
    local shouldBeActive = not getGameTime():isZombieInactivityPhase()
    local zoneActive
    if zone and type(zone.dayNightActivity) == "table" then zoneActive = zombieZonesAIHandler.isActiveHour(zone.dayNightActivity) end
    if zoneActive ~= nil and zoneActive ~= shouldBeActive then
        shouldBeActive = zoneActive
        zombie:makeInactive(not shouldBeActive)
    end

    if not shouldBeActive then return end

    if zombieModData.ZombieZonesSpeed == nil then zombieModData.ZombieZonesSpeed = zone and zombieZonesAIHandler.rollForSpeed(zone, zombie) or false end

    local zombieSpeed = zombieModData.ZombieZonesSpeed
    if zombieSpeed and zombie:getWalkType() ~= zombieSpeed then
        zombie:setWalkType(zombieSpeed)
        zombie:setSpeedTypeFromWalkType()
    end
end

return zombieZonesAIHandler
