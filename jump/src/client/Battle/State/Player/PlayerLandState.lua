local stateBase = require(game.StarterPlayer.StarterPlayerScripts.State.StateBase)
local PlayerLandState = stateBase:new()

local Player = nil

function PlayerLandState:new(machine, player)
    local obj = {}
    self.__index = self
    setmetatable(obj, self)
    obj.stateMachine = machine
    Player = player
    return obj
end

function PlayerLandState:OnEnter()
    Player:PlayAnim("83173520624654")
    Player:PlayEff("落地特效", 0.1)
    task.wait(0.9)
    Player:StopAnim("83173520624654")
    Player:FixedStateAfterLand()
    self.stateMachine:ChangeState("Idle")
end

function PlayerLandState:OnLeave()
    Player:LeaveLand()
end

return PlayerLandState