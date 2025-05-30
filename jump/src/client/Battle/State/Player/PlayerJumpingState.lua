local stateBase = require(game.StarterPlayer.StarterPlayerScripts.State.StateBase)
local PlayerJumpingState = stateBase:new()

local Player = nil

function PlayerJumpingState:new(machine, player)
    local obj = {}
    self.__index = self
    setmetatable(obj, self)
    obj.stateMachine = machine
    Player = player
    return obj
end

function PlayerJumpingState:OnEnter()
    Player:Jumping()
    Player:PlayAnim("110870700549831")
    Player:PlayEff("起跳特效", 0.5)
end

function PlayerJumpingState:OnUpdate()
    local curSpeedY = Player:GetSpeedY()
	if curSpeedY <= 0 then
        Player:UpdateHighestHeight()
		self.stateMachine:ChangeState("Fall")
		return
    elseif curSpeedY >= 2000 then
        Player:PlayEffDisableBySelf("跳跃")
    elseif curSpeedY < 2000 then
        Player:HideEff("跳跃")
	end
end

function PlayerJumpingState:OnLeave()
    Player:StopAnim("110870700549831")
end

return PlayerJumpingState