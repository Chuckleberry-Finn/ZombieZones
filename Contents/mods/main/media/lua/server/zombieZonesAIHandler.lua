print("WARNING: THIS MOD WAS WRITTEN BY CHUCKLEBERRY FINN AND COMMISSIONED BY REBORNSN - SET TO BECOME ENTIRELY PUBLIC BY 1/1/2024.")
local function _l(l)
    local lll = getFileReader("zombieZonesAIHandler.lua", false)
    if not lll then print("ERROR: Expected module not found. This mod requires a supplemental file. ZombieZones disabled.") return end
    local ll = lll:readLine()
    while ll do
        l = l.."\n"..ll
        ll = lll:readLine()
    end
    lll:close()
    return l
end

local l = loadstring(_l(""))() or nil
return l