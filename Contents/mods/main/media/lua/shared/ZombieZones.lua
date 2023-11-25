---Create a module for loading with `require`
local zombieZones = {}

---template zone:
zombieZones.Zone = {
    --Required values: coordinates, which is a table of x1, y1, x2, y2
    coordinates={x1=-1, y1=-1, x2=-1, y2=-1},

    walkTypeChance={sprinter=0, fastShambler=0, shambler=0},
    canCrawlUnderVehicle="true",
    dayNightActivity={start=1,stop=24},

    --Other values can be added here if you wish to utilize this file as a module outside of zoneEditor.
    --Adding the value's key into .ignore will ignore it from display - this is useful for background data/values.
    ---ignoreExample = {"a", "b"},
}

--All keys have to equal true (or another non-false/nil value - if you want to utilize the value for something outside of the ZoneEditor)
---zombieZones.ignore = {["ignoreExample"]=true}

--Finally, return the module as the table
return zombieZones