local UIManager = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player.PlayerGui
local ui = playerGui:WaitForChild("UI")
local main = ui:WaitForChild("主界面")

uis ={
    ["主界面"] = main,
}

function UIManager:Get(name)
    if uis[name] then
        return uis[name]
    else
        warn("[NG Client] Not found UI "..tostring(name))
        return nil
    end
end

return UIManager