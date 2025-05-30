local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local SharedEvent = require(game.ReplicatedStorage.Shared.EventHandlesCenter)
local UIManager = require(game.StarterGui.UIScript.UIManager)
local ModTimer = require(game.StarterPlayer.StarterPlayerScripts.Module.ModTimer)
local ui = UIManager:Get("获得资源")

local template = ui["获得资源"]
template.Visible = false

local gainIcon = {
    ["力量"] = "rbxassetid://91343832506556",
    ["金币"] = "rbxassetid://119678771365821",
    ["重生"] = "rbxassetid://121813900109826"
}

EventCenter:AddCEventListener(EventCenter.EventType.CGainResources, function(gainType, num)
    local newTemplate = template:Clone()
    newTemplate.Parent = template.Parent
    newTemplate.Visible = true

    if gainType == "coin" then
        newTemplate["图标"].Image = gainIcon["金币"]
    elseif gainType == "strength" then
        newTemplate["图标"].Image = gainIcon["力量"]
    end
    newTemplate["图标"]["数量"].Text = " + "..num

    newTemplate["图标"].Position = UDim2.new(math.random(), 0, math.random(), 0)
    ModTimer:AddTimer(2, function()
        newTemplate:Destroy()
    end)
    -- task.wait(2)
end)

EventCenter:AddCEventListener(EventCenter.EventType.CUpdateCoin, function(val)
    local newTemplate = template:Clone()
    newTemplate.Parent = template.Parent
    newTemplate.Visible = true
end)