local stateBase = require(game.StarterPlayer.StarterPlayerScripts.State.StateBase)
local PlayerWalkState = stateBase:new()

local Player = nil

function PlayerWalkState:new(machine, player)
    local obj = {}
    self.__index = self
    setmetatable(obj, self)
    obj.stateMachine = machine
    Player = player
    return obj
end

function PlayerWalkState:OnEnter()
    Player:PlayWalkAnim()
end

function PlayerWalkState:OnUpdate()
    if Player:GetWalkSpeed() <= 0 then
        self.stateMachine:ChangeState("Idle")
    end
end

return PlayerWalkState