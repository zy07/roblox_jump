local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local EffectManager = require(game.StarterPlayer.StarterPlayerScripts.Effect.EffectManager)
local Search = require(game.StarterPlayer.StarterPlayerScripts.Battle.Search.Search)
local machineTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.State.Player.PlayerStateMachine)
local idleStateTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.State.Player.PlayerIdleState)
local skillStateTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.State.Player.PlayerSkillState)
local jumpStateTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.State.Player.PlayerJumpState)
local jumpingStateTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.State.Player.PlayerJumpingState)
local fallStateTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.State.Player.PlayerFallState)
local trainStateTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.State.Player.PlayerTrainState)

local PlayerController = {}

-- Services
local Players = game:GetService("Players")
local tweenService = game:GetService("TweenService")

-- LocalPlayer
local Player = Players.LocalPlayer
local Character = nil
local characterParts = nil
local humanoid = nil
local humanoidRootPart = nil
local animator = nil
local animationIds = {
	"83155635118048", -- Idle
	"116855912188391", -- Walk
	"114685600680382", -- Prepare
	"127264515888392", -- StartJump
	"110870700549831", -- Jumping
	"125924335703879", -- Fall
	"107503732851722", -- Squat
}
local animationTracks = {}

-- StateMachine
local playerStateMachine = machineTemplate:new()
local idleState = idleStateTemplate:new(playerStateMachine)
local skillState = skillStateTemplate:new(playerStateMachine)
local jumpState = jumpStateTemplate:new(playerStateMachine, PlayerController)
local jumpingState = jumpingStateTemplate:new(playerStateMachine, PlayerController)
local fallState = fallStateTemplate:new(playerStateMachine, PlayerController)
local trainState = trainStateTemplate:new(playerStateMachine, PlayerController)
playerStateMachine:AddState("Idle", idleState)
playerStateMachine:AddState("Skill", skillState)
playerStateMachine:AddState("Jump", jumpState)
playerStateMachine:AddState("Jumping", jumpingState)
playerStateMachine:AddState("Fall", fallState)
playerStateMachine:AddState("Train", trainState)

function PlayerController:new(player)
	local obj = {}
	self.__index = self
	setmetatable(obj, self)
	obj.Player = player
	obj.Character = player.Character or player.CharacterAdded:Wait()
	obj:Init()
	return obj
end

function PlayerController:Init()
	Character = Player.Character or Player.CharacterAdded:Wait()
	characterParts = Character:GetDescendants()
	-- Ensure that the character's humanoid contains an "Animator" object
	humanoid = Character:WaitForChild("Humanoid")
	humanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	animator = humanoid:WaitForChild("Animator")
	-- Load the animation onto the animator
	for _, animId in animationIds do
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://"..animId
		local track = animator:LoadAnimation(animation)
		if animationTracks[animId] == nil then
			animationTracks[animId] = track
		end
	end
	local animateScript = Character:WaitForChild("Animate")
	animateScript.run.RunAnim.AnimationId = "rbxassetid://116855912188391"
	animateScript.idle.Animation1.AnimationId = "rbxassetid://83155635118048"
	animateScript.walk.WalkAnim.AnimationId = "rbxassetid://116855912188391"
	playerStateMachine:Run("Idle")
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	humanoid.StateChanged:Connect(function(oldState, newState)
		if newState == Enum.HumanoidStateType.Landed then
			playerStateMachine:ChangeState("Idle")
		end
	end)
end

-- local function onCharacterAdded(playerCharacter)
-- 	Character = playerCharacter
-- 	characterParts = Character:GetDescendants()
-- 	-- Ensure that the character's humanoid contains an "Animator" object
-- 	humanoid = Character:WaitForChild("Humanoid")
-- 	humanoidRootPart = Character:WaitForChild("HumanoidRootPart")
-- 	animator = humanoid:WaitForChild("Animator")
-- 	-- Load the animation onto the animator
-- 	for _, animId in animationIds do
-- 		local animation = Instance.new("Animation")
-- 		animation.AnimationId = "rbxassetid://"..animId
-- 		local track = animator:LoadAnimation(animation)
-- 		if animationTracks[animId] == nil then
-- 			animationTracks[animId] = track
-- 		end
-- 	end
--     rushEff = EffectManager:AddReplicatedStorageEffect("ͨ��-������?", humanoidRootPart.CFrame, humanoidRootPart, Character)
--     rushEffParticle = rushEff:FindFirstChildWhichIsA("ParticleEmitter")
-- 	hideRushEffect()
-- 	playerStateMachine:Run("Idle")
-- end

-- Player.CharacterAdded:Connect(onCharacterAdded)

function PlayerController:PlayAnim(animId)
	playAnim(animId)
end

function playAnim(animId)
	if animationTracks[animId] ~= nil then
		animationTracks[animId]:Play()
		return animationTracks[animId]
	else
		local anim = Instance.new("Animation")
		anim.AnimationId = animId
		local track = animator:LoadAnimation(anim)
		animationTracks[animId] = track
		track:Play()
		return track
	end
end

function PlayerController:StopAnim(animId)
	stopAnim(animId)
end

function stopAnim(animId)
	if animationTracks[animId] ~= nil then
		animationTracks[animId]:Stop()
		return animationTracks[animId]
	end
end

-- handleSAttack = function()
-- 	setPlayerTransparency(1)
-- 	showRushEffect()
-- 	task.wait(0.1)
-- 	setPlayerTransparency(0)
-- 	hideRushEffect()
-- 	-- local anim = playAnim("70625062208041")
-- 	-- anim:Play()
-- end

-- EventCenter:AddSEventListener(EventCenter.EventType.SAttack, handleSAttack)

function PlayerController:Update()
	playerStateMachine:Update()
end

function HandleAttack()
	playerStateMachine:ChangeState("Jump")
end

function HandleTrain()
	playerStateMachine:ChangeState("Train")
end

function PlayerController:SetWalkSpeed(walkSpeed)
	humanoid.WalkSpeed = walkSpeed
end

function PlayerController:Jumping()
	-- 施加向上的速度
	humanoidRootPart.Velocity = Vector3.new(0, 50, 0) -- 50 studs/秒的上升速度

	-- 如果要保持一段时间上升，可以结合BodyVelocity
	local bv = Instance.new("BodyVelocity")
	bv.Velocity = Vector3.new(0, 20, 0) -- 持续向上的速度
	bv.Parent = humanoidRootPart

	task.wait(3)	
	bv:Destroy()
end

EventCenter:AddCEventListener(EventCenter.EventType.CAttack, HandleAttack)
EventCenter:AddCEventListener(EventCenter.EventType.CTrain, HandleTrain)

return PlayerController