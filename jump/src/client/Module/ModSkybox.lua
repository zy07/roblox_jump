local lightning = game:GetService("Lighting")
local SkyBox = {}

local skyResFolder = lightning:WaitForChild("天空")
local curSky = nil
local skys = {}

local lightningChildren = lightning:GetChildren()
for _, child in lightningChildren do
    if child:IsA("Sky") then
        curSky = child
        break
    end
end
local children = skyResFolder:GetChildren()
for _, child in children do
    skys[child.name] = child
end

function SkyBox:Change(name)
    if curSky.name == name then
        return
    end

    local findSky = skys[name]
    if findSky then
        curSky.Parent = skyResFolder
        curSky = findSky
        curSky.Parent = lightning
    end
end

return SkyBox