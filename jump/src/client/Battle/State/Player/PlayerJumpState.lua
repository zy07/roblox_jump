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
    Player:PlayEffDisableBySelf("准备起跳特效")
    print("PlayerJumpPrepareState OnEnter")
    Player:PlayAnim("114685600680382", 0.3)
    Player:SetWalkSpeed(0)
    task.wait(1)
    Player:HideEff("准备起跳特效")
    Player:PlayAnim("127264515888392")
    --task.wait(0.1)
    self.stateMachine:ChangeState("Jumping")
end

return PlayerJumpState