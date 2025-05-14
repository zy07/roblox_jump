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
local landStateTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.State.Player.PlayerLandState)
local propertyTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.Property.Property)

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
	"83173520624654", -- Land
	"107503732851722", -- Squat
}
local animationTracks = {}

-- Property
local property = propertyTemplate:new()

-- StateMachine
local playerStateMachine = machineTemplate:new()
local idleState = idleStateTemplate:new(playerStateMachine)
local skillState = skillStateTemplate:new(playerStateMachine)
local jumpState = jumpStateTemplate:new(playerStateMachine, PlayerController)
local jumpingState = jumpingStateTemplate:new(playerStateMachine, PlayerController)
local fallState = fallStateTemplate:new(playerStateMachine, PlayerController)
local trainState = trainStateTemplate:new(playerStateMachine, PlayerController)
local landState = landStateTemplate:new(playerStateMachine, PlayerController)
playerStateMachine:AddState("Idle", idleState)
playerStateMachine:AddState("Skill", skillState)
playerStateMachine:AddState("Jump", jumpState)
playerStateMachine:AddState("Jumping", jumpingState)
playerStateMachine:AddState("Fall", fallState)
playerStateMachine:AddState("Train", trainState)
playerStateMachine:AddState("Land", landState)

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
	animateScript.idle.Animation2.AnimationId = "rbxassetid://83155635118048"
	animateScript.walk.WalkAnim.AnimationId = "rbxassetid://116855912188391"
	playerStateMachine:Run("Idle")
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	local gravity = workspace.Gravity -- 获取当前重力值
    
    -- 创建反向力（大小 = 质量 × 重力）
    --local antiGravity = Instance.new("BodyForce")
    --antiGravity.Force = Vector3.new(0, humanoidRootPart:GetMass() * gravity, 0)
    --antiGravity.Parent = humanoidRootPart
	humanoid.StateChanged:Connect(function(oldState, newState)
		if newState == Enum.HumanoidStateType.Landed then
			playerStateMachine:ChangeState("Land")
		end
	end)

	property["Strength"] = 0
	property["Jumpable"] = true
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

function PlayerController:PlayAnim(animId, timer)
	playAnim(animId, timer)
end

function playAnim(animId, timer)
	timer = timer or 0
	if animationTracks[animId] ~= nil then
		animationTracks[animId]:Play(timer)
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
	local canJump = property["Jumpable"]
	if canJump then
		playerStateMachine:ChangeState("Jump")
	end
end

function HandleTrain()
	if property["Trainable"] then
		playerStateMachine:ChangeState("Train")
	end
end

function PlayerController:SetWalkSpeed(walkSpeed)
	humanoid.WalkSpeed = walkSpeed
end

function PlayerController:SetJumpable(jumpable)
	property["Jumpable"] = jumpable
end
function PlayerController:SetTrainable(trainable)
	property["Trainable"] = trainable
end

local OriginPosY = 0

function PlayerController:Jumping()
	OriginPosY = humanoidRootPart.CFrame.Position.Y
	-- 如果要保持一段时间上升，可以结合BodyVelocity
	
	--local goal = {}
	--goal.CFrame = CFrame.new(humanoidRootPart.CFrame.Position.X, 100, humanoidRootPart.CFrame.Position.Z)
	
	local bv1 = Instance.new("VectorForce")
	bv1.Force = Vector3.new(0, 2000000 + property["Strength"] * 2, 0)
	print("当前的起跳速度为："..bv1.Force.Y)
	bv1.RelativeTo = Enum.ActuatorRelativeTo.World
	bv1.Attachment0 = humanoidRootPart:FindFirstChildOfClass("Attachment") or Instance.new("Attachment")
	bv1.Attachment0.Parent = humanoidRootPart
	bv1.Parent = humanoidRootPart
	
	local goal = {}
	goal.Force = Vector3.new(0, 0, 0)
	local info = TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0);
	--local tween = tweenService:Create(humanoidRootPart, info, goal)
	local tween = tweenService:Create(bv1, info, goal)
	tween:Play()
	task.wait(1)
	bv1:Destroy()tween:Destroy()
end

function PlayerController:LogJumping()
	print(humanoidRootPart.CFrame.Position.Y)
end

function PlayerController:GetCurY()
	return humanoidRootPart.CFrame.Position.Y
end

function PlayerController:ChangeState(state)
	humanoid:ChangeState(state)
end

function PlayerController:AddStrength()
	-- TODO: has other things can add strength
	property["Strength"] = property["Strength"] + 1
	self:PrintStrength()
end

function PlayerController:PrintStrength()
	print("你的力量现在是："..property["Strength"])
end

EventCenter:AddCEventListener(EventCenter.EventType.CAttack, HandleAttack)
EventCenter:AddCEventListener(EventCenter.EventType.CTrain, HandleTrain)

return PlayerController