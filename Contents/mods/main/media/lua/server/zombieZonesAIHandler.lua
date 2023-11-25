local zombieZonesAIHandler = {}

--speed
--strength
--toughness
--transmission
--infectionmortality
--reanimatetime
--cognition
--crawlundervehicle
--memory
--sight
--hearing
--day/night
--dragDown
--fenceLunge
--fakeDead

--setCanCrawlUnderVehicle

--      WT1("1"),
--      WT2("2"),
--      WT3("3"),
--      WT4("4"),
--      WT5("5"),
--      WTSprint1("sprint1"),
--      WTSprint2("sprint2"),
--      WTSprint3("sprint3"),
--      WTSprint4("sprint4"),
--      WTSprint5("sprint5"),
--      WTSlow1("slow1"),
--      WTSlow2("slow2"),
--      WTSlow3("slow3");

--zombie:setWalkType("sprint1")
--zombie:setNoTeeth(true)
--zombie:setWalkType("slow1")
--zombie:setCanWalk(true)

--if zombie:isCrawling() then zombie:toggleCrawling() end

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
    if not zombieSpeed then

        local sprinterChance = zone.walkTypeChance.sprinter
        local fastShamblerChance = zone.walkTypeChance.fastShambler
        local shamblerChance = zone.walkTypeChance.shambler

        local speedDetermined = ((ZombRand(101) < sprinterChance) and "sprint"..ZombRand(1,6)) or
                ((ZombRand(101) < fastShamblerChance) and ZombRand(1,6)) or
                ((ZombRand(101) < shamblerChance) and "slow"..ZombRand(1,4))

        zombieModData.ZombieZonesSpeed = speedDetermined
    else
        zombie:setWalkType(zombieModData.ZombieZonesSpeed)
    end

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