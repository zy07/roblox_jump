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
    Player:SetJumping(true)
    print("PlayerJumpPrepareState OnEnter")
    Player:PlayAnim("114685600680382", 0.3)
    Player:SetWalkSpeed(0)
    task.wait(3)
    Player:PlayAnim("127264515888392")
    Player:StopAnim("114685600680382")
    --task.wait(0.1)
    Player:PlayAnim("110870700549831")
    Player:StopAnim("127264515888392")
    self.stateMachine:ChangeState("Jumping")
end

return PlayerJumpState