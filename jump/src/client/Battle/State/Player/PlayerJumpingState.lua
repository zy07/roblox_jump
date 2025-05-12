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
    self.stateMachine:ChangeState("Fall")
end

return PlayerJumpingState