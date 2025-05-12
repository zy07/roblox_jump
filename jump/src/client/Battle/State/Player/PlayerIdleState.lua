local stateBase = require(game.StarterPlayer.StarterPlayerScripts.State.StateBase)
local PlayerIdleState = stateBase:new()

function PlayerIdleState:new(machine)
    local obj = {}
    self.__index = self
    setmetatable(obj, self)
    obj.stateMachine = machine
    return obj
end

return PlayerIdleState