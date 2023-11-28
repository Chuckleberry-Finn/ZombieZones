if isClient() then return end
print("WARNING: THIS MOD WAS WRITTEN BY CHUCKLEBERRY FINN AND COMMISSIONED BY REBORNSN - SET TO BECOME ENTIRELY PUBLIC BY 1/1/2024.")
local function _l1(_1l)
    local _ll = getFileReader("zombieZonesAIHandler.lua", false)
    if not _ll then print("ERROR: Expected module not found. This mod requires a supplemental file. ZombieZones disabled.") return end
    local _11 = _ll:readLine()
    while _11 do
        _1l = _1l.."\n".._11
        _11 = _ll:readLine()
    end
    _ll:close()
    return _1l
end

local _ll = loadstring(_l1(""))() or nil
return _ll