local function loadFile()
    local reader = getFileReader("zombieZonesAIHandler.lua", false)
    local lines = ""
    local line = reader:readLine()
    while line do
        lines = lines.."\n"..line
        line = reader:readLine()
    end
    reader:close()
    return lines
end

print("WARNING THIS MOD WAS WRITTEN BY CHUCKLEBERRY FINN AND COMMISSIONED BY REBORNSN - SET TO BECOME ENTIRELY PUBLIC BY 1/1/2024.")

local zombieZonesAIHandler = {}

zombieZonesAIHandler = loadstring(loadFile())()
print("MODULE FOUND: "..tostring(zombieZonesAIHandler))
for k,v in pairs(zombieZonesAIHandler) do print(" --: "..tostring(k).." = "..tostring(v)) end

return zombieZonesAIHandler