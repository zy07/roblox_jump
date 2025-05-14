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
    task.wait(1)
    self.stateMachine:ChangeState("Idle")
end

function PlayerLandState:OnLeave()
	Player:SetWalkSpeed(16)
end

return PlayerLandState