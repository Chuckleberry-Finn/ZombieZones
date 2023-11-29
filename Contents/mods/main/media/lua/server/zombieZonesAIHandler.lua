if isClient() then return end

print("WARNING: ZOMBIE ZONES WAS WRITTEN BY CHUCKLEBERRY FINN AND COMMISSIONED BY ZAC/REBORNSN - IT IS CURRENTLY EXCLUSIVE AND SET TO BECOME ENTIRELY PUBLIC BY 1/1/2024.")
local function _l1(_1l)
    local _ll = getFileReader("zombieZonesAIHandler.lua", false)
    if not _ll then print("ERROR: ZOMBIE ZONES: Expected module not found. This mod requires a supplemental file. ZombieZones disabled.") return end
    local _11 = _ll:readLine()
    while _11 do
        _1l = _1l.."\n".._11
        _11 = _ll:readLine()
    end
    _ll:close()
    return _1l
end

local _11 = _l1("")

local function onClientCommand(_m, _c, _p, _d)
    if _m ~= "zz" or not _p or not _11 then return end
    if isServer() then sendServerCommand(_p,"zz", "z", {s=_11}) else return _11 end
end
Events.OnClientCommand.Add(onClientCommand)