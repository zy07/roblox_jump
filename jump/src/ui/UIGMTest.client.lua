local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local UIManager = require(game.StarterGui.UIScript.UIManager)

local ui = UIManager:Get("开发测试")

ui['加力量']['增加'].Activated:Connect(function(inputObject: InputObject, clickCount: number)
    print("GM Click Add Strength")
    EventCenter:SendEvent(EventCenter.EventType.CUpdateStrength, ui['加力量']['输入框']['TextBox'].Text)
end)