local ModPlayers = require(game.StarterPlayer.StarterPlayerScripts.Player.ModPlayers)
local ModEquipment = require(game.StarterPlayer.StarterPlayerScripts.Module.ModEquipment)
local ClientEventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local InputMgr = require(game.StarterPlayer.StarterPlayerScripts.Input.InputManager)
local ModSkybox = require(game.StarterPlayer.StarterPlayerScripts.Module.ModSkybox)
local ModTimer = require(game.StarterPlayer.StarterPlayerScripts.Module.ModTimer)
-- Require Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventSync = ReplicatedStorage:WaitForChild("GameEventSync")
local function Update(deltaTime)
	ModPlayers:Update()
	-- 123123123
	ModTimer:Update(deltaTime)
end

RunService.Heartbeat:Connect(Update)