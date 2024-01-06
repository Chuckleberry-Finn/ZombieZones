local zombieZonesAIHandler = require "zombieZonesAIHandler"
if zombieZonesAIHandler then Events.OnZombieUpdate.Add(zombieZonesAIHandler.onUpdate) end

Events.OnGameBoot.Add(function() print("ZombieZones: ver:JAN_5_2023") end)