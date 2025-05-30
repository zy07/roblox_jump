local UIManager = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player.PlayerGui
local ui = playerGui:WaitForChild("UI")
local main = ui:WaitForChild("主界面")
local gm = ui:WaitForChild("开发测试")
local equipment = ui:WaitForChild("器材背包ui")
local gainResources = ui:WaitForChild("获得资源")

uis ={
    ["主界面"] = main,
    ["开发测试"] = gm,
    ["器材背包ui"] = equipment,
    ["获得资源"] = gainResources,
}

function UIManager:Show(name)
    if uis[name] then
        uis[name].Visible = true
    else
        warn("[NG Client] Not found UI "..tostring(name))
    end
end

function UIManager:Hide(name)
    if uis[name] then
        uis[name].Visible = false
    else
        warn("[NG Client] Not found UI "..tostring(name))
    end
end

function UIManager:Get(name)
    if uis[name] then
        return uis[name]
    else
        warn("[NG Client] Not found UI "..tostring(name))
        return nil
    end
end

return UIManager