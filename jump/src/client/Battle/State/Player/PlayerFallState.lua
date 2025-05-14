local stateBase = require(game.StarterPlayer.StarterPlayerScripts.State.StateBase)
local PlayerFallState = stateBase:new()

local Player = nil

function PlayerFallState:new(machine, player)
    local obj = {}
    self.__index = self
    setmetatable(obj, self)
    obj.stateMachine = machine
    Player = player
    return obj
end

function PlayerFallState:OnEnter()
    Player:PlayAnim("125924335703879", 0.3)
end

function PlayerFallState:OnLeave()
    Player:StopAnim("125924335703879")
end

return PlayerFallState