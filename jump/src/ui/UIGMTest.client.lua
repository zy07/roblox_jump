local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local UIManager = require(game.StarterGui.UIScript.UIManager)

local ui = UIManager:Get("开发测试")

ui['测试']['增加力量'].Activated:Connect(function(inputObject: InputObject, clickCount: number)
    print("GM Click Add Strength")
    EventCenter:SendSEvent(EventCenter.EventType.CReqForceUpdateStrength, ui['测试']['输入框']['TextBox'].Text)
end)