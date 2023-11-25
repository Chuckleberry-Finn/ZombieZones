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


zombieZonesAIHandler.walkTypes = {
    sprinter={id="sprint",rand=5},
    fastShambler={id="",rand=5},
    shambler={id="slow",rand=3},
}

function zombieZonesAIHandler.rollForSpeed(zone)
    local speeds = { sprinter=zone.speed.sprinter, fastShambler=zone.speed.fastShambler, shambler=zone.speed.shambler}

    local weight = 0
    for _,chance in pairs(speeds) do weight = weight + (chance) end
    local rand = ZombRand(1, weight+1)

    weight = 0
    for speed,chance in pairs(speeds) do
        weight = weight + (chance)
        if weight >= rand then
            return zombieZonesAIHandler.walkTypes[speed].id..ZombRand(1,zombieZonesAIHandler.walkTypes[speed].rand)+1
        end
    end
end


---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
function zombieZonesAIHandler.onUpdate(zombie)
    ---zombie mod data is not saved unless it's a reanimated player
    if zombie:isReanimatedPlayer() then return end
    local zombieModData = zombie:getModData()
    local zone = zombieZonesAIHandler.getZone(zombie)
    if not zone then return end

    local zombieSpeed = zombieModData.ZombieZonesSpeed
    if zombieSpeed == nil then zombieModData.ZombieZonesSpeed = zombieZonesAIHandler.rollForSpeed(zone) end
    if zombieSpeed then zombie:setWalkType(zombieModData.ZombieZonesSpeed) end

    local canCrawlUnderVehicle = zone.canCrawlUnderVehicle and (zone.canCrawlUnderVehicle=="false" and false) or (zone.canCrawlUnderVehicle=="true" and true) or SandboxVars.ZombieLore.CrawlUnderVehicle
    zombie:setCanCrawlUnderVehicle(canCrawlUnderVehicle)

    local dayNightActivity = zone.dayNightActivity
    local hour = getGameTime():getHour()
    local shouldBeActive = (hour >= dayNightActivity.start and hour <= dayNightActivity.stop)
    zombie:makeInactive(not shouldBeActive)

    if getDebug() then

        zombie:addLineChatElement(tostring(zombie:getID()).." _ "..tostring(zombie:getOnlineID())..
                "\npersistentOutfitID:"..zombie:getPersistentOutfitID()..
                "\nspeed:"..tostring(zombieModData.ZombieZonesSpeed)..
                "\ncanCrawlUnderVehicle:"..tostring(canCrawlUnderVehicle))
    end
end

return zombieZonesAIHandler