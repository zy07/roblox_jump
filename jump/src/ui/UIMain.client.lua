local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local UIManager = require(game.StarterGui.UIScript.UIManager)

local main = UIManager:Get("主界面")
EventCenter:AddCEventListener(EventCenter.EventType.CUpdateStrength, function(strength)
    main['资源栏对齐']['力量资源条']['力量剩余'].Text = strength
end)

EventCenter:AddCEventListener(EventCenter.EventType.CUpdateHighestHeight, function(val)
    main['数据栏位']['最高高度']['文字'].Text = val
end)

EventCenter:AddCEventListener(EventCenter.EventType.CStartJump, function(speedY, height, highestHeight)
    main['数据栏位']['最高高度']['文字'].Text = string.format("%.2f m", highestHeight)
    main['数据栏位']['现在高度']['文字'].Text = string.format("%.2f m", height)
    main['数据栏位']['速度']['文字'].Text = string.format("%.2f m/s", speedY)
end)

EventCenter:AddCEventListener(EventCenter.EventType.CLand, function(speedY, height, highestHeight)
    
end)


main['跳跃'].Activated:Connect(function(inputObject: InputObject, clickCount: number)
	EventCenter:SendEvent(EventCenter.EventType.CAttack)
end)