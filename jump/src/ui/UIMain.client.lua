local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local UIManager = require(game.StarterGui.UIScript.UIManager)

local main = UIManager:Get("主界面")

main['数据栏位']['现在高度']['文字'].Text = string.format("%.2f m", 0)
main['数据栏位']['速度']['文字'].Text = string.format("%.2f m/s", 0)

EventCenter:AddCEventListener(EventCenter.EventType.CUpdateStrength, function(strength)
    main['资源栏对齐']['力量资源条']['力量剩余'].Text = strength
end)

EventCenter:AddCEventListener(EventCenter.EventType.CUpdateHighestHeight, function(val)
    main['数据栏位']['最高高度']['文字'].Text = string.format("%.2f m", val)
end)

EventCenter:AddCEventListener(EventCenter.EventType.CUpdateCoin, function(val)
    main['资源栏对齐']['金币资源条']['金币剩余'].Text = val
end)

EventCenter:AddCEventListener(EventCenter.EventType.CJumping, function(speedY, height, highestHeight)
    local newHighestHeight =highestHeight
    if height == nil then
        height = 0
    end
    if height > highestHeight then
        newHighestHeight = height
    end
    main['数据栏位']['最高高度']['文字'].Text = string.format("%.2f m", newHighestHeight)
    main['数据栏位']['现在高度']['文字'].Text = string.format("%.2f m", height)
    main['数据栏位']['速度']['文字'].Text = string.format("%.2f m/s", speedY)
end)

EventCenter:AddCEventListener(EventCenter.EventType.CLand, function(highestHeight)
    main['数据栏位']['最高高度']['文字'].Text = string.format("%.2f m", highestHeight)
    main['数据栏位']['现在高度']['文字'].Text = string.format("%.2f m", 0)
    main['数据栏位']['速度']['文字'].Text = string.format("%.2f m/s", 0)
end)


-- main['跳跃'].Activated:Connect(function(inputObject: InputObject, clickCount: number)
-- 	EventCenter:SendEvent(EventCenter.EventType.CAttack)
-- end)

main['功能按钮自动对齐']['背包'].Activated:Connect(function(inputObject: InputObject, clickCount: number)
    UIManager:Show("器材背包ui")
end)