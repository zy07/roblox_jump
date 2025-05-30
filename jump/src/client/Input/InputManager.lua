local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local InputManager = {}

local UserInputService = game:GetService("UserInputService")

local function onInputEnded(inputObject, processedEvent)
	if processedEvent then return end

	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		EventCenter:SendEvent(EventCenter.EventType.CFire)
	elseif inputObject.UserInputType == Enum.UserInputType.Touch then
		EventCenter:SendEvent(EventCenter.EventType.CFire)
	elseif inputObject.UserInputType == Enum.UserInputType.Keyboard then
		if inputObject.KeyCode == Enum.KeyCode.One then
			EventCenter:SendEvent(EventCenter.EventType.CKeyboard, Enum.KeyCode.One)
		elseif inputObject.KeyCode == Enum.KeyCode.Two then
			EventCenter:SendEvent(EventCenter.EventType.CKeyboard, Enum.KeyCode.Two)
		end
	end
end

local function onInputBegan()
	--if UserInputService:IsKeyDown(Enum.KeyCode.F) then
	--	EventCenter:SendEvent(EventCenter.EventType.CTrain)
	--end
end

UserInputService.InputEnded:Connect(onInputEnded)

UserInputService.InputBegan:Connect(onInputBegan)

return InputManager