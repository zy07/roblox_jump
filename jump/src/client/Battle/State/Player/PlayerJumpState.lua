local stateBase = require(game.StarterPlayer.StarterPlayerScripts.State.StateBase)
local PlayerJumpState = stateBase:new()

local Player = nil
local CountDown = 3

function PlayerJumpState:new(machine, player)
    local obj = {}
    self.__index = self
    setmetatable(obj, self)
    obj.stateMachine = machine
    Player = player
    return obj
end

function PlayerJumpState:OnEnter()
    print("PlayerJumpPrepareState OnEnter")
    Player:PlayAnim("114685600680382")
    Player:SetWalkSpeed(0)
    task.wait(3)
    Player:StopAnim("114685600680382")
    Player:PlayAnim("127264515888392")
    task.wait(0.13)
    Player:StopAnim("127264515888392")
    Player:PlayAnim("110870700549831")
    self.stateMachine:ChangeState("Jumping")
end


return PlayerJumpState