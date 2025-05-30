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
    Player:SetTraining(true)
    Player:PlayAnim("107503732851722")
    Player:PlayEff("训练特效", 0.3)
    task.wait(0.65)
    Player:StopAnim("107503732851722")
    if Player:GetWalkSpeed() > 0 then
        self.stateMachine:ChangeState("Walk")
    else
        self.stateMachine:ChangeState("Idle")
    end
end

function PlayerTrainState:OnLeave()
    Player:SetTraining(false)
    Player:AddStrength()
end

return PlayerTrainState