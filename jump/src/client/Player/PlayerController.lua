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
local walkStateTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.State.Player.PlayerWalkState)
local propertyTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.Property.Property)
local ModEquipment = require(game.StarterPlayer.StarterPlayerScripts.Module.ModEquipment)
local ModSkybox = require(game.StarterPlayer.StarterPlayerScripts.Module.ModSkybox)

local PlayerController = {}

PlayerController.StateType = {
    DEFAULT = 0,
    EQUIP = 1,
    JUMP = 2,
}

local CurState = PlayerController.StateType.DEFAULT

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
}

local actionAnimationIds = {
	"107503732851722", -- Squat
	"111855132298439", -- Idle2Equip
}

local action2AnimationIds = {
	"114685600680382", -- Prepare
	"127264515888392", -- StartJump
	"110870700549831", -- Jumping
	"125924335703879", -- Fall
	"83173520624654", -- Land
}

local animationTracks = {}
local walkSpeed = 0

-- Property
local property = propertyTemplate:new()

-- StateMachine
local playerStateMachine = machineTemplate:new()
local idleState = idleStateTemplate:new(playerStateMachine, PlayerController)
local skillState = skillStateTemplate:new(playerStateMachine)
local jumpState = jumpStateTemplate:new(playerStateMachine, PlayerController)
local jumpingState = jumpingStateTemplate:new(playerStateMachine, PlayerController)
local fallState = fallStateTemplate:new(playerStateMachine, PlayerController)
local trainState = trainStateTemplate:new(playerStateMachine, PlayerController)
local landState = landStateTemplate:new(playerStateMachine, PlayerController)
local walkState = walkStateTemplate:new(playerStateMachine, PlayerController)
playerStateMachine:AddState("Idle", idleState)
playerStateMachine:AddState("Skill", skillState)
playerStateMachine:AddState("Jump", jumpState)
playerStateMachine:AddState("Jumping", jumpingState)
playerStateMachine:AddState("Fall", fallState)
playerStateMachine:AddState("Train", trainState)
playerStateMachine:AddState("Land", landState)
playerStateMachine:AddState("Walk", walkState)

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

	for _, animId in actionAnimationIds do
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://"..animId
		local track = animator:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Action
		if animationTracks[animId] == nil then
			animationTracks[animId] = track
		end
	end

	for _, animId in action2AnimationIds do
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://"..animId
		local track = animator:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Action2
		if animationTracks[animId] == nil then
			animationTracks[animId] = track
		end
	end

	local animateScript = Character:WaitForChild("Animate")
	-- animateScript.run.RunAnim.AnimationId = "rbxassetid://93441484014353"
	-- animateScript.idle.Animation1.AnimationId = "rbxassetid://76376945167646"
	-- animateScript.idle.Animation2.AnimationId = "rbxassetid://76376945167646"
	-- animateScript.walk.WalkAnim.AnimationId = "rbxassetid://93441484014353"
	playerStateMachine:Run("Idle")
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
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
	EventCenter:AddCEventListener(EventCenter.EventType.CForceLand, HandleForceLand)
	EventCenter:AddCEventListener(EventCenter.EventType.CAutoTrain, HandleAutoTrain)
	EventCenter:SendSEvent(SharedEvent.EventType.CReqStrength) 
	EventCenter:SendSEvent(SharedEvent.EventType.CReqHighestHeight)
	EventCenter:SendSEvent(SharedEvent.EventType.CRequestCoin)
	humanoid.Running:Connect(function(speed)
		if property["Jumping"] then
			return
		end
		walkSpeed = speed
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

function PlayerController:PlayAnim(animId, timer)
	playAnim(animId, timer)
end

function playAnim(animId, timer)
	local animations = animator:GetPlayingAnimationTracks()
    for _, anim in animations do
        anim:Stop()
    end
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
	TryChangeSkybox()
	local curSpeedY = self:GetSpeedY()
	if property["Jumping"] then
		EventCenter:SendEvent(EventCenter.EventType.CJumping, curSpeedY, humanoidRootPart.CFrame.Position.Y, property["HighestHeight"])
	end
end

function TryChangeSkybox()
	local playerY = humanoidRootPart.CFrame.Position.Y
	if playerY <= 50001 then
		ModSkybox:Change("Sky01")
	elseif playerY >= 50001 and playerY <= 300000 then
		ModSkybox:Change("Sky02")
	elseif playerY >= 300000 and playerY <= 1000000 then
		ModSkybox:Change("Sky03")
	elseif playerY >= 1000001 and playerY <= 10000000 then
		ModSkybox:Change("Sky04")
	elseif playerY >= 10000001 and playerY <= 50000000 then
		ModSkybox:Change("Sky05")
	elseif playerY >= 500000001 and playerY <= 1000000000 then
		ModSkybox:Change("Sky06")
	elseif playerY >= 1000000001 then
		ModSkybox:Change("Sky07")
	end
end

function HandleTrain()
	if property["Trainable"] and not property["Training"] then
		playerStateMachine:ChangeState("Train")
	end
end

function HandleAttack()
	if property["Jumpable"] and not property["Jumping"] then
		playerStateMachine:ChangeState("Jump")
	end
end

function HandleFire()
	if property["Jumping"] then
		return
	end

	HandleTrain()
	HandleAttack()
end

function HandleResponseStrength(strength)
	local nowStrength = property["Strength"]
	if tonumber(nowStrength) < tonumber(strength) then
		EventCenter:SendEvent(EventCenter.EventType.CGainResources, "strength", strength - nowStrength)
	end
	property["Strength"] = strength
	EventCenter:SendEvent(EventCenter.EventType.CUpdateStrength, strength)
end

function HandleResponseHighestHeight(highestHeight)
	property["HighestHeight"] = highestHeight
	EventCenter:SendEvent(EventCenter.EventType.CUpdateHighestHeight, highestHeight)
end

function HandleResponseCoin(coin)
	local nowCoin = property["Coin"]
	if tonumber(nowCoin) < tonumber(coin) then
		EventCenter:SendEvent(EventCenter.EventType.CGainResources, "coin", coin - nowCoin)
	end
	property["Coin"] = coin
	EventCenter:SendEvent(EventCenter.EventType.CUpdateCoin, coin)
end

function HandleForceLand()
	local curSpeedY = humanoidRootPart.AssemblyLinearVelocity.Y
	if curSpeedY > 0 then
		EventCenter:SendSEvent(SharedEvent.EventType.SUpdateHighestHeight)
	end
	humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.CFrame.X, 1, humanoidRootPart.CFrame.Z)
	
end

function HandleAutoTrain(open)
	property["AutoTrain"] = open
	if open then
		playerStateMachine:ChangeState("Train")
	else
		if walkSpeed > 0 then
			playerStateMachine:ChangeState("Walk")
		else
			playerStateMachine:ChangeState("Idle")
		end
	end
end

function PlayerController:CheckAutoTrain()
	return property["AutoTrain"]
end

function PlayerController:SetWalkSpeed(ws)
	humanoid.WalkSpeed = ws
	if ws == 0 then
		walkSpeed = 0
	end
end

function PlayerController:GetWalkSpeed()
	return walkSpeed
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

function PlayerController:SetTraining(training)
	property["Training"] = training
end

local OriginPosY = 0

function PlayerController:Jumping()
	OriginPosY = humanoidRootPart.CFrame.Position.Y
	EventCenter:SendEvent(EventCenter.EventType.CStartJumping)
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
	local preState = CurState
	if CurState == state then
        CurState = self.StateType.DEFAULT
    else
        CurState = state
    end

	if state == self.StateType.DEFAULT then
		property["Trainable"] = false
		property["Jumpable"] = false
	elseif state == self.StateType.JUMP then
		property["Jumpable"] = true
		property["Trainable"] = false
	else
		property["Trainable"] = true
		property["Jumpable"] = false
	end

	if property["Jumping"] then
		return
	end

	if state == self.StateType.EQUIP then
        if preState == self.StateType.EQUIP then
            EventCenter:SendSEvent(SharedEvent.EventType.CReqHideEquip)
			property["AutoTrain"] = false
        else
            EventCenter:SendSEvent(SharedEvent.EventType.CReqShowEquip)
        end
    end

    if preState == self.StateType.EQUIP and state ~= self.StateType.EQUIP then
		property["AutoTrain"] = false
        EventCenter:SendSEvent(SharedEvent.EventType.CReqHideEquip)
    end

	local animateScript = Character:WaitForChild("Animate")
	if (preState == self.StateType.DEFAULT or preState == self.StateType.JUMP) and state ~= self.StateType.EQUIP then
		return
	end
	if (preState == self.StateType.DEFAULT or preState == self.StateType.JUMP) and state == self.StateType.EQUIP then
		playAnim("111855132298439", 0.1)
		task.wait(0.3)
		stopAnim("111855132298439")
	end
	playerStateMachine:ChangeState("Idle", true)
	-- animateScript.Parent = nil
	-- task.wait()
	-- animateScript.Parent = Character
end

function PlayerController:FixedStateAfterLand()
	if CurState == self.StateType.EQUIP then
        EventCenter:SendSEvent(SharedEvent.EventType.CReqShowEquip)
		playAnim("111855132298439", 0.1)
		task.wait(0.3)
		stopAnim("111855132298439")
		playerStateMachine:ChangeState("Idle", true)
    end
end

function PlayerController:HandleEuiqpmentChanged()
	if CurState == self.StateType.EQUIP then
        EventCenter:SendSEvent(SharedEvent.EventType.CReqShowEquip)
    end
end

function PlayerController:PlayTrainEff()
    local trainEff = humanoidRootPart:FindFirstChild("训练特效")
	if trainEff:IsA("Part") then
    	trainEff.CFrame = CFrame.new(humanoidRootPart.CFrame.X, 0, humanoidRootPart.CFrame.Z)
	end
    local effChildren = trainEff:GetChildren()
    for _, child in pairs(effChildren) do
        child.Enabled = true
    end
    
    task.wait(0.5)
    
    for _, child in pairs(effChildren) do
        child.Enabled = false
    end
end

function PlayerController:PlayEff(effName, time)
	print(effName)
    local trainEff = humanoidRootPart:FindFirstChild(effName)
	if trainEff == nil then
		return
	end
	if trainEff:IsA("Part") then
    	trainEff.CFrame = CFrame.new(humanoidRootPart.CFrame.X, 0, humanoidRootPart.CFrame.Z)
	end
    local effChildren = trainEff:GetChildren()
	EnableChildren(trainEff, true)
    -- for _, child in pairs(effChildren) do
    --     child.Enabled = true
    -- end
    
    task.wait(time)
    EnableChildren(trainEff, false)
    -- for _, child in pairs(effChildren) do
    --     child.Enabled = false
    -- end
end

function PlayerController:PlayEffDisableBySelf(effName)
	print(effName)
    local trainEff = humanoidRootPart:FindFirstChild(effName)
	if trainEff:IsA("Part") then
    	trainEff.CFrame = CFrame.new(humanoidRootPart.CFrame.X, 0, humanoidRootPart.CFrame.Z)
	end
	EnableChildren(trainEff, true)
    -- local effChildren = trainEff:GetChildren()
    -- for _, child in pairs(effChildren) do
    --     child.Enabled = true
    -- end
end

function PlayerController:HideEff(effName)
    local trainEff = humanoidRootPart:FindFirstChild(effName)
	if trainEff:IsA("Part") then
    	trainEff.CFrame = CFrame.new(humanoidRootPart.CFrame.X, 0, humanoidRootPart.CFrame.Z)
	end
	EnableChildren(trainEff, false)
    -- local effChildren = trainEff:GetChildren()
    -- for _, child in pairs(effChildren) do
    --     child.Enabled = false
    -- end
end

function EnableChildren(parent, enable)
    local children = parent:GetChildren()
    local childrenCnt = #parent:GetChildren()
    if childrenCnt <= 0 then
        return
    end
    for _, child in pairs(children) do
        if child:IsA("ParticleEmitter") then
            child.Enabled = enable
        end
        EnableChildren(child, enable)
    end
end

function PlayerController:PlayIdleAnim()
    -- self:StopAllDefaultAnim()
    local idleAnimId = "76376945167646"
    if CurState == self.StateType.EQUIP then
        idleAnimId = "83155635118048"
    end
    
    playAnim(idleAnimId)
end

function PlayerController:PlayWalkAnim()
	print("PlayWalkAnim")
    -- self:StopAllDefaultAnim()
    local walkAnimId = "93441484014353"
    if CurState == self.StateType.EQUIP then
        walkAnimId = "116855912188391"
    end
    playAnim(walkAnimId)
end

function PlayerController:StopAllDefaultAnim()
    local animations = animator:GetPlayingAnimationTracks()
    for _, anim in animations do
        anim:Stop()
    end
end

return PlayerController