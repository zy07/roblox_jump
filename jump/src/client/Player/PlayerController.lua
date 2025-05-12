local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local EffectManager = require(game.StarterPlayer.StarterPlayerScripts.Effect.EffectManager)
local Search = require(game.StarterPlayer.StarterPlayerScripts.Battle.Search.Search)
local machineTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.State.Player.PlayerStateMachine)
local idleStateTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.State.Player.PlayerIdleState)
local skillStateTemplate = require(game.StarterPlayer.StarterPlayerScripts.Battle.State.Player.PlayerSkillState)

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
}
local animationTracks = {}

-- StateMachine
local playerStateMachine = machineTemplate:new()
local idleState = idleStateTemplate:new(playerStateMachine)
local skillState = skillStateTemplate:new(playerStateMachine)
playerStateMachine:AddState("Idle", idleState)
playerStateMachine:AddState("Skill", skillState)

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
	playerStateMachine:Run("Idle")
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

return PlayerController