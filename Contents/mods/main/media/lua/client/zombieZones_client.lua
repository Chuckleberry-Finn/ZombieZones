require "zoneEditor"
zoneEditor.addZoneType("ZombieZones")

local zombieZonesAIHandler = require "zombieZones_AIHandler"
if zombieZonesAIHandler then Events.OnZombieUpdate.Add(zombieZonesAIHandler.onUpdate) end