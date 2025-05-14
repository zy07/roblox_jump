local stateBase = require(game.StarterPlayer.StarterPlayerScripts.State.StateBase)
local PlayerJumpingState = stateBase:new()

local Player = nil
local LastY = 0

function PlayerJumpingState:new(machine, player)
    local obj = {}
    self.__index = self
    setmetatable(obj, self)
    obj.stateMachine = machine
    Player = player
    return obj
end

function PlayerJumpingState:OnEnter()
    Player:Jumping()
end

function PlayerJumpingState:OnUpdate()
	local curY = Player:GetCurY()
	if curY < LastY then
		self.stateMachine:ChangeState("Fall")
		return
	end
	LastY = curY
	Player:LogJumping()
end

function PlayerJumpingState:OnLeave()
	LastY = 0
    Player:StopAnim("110870700549831")
end

return PlayerJumpingState