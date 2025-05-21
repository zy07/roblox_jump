local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local SharedEvent = require(game.ReplicatedStorage.Shared.EventHandlesCenter)
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
local ModEquipment = require(game.StarterPlayer.StarterPlayerScripts.Module.ModEquipment)

local PlayerController = {}

PlayerController.StateType = {
    DEFAULT = 0,
    EQUIP = 1,
    JUMP = 2,
}

PlayerController.CurState = PlayerController.StateType.DEFAULT

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
	"76376945167646", -- without equip idle
	"93441484014353", -- without equip walk
	"83155635118048", -- Idle
	"116855912188391", -- Walk
	"114685600680382", -- Prepare
	"127264515888392", -- StartJump
	"110870700549831", -- Jumping
	"125924335703879", -- Fall
	"83173520624654", -- Land
	"107503732851722", -- Squat
	"111855132298439", -- Idle2Equip
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
	animateScript.run.RunAnim.AnimationId = "rbxassetid://93441484014353"
	animateScript.idle.Animation1.AnimationId = "rbxassetid://76376945167646"
	animateScript.idle.Animation2.AnimationId = "rbxassetid://76376945167646"
	animateScript.walk.WalkAnim.AnimationId = "rbxassetid://93441484014353"
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
	property["Trainable"] = false
	property["Jumpable"] = false
	EventCenter:AddSEventListener(SharedEvent.EventType.SResStrength, HandleResponseStrength)
	EventCenter:AddSEventListener(SharedEvent.EventType.SResHighestHeight, HandleResponseHighestHeight)
	EventCenter:AddSEventListener(SharedEvent.EventType.SResCoin, HandleResponseCoin)
	EventCenter:SendSEvent(SharedEvent.EventType.CReqStrength) 
	EventCenter:SendSEvent(SharedEvent.EventType.CReqHighestHeight)
	EventCenter:SendSEvent(SharedEvent.EventType.CRequestCoin)
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
	local curSpeedY = self:GetSpeedY()
	if property["Jumping"] then
		EventCenter:SendEvent(EventCenter.EventType.CJumping, curSpeedY, humanoidRootPart.CFrame.Position.Y, property["HighestHeight"])
	end 
end

function HandleTrain()
	print(property)
	if property["Trainable"] then
		playerStateMachine:ChangeState("Train")
	end
end

function HandleAttack()
	print(property)
	if property["Jumpable"] and not property["Jumping"] then
		playerStateMachine:ChangeState("Jump")
	end
end

function HandleFire()
	HandleTrain()
	HandleAttack()
end

function HandleResponseStrength(strength)
	property["Strength"] = strength
	EventCenter:SendEvent(EventCenter.EventType.CUpdateStrength, strength)
end

function HandleResponseHighestHeight(highestHeight)
	property["HighestHeight"] = highestHeight
	EventCenter:SendEvent(EventCenter.EventType.CUpdateHighestHeight, highestHeight)
end

function HandleResponseCoin(coin)
	property["Coin"] = coin
	EventCenter:SendEvent(EventCenter.EventType.CUpdateCoin, coin)
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

function PlayerController:SetJumping(jumping)
	property["Jumping"] = jumping
end

local OriginPosY = 0

function PlayerController:Jumping()
	OriginPosY = humanoidRootPart.CFrame.Position.Y
	-- 如果要保持一段时间上升，可以结合BodyVelocity
	
	--local goal = {}
	--goal.CFrame = CFrame.new(humanoidRootPart.CFrame.Position.X, 100, humanoidRootPart.CFrame.Position.Z)
	
	local bv1 = Instance.new("VectorForce")
	bv1.Force = Vector3.new(0, 10000 + property["Strength"] * 2, 0)
	-- bv1.Force = Vector3.new(0, humanoidRootPart:GetMass() * workspace.Gravity + 1, 0)
	bv1.RelativeTo = Enum.ActuatorRelativeTo.World
	bv1.Attachment0 = humanoidRootPart:FindFirstChildOfClass("Attachment") or Instance.new("Attachment")
	bv1.Attachment0.Parent = humanoidRootPart
	bv1.Parent = humanoidRootPart

	-- humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.CFrame.Position.X, 1000000, humanoidRootPart.CFrame.Position.Z)
	
	-- local goal = {}
	-- goal.Force = Vector3.new(0, 0, 0)
	-- local info = TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0);
	-- --local tween = tweenService:Create(humanoidRootPart, info, goal)
	-- local tween = tweenService:Create(bv1, info, goal)
	-- tween:Play()
	task.wait(0.1)
	bv1:Destroy()
	-- tween:Destroy()
end

function PlayerController:LogJumping()
	-- print(humanoidRootPart.CFrame.Position.Y)
	print(humanoidRootPart.AssemblyLinearVelocity.Y)
end

function PlayerController:GetSpeedY()
	return humanoidRootPart.AssemblyLinearVelocity.Y
end

function PlayerController:GetCurY()
	return humanoidRootPart.CFrame.Position.Y
end

function PlayerController:ChangeState(state)
	humanoid:ChangeState(state)
end

function PlayerController:AddStrength()
	-- TODO: has other things can add strength
	EventCenter:SendSEvent(SharedEvent.EventType.SUpdateStrength)
end

function PlayerController:UpdateHighestHeight()
	EventCenter:SendSEvent(SharedEvent.EventType.SUpdateHighestHeight)
end

function PlayerController:LeaveLand()
    self:SetJumping(false)
	self:SetWalkSpeed(16)
	EventCenter:SendEvent(EventCenter.EventType.CLand, property["HighestHeight"])
end

EventCenter:AddCEventListener(EventCenter.EventType.CFire, HandleFire)

function PlayerController:GetProperty(propertyKey)
	local val = property[propertyKey]
	if val == nil then
		warn("Property " .. propertyKey .. " not found")
		return nil
	end
	return property[propertyKey]
end

function PlayerController:HandleChangeEquipAnim(state)
	local preState = self.CurState
	if state == self.StateType.EQUIP then
        if self.CurState == self.StateType.EQUIP then
            EventCenter:SendSEvent(SharedEvent.EventType.CReqHideEquip)
        else
            EventCenter:SendSEvent(SharedEvent.EventType.CReqShowEquip)
        end
    end

    if self.CurState == self.StateType.EQUIP and state ~= self.StateType.EQUIP then
        EventCenter:SendSEvent(SharedEvent.EventType.CReqHideEquip)
    end

    if self.CurState == state then
        self.CurState = self.StateType.DEFAULT
    else
        self.CurState = state
    end

	if self.CurState == self.StateType.DEFAULT then
		property["Trainable"] = false
		property["Jumpable"] = false
	elseif self.CurState == self.StateType.JUMP then
		property["Jumpable"] = true
		property["Trainable"] = false
	else
		property["Trainable"] = true
		property["Jumpable"] = false
	end

	local animateScript = Character:WaitForChild("Animate")
	if self.CurState == self.StateType.EQUIP then
		animateScript.run.RunAnim.AnimationId = "rbxassetid://116855912188391"
		animateScript.idle.Animation1.AnimationId = "rbxassetid://83155635118048"
		animateScript.idle.Animation2.AnimationId = "rbxassetid://83155635118048"
		animateScript.walk.WalkAnim.AnimationId = "rbxassetid://116855912188391"
	else
		animateScript.run.RunAnim.AnimationId = "rbxassetid://93441484014353"
		animateScript.idle.Animation1.AnimationId = "rbxassetid://76376945167646"
		animateScript.idle.Animation2.AnimationId = "rbxassetid://76376945167646"
		animateScript.walk.WalkAnim.AnimationId = "rbxassetid://93441484014353"
	end
	local animations = animator:GetPlayingAnimationTracks()
	for _, anim in animations do
		print(anim.name)
	end
	if (preState == self.StateType.DEFAULT or preState == self.StateType.JUMP) and self.CurState ~= self.StateType.EQUIP then
		return
	end
	if (preState == self.StateType.DEFAULT or preState == self.StateType.JUMP) and self.CurState == self.StateType.EQUIP then
		playAnim("111855132298439", 0.1)
		task.wait(0.3)
		stopAnim("111855132298439")
	end
	-- animateScript.Parent = nil
	-- task.wait()
	-- animateScript.Parent = Character
end

function PlayerController:HandleEuiqpmentChanged()
	if self.CurState == self.StateType.EQUIP then
        EventCenter:SendSEvent(SharedEvent.EventType.CReqShowEquip)
    end
end

return PlayerController