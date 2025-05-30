local stateBase = require(game.StarterPlayer.StarterPlayerScripts.State.StateBase)
local PlayerIdleState = stateBase:new()

local Player = nil

function PlayerIdleState:new(machine, player)
    local obj = {}
    self.__index = self
    setmetatable(obj, self)
    obj.stateMachine = machine
    Player = player
    return obj
end

function PlayerIdleState:OnEnter()
    Player:PlayIdleAnim()
    if Player:CheckAutoTrain() then
        self.stateMachine:ChangeState("Train")
    end
end

function PlayerIdleState:OnUpdate()
    if Player:GetWalkSpeed() > 0 then
        self.stateMachine:ChangeState("Walk")
    end
end

return PlayerIdleState