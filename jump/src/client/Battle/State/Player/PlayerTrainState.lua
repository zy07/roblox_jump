local stateBase = require(game.StarterPlayer.StarterPlayerScripts.State.StateBase)
local PlayerTrainState = stateBase:new()

local Player = nil

function PlayerTrainState:new(machine, player)
    local obj = {}
    self.__index = self
    setmetatable(obj, self)
    obj.stateMachine = machine
    Player = player
    return obj
end

function PlayerTrainState:OnEnter()
    Player:SetTrainable(false)
    Player:PlayAnim("107503732851722")
    Player:SetWalkSpeed(0)
    task.wait(1)
    self.stateMachine:ChangeState("Idle")
end

function PlayerTrainState:OnLeave()
    Player:SetTrainable(true)
    Player:StopAnim("107503732851722")
    Player:SetWalkSpeed(16)
    Player:AddStrength()
end

return PlayerTrainState