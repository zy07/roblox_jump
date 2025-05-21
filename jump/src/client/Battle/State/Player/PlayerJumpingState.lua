local stateBase = require(game.StarterPlayer.StarterPlayerScripts.State.StateBase)
local PlayerJumpingState = stateBase:new()

local Player = nil

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
    local curSpeedY = Player:GetSpeedY()
	if curSpeedY <= 0 then
        Player:UpdateHighestHeight()
		self.stateMachine:ChangeState("Fall")
		return
	end
end

function PlayerJumpingState:OnLeave()
    Player:StopAnim("110870700549831")
end

return PlayerJumpingState