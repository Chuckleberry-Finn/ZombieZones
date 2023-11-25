local zombieZonesAIHandler = {}

--strength
--toughness
--transmission
--infectionmortality
--reanimatetime
--cognition
--memory
--sight
--hearing
--day/night
--dragDown
--fenceLunge
--fakeDead
--if zombie:isCrawling() then zombie:toggleCrawling() end

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


---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
function zombieZonesAIHandler.onUpdate(zombie)
    ---zombie mod data is not saved unless it's a reanimated player
    if zombie:isReanimatedPlayer() then return end
    local zombieModData = zombie:getModData()
    local zone = zombieZonesAIHandler.getZone(zombie)
    if not zone then return end

    local zombieSpeed = zombieModData.ZombieZonesSpeed
    if zombieSpeed == nil then

        local sprinterChance = zone.speed.sprinter
        local fastShamblerChance = zone.speed.fastShambler
        local shamblerChance = zone.speed.shambler

        local speedDetermined = ((ZombRand(1,101) <= sprinterChance) and "sprint"..ZombRand(1,6)) or
                ((ZombRand(1,101) <= fastShamblerChance) and ZombRand(1,6)) or
                ((ZombRand(1,101) <= shamblerChance) and "slow"..ZombRand(1,4))

        zombieModData.ZombieZonesSpeed = speedDetermined
    end
    if zombieSpeed then zombie:setWalkType(zombieModData.ZombieZonesSpeed) end

    local canCrawlUnderVehicle = zone.canCrawlUnderVehicle and (zone.canCrawlUnderVehicle=="false" and false) or (zone.canCrawlUnderVehicle=="true" and true) or SandboxVars.ZombieLore.CrawlUnderVehicle
    zombie:setCanCrawlUnderVehicle(canCrawlUnderVehicle)

    local dayNightActivity = zone.dayNightActivity
    local hour = getGameTime():getHour()
    local shouldBeActive = (hour >= dayNightActivity.start and hour <= dayNightActivity.stop)
    zombie:makeInactive(not shouldBeActive)

    zombie:addLineChatElement(tostring(zombie:getID()).." _ "..tostring(zombie:getOnlineID())..
            "\nspeed:"..tostring(zombieModData.ZombieZonesSpeed)..
            "\ncanCrawlUnderVehicle:"..tostring(canCrawlUnderVehicle))
end

return zombieZonesAIHandler