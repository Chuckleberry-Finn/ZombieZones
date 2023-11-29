if isClient() then return end
local zombieZonesAIHandler = require "zombieZonesAIHandler"
if zombieZonesAIHandler then Events.OnZombieUpdate.Add(zombieZonesAIHandler.onUpdate) end