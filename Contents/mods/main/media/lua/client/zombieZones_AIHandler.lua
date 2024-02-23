local zombieZonesAIHandler = {}

--strength, toughness, transmission, cognition, sight, hearing
-- memory = 1 = 1250, 2 = 800, 3 = 500, 4 = 25

require "zoneEditor"
function zombieZonesAIHandler.getZone(zombie)

    local zombieZones = zoneEditor.requestZone("ZombieZones")
    if not zombieZones then return false end

    for i, zone in pairs(zombieZones) do
        if zone.coordinates and zone.coordinates.x1 and zone.coordinates.x2 and zone.coordinates.y1 and zone.coordinates.y2 then

            local lowX = math.min(zone.coordinates.x1, zone.coordinates.x2)
            local highX = math.max(zone.coordinates.x1, zone.coordinates.x2)

            local lowY = math.min(zone.coordinates.y1, zone.coordinates.y2)
            local highY = math.max(zone.coordinates.y1, zone.coordinates.y2)

            if zone.coordinates and zombie:getX() >= lowX and zombie:getX() <= highX and zombie:getY() >= lowY and zombie:getY() <= highY then return zone end
        end
    end

    return false
end


zombieZonesAIHandler.walkTypes = { sprinter={id="sprint",rand=5}, fastShambler={id="",rand=5}, shambler={id="slow",rand=3}, }


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
    local weight, speeds = 0, { sprinter=zone.speed.sprinter, fastShambler=zone.speed.fastShambler, shambler=zone.speed.shambler}
    for _,chance in pairs(speeds) do weight = weight + (chance) end

    local zombieModData = zombie:getModData()
    zombieModData.ZombieZoneRand = zombieModData.ZombieZoneRand or zombieZonesAIHandler.seededRand(zombieZonesAIHandler.getTruePersistentOutfitID(zombie),weight)
    if zombieModData.ZombieZonesSpeed then return end

    weight = 0
    for speed,chance in pairs(speeds) do
        weight = weight + (chance)
        if weight >= zombieModData.ZombieZoneRand then return (zombieZonesAIHandler.walkTypes[speed].id..(ZombRand(1,zombieZonesAIHandler.walkTypes[speed].rand)+1)) end
    end
end


--https://stackoverflow.com/questions/5977654/how-do-i-use-the-bitwise-operator-xor-in-lua
zombieZonesAIHandler.bit = {}

function zombieZonesAIHandler.bit.Xor(a,b)--Bitwise xor
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra~=rb then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    if a<b then a=b end
    while a>0 do
        local ra=a%2
        if ra>0 then c=c+p end
        a,p=(a-ra)/2,p*2
    end
    return c
end

function zombieZonesAIHandler.bit.Or(a,b)
    local p,c=1,0
    while a+b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>0 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

function zombieZonesAIHandler.bit.And(a,b)
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

function zombieZonesAIHandler.bit.Not(n)
    local p,c=1,0
    while n>0 do
        local r=n%2
        if r<1 then c=c+p end
        n,p=(n-r)/2,p*2
    end
    return c
end


zombieZonesAIHandler.idMatrix = {trueID={}, hatFallen={}}
---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
function zombieZonesAIHandler.getTruePersistentOutfitID(zombie)
    local bit = zombieZonesAIHandler.bit
    local pID = zombie:getPersistentOutfitID()

    local found = zombieZonesAIHandler.idMatrix.trueID[pID] or zombieZonesAIHandler.idMatrix.hatFallen[pID]
    if found then return found end

    local neuteredID = math.abs(pID)

    local trueID = (bit.And(neuteredID,32768) ~= 0) and bit.And(neuteredID,-32769) or neuteredID
    local hatID = bit.Or(trueID,32768)

    trueID = ((pID<0) and 0-trueID) or trueID

    zombieZonesAIHandler.idMatrix.trueID[trueID] = trueID
    zombieZonesAIHandler.idMatrix.hatFallen[hatID] = trueID

    return trueID
end


---@param zombie IsoZombie|IsoGameCharacter|IsoMovingObject|IsoObject
function zombieZonesAIHandler.onUpdate(zombie)

    ---zombie mod data is not saved unless it's a reanimated player
    if zombie:isReanimatedPlayer() then return end
    local zombieModData = zombie:getModData()
    local zone = zombieZonesAIHandler.getZone(zombie)

    local oldPersistentID = zombieModData.ZombieZonesPersistentID
    if oldPersistentID and oldPersistentID~=zombieZonesAIHandler.getTruePersistentOutfitID(zombie) then
        zombieModData.ZombieZonesSpeed = nil
        zombieModData.ZombieZoneRand = nil
    end
    zombieModData.ZombieZonesPersistentID = zombieZonesAIHandler.getTruePersistentOutfitID(zombie)

    local dayNightActivity = zone and zone.dayNightActivity
    local hour = getGameTime():getHour()
    local shouldBeActive = true
    if dayNightActivity then
        if (dayNightActivity.start >= dayNightActivity.stop) then
            shouldBeActive = (hour >= dayNightActivity.start or hour < dayNightActivity.stop)
        else
            shouldBeActive = (hour >= dayNightActivity.start and hour < dayNightActivity.stop)
        end
    end

    zombie:makeInactive(not shouldBeActive)
    if shouldBeActive then

        local zombieSpeed = zombieModData.ZombieZonesSpeed
        if zombieSpeed == nil then
            if zone then
                zombieModData.ZombieZonesSpeed = zombieZonesAIHandler.rollForSpeed(zone, zombie)
            else
                zombieModData.ZombieZonesSpeed = false
            end
        end
        if zombieSpeed then zombie:setWalkType(zombieModData.ZombieZonesSpeed) end

        local canCrawlUnderVehicle = nil
        if zone and zone.canCrawlUnderVehicle then canCrawlUnderVehicle = (zone.canCrawlUnderVehicle=="false" and false) or (zone.canCrawlUnderVehicle=="true" and true) end

        if canCrawlUnderVehicle~=nil then zombie:setCanCrawlUnderVehicle(canCrawlUnderVehicle) end
    end

    if getDebug() then
        --zombie:addLineChatElement("i:"..tostring(shouldBeActive).."  s:"..tostring(zombieModData.ZombieZonesSpeed).. "\npOID:"..(zombie:getPersistentOutfitID()).." r: "..tostring(zombieModData.ZombieZoneRand))

        local pID = zombie:getPersistentOutfitID()

        local tID = zombieZonesAIHandler.getTruePersistentOutfitID(zombie)

        local bits = Integer.toBinaryString(pID); -- returns a string with 0 and 1's
        local reordered = string.reverse(bits); -- if you wanna handle it that way, then swap the hat bit around however you wish (16th bit from the back?)
        local modified = reordered-- whatever work you gotta do
        local res = Integer.toUnsignedInteger(string.reverse(modified), 2);
        zombie:addLineChatElement(" -: "..reordered.."\n  : "..res.."\n")

        --zombie:addLineChatElement(" -: "..pID.."\n  : "..tID.."\n")
    end
end

return zombieZonesAIHandler
