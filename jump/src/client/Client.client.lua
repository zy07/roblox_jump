local ModPlayers = require(game.StarterPlayer.StarterPlayerScripts.Player.ModPlayers)
local ClientEventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local InputMgr = require(game.StarterPlayer.StarterPlayerScripts.Input.InputManager)
-- Require Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventSync = ReplicatedStorage:WaitForChild("GameEventSync")

local function Update()
	ModPlayers:Update()
	-- 123123123
end

RunService.Heartbeat:Connect(Update)