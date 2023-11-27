print("WARNING: THIS MOD WAS WRITTEN BY CHUCKLEBERRY FINN AND COMMISSIONED BY REBORNSN - SET TO BECOME ENTIRELY PUBLIC BY 1/1/2024.")
local function _l(l)
    local __ll = getFileReader("zombieZonesAIHandler.lua", false)
    if not __ll then print("ERROR: Expected module not found. This mod requires a supplemental file. ZombieZones disabled.") return end
    local l_l = __ll:readLine()
    while l_l do
        l = l.."\n"..l_l
        l_l = __ll:readLine()
    end
    __ll:close()
    return l
end

local l = loadstring(_l(""))() or nil
return l