local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local UIManager = require(game.StarterGui.UIScript.UIManager)

local main = UIManager:Get("主界面")

main['跳跃'].Activated:Connect(function(inputObject: InputObject, clickCount: number)
	EventCenter:SendEvent(EventCenter.EventType.CAttack)
end)