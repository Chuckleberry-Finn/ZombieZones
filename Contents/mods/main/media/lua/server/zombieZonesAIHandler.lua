local zombieZonesAIHandler = {}

--strength, toughness, transmission, cognition, sight, hearing
--        if (this.memory == -1 && var1 == 1 || var2 == 0) {this.memory = 1250;}
--        if (this.memory == -1 && var1 == 2 || var2 == 1) {this.memory = 800;}
--        if (this.memory == -1 && var1 == 3 || var2 == 2) {this.memory = 500;}
--        if (this.memory == -1 && var1 == 4 || var2 == 3) {this.memory = 25;}

require "zoneEditor"
function zombieZonesAIHandler.getZone(zombie)

    local zombieZones = zoneEditor.requestZone("ZombieZones")
    if not zombieZones then return false end

    for i, zone in pairs(zombieZones) do
        if zone.coordinates and
                zombie:getX() >= zone.coordinates.x1 and zombie:getX() <= zone.coordinates.x2 and
                zombie:getY() >= zone.coordinates.y1 and zombie:getY() <= zone.coordinates.y2 then
            return zone
        end
    end

    return false

end


zombieZonesAIHandler.walkTypes = { sprinter={id="sprint",rand=5}, fastShambler={id="",rand=5}, shambler={id="slow",rand=3}, }
function zombieZonesAIHandler.seededRand(seed,upper)
    ---https://stackoverflow.com/questions/20154991/generating-uniform-random-numbers-in-lua
    local A1, A2 = 727595, 798405  -- 5^17=D20*A1+A2
    local D20, D40 = 1048576, 1099511627776  -- 2^20, 2^40
    local X1, X2 = 0, 1

    local result = nil
    for i=0, math.abs(seed) do
        local U = X2*A2
        local V = (X1*A2 + X2*A1) % D20
        V = (V*D20 + U) % D40
        X1 = math.floor(V/D20)
        X2 = V - X1*D20
        result = math.floor((V/D40)*upper) + 1
    end
    return result
end


function zombieZonesAIHandler.rollForSpeed(zone, zombie)
    local weight, speeds = { sprinter=zone.speed.sprinter, fastShambler=zone.speed.fastShambler, shambler=zone.speed.shambler}, 0
    for _,chance in pairs(speeds) do weight = weight + (chance) end

    local zombieModData = zombie:getModData()
    zombieModData.ZombieZoneRand = zombieModData.ZombieZoneRand or zombieZonesAIHandler.seededRand((zombie:getPersistentOutfitID()%100000),weight)
    if zombieModData.ZombieZonesSpeed then return end

    weight = 0
    for speed,chance in pairs(speeds) do
        weight = weight + (chance)
        if weight >= zombieModData.ZombieZoneRand then return (zombieZonesAIHandler.walkTypes[speed].id..(ZombRand(1,zombieZonesAIHandler.walkTypes[speed].rand)+1)) end
    end
end


---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
function zombieZonesAIHandler.onUpdate(zombie)
    ---zombie mod data is not saved unless it's a reanimated player
    if zombie:isReanimatedPlayer() then return end
    local zombieModData = zombie:getModData()
    local zone = zombieZonesAIHandler.getZone(zombie)

    local zombieSpeed = zombieModData.ZombieZonesSpeed

    if zombieSpeed == nil and zone then
        zombieModData.ZombieZonesSpeed = zombieZonesAIHandler.rollForSpeed(zone, zombie)
    end
    if zombieSpeed then zombie:setWalkType(zombieModData.ZombieZonesSpeed) end

    local canCrawlUnderVehicle = zone and zone.canCrawlUnderVehicle and (zone.canCrawlUnderVehicle=="false" and false) or (zone.canCrawlUnderVehicle=="true" and true) or SandboxVars.ZombieLore.CrawlUnderVehicle
    zombie:setCanCrawlUnderVehicle(canCrawlUnderVehicle)

    local dayNightActivity = zone and zone.dayNightActivity
    local hour = getGameTime():getHour()
    local shouldBeActive = dayNightActivity and (hour >= dayNightActivity.start and hour <= dayNightActivity.stop) or nil
    shouldBeActive = shouldBeActive==nil and SandboxVars.ZombieLore.ActiveOnly or shouldBeActive
    zombie:makeInactive(not shouldBeActive)
    
    --if getDebug() then zombie:addLineChatElement("speed:"..tostring(zombieModData.ZombieZonesSpeed).. "\npOID:"..(zombie:getPersistentOutfitID()%100000).. "\nrand: "..tostring(zombieModData.ZombieZoneRand)) end
end

return zombieZonesAIHandler