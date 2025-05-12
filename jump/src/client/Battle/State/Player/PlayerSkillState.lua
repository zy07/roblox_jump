local stateBase = require(game.StarterPlayer.StarterPlayerScripts.State.StateBase)
local PlayerSkillState = stateBase:new()

function PlayerSkillState:new(machine)
    local obj = {}
    self.__index = self
    setmetatable(obj, self)
    obj.stateMachine = machine
    return obj
end

return PlayerSkillState