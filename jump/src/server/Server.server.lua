local RunService = game:GetService("RunService")
local eventHandlerCenter = require(game.ServerScriptService.Server.EventHandlersCenter)
local playerDataTemplate = require(game.ServerScriptService.Server.PlayerData)
local equipmentDataTemplate = require(game.ServerScriptService.Server.EquipmentData)
local DataStoreManager = require(game.ServerScriptService.Server.DataStoreManager)
print("Server init, from server!")

local replicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")


-- 创建远程事件
local EventSync = Instance.new("RemoteEvent")
EventSync.Name = "GameEventSync"
EventSync.Parent = game.ReplicatedStorage
eventHandlerCenter:Init(EventSync)
DataStoreManager:new(DataStoreService)
local EquipmentData = equipmentDataTemplate:new(eventHandlerCenter, DataStoreService)
local PlayerData = playerDataTemplate:new(eventHandlerCenter, EquipmentData, DataStoreService)
-- 监听客户端事件
EventSync.OnServerEvent:Connect(function(player, eventType, ...)
    eventHandlerCenter:HandleEvents(player, eventType, ...)
end)

RunService.Heartbeat:Connect(function(deltaTime)
    -- 每帧执行，deltaTime
    PlayerData:Update(deltaTime)
end)

game:BindToClose(function()
    print("服务器即将关闭！保存数据中.....")
    PlayerData:SaveData()
end)

-- 附近玩家广播函数
-- function broadcastToNearbyPlayers(sourcePlayer, eventType, ...)
--     local sourcePos = sourcePlayer.Character.HumanoidRootPart.Position
--     for _, player in ipairs(Players:GetPlayers()) do
--         if player ~= sourcePlayer and player.Character then
--             local distance = (player.Character.HumanoidRootPart.Position - sourcePos).Magnitude
--             if distance < 50 then -- 50米范围内
--                 EventSync:FireClient(player, eventType, ...)
--             end
--         end
--     end
-- end