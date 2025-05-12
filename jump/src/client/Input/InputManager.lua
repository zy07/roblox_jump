local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local InputManager = {}

local UserInputService = game:GetService("UserInputService")

local function onInputEnded(inputObject, processedEvent)
	if processedEvent then return end

	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
        EventCenter:SendEvent(EventCenter.EventType.CAttack)
		
		print("Left Mouse button was pressed:", inputObject.Position)
	elseif inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
		print("Right Mouse button was pressed:", inputObject.Position)
	end
end

UserInputService.InputEnded:Connect(onInputEnded)

return InputManager