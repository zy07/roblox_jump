local eventHandlerCenter = require(game.ServerScriptService.Server.EventHandlersCenter)
print("Server init, from server!")

local replicatedStorage = game:GetService("ReplicatedStorage")

-- 创建远程事件
local EventSync = Instance.new("RemoteEvent")
EventSync.Name = "GameEventSync"
EventSync.Parent = game.ReplicatedStorage
eventHandlerCenter:Init(EventSync)
-- 监听客户端事件
EventSync.OnServerEvent:Connect(function(player, eventType, ...)
    eventHandlerCenter:HandleEvents(player, eventType, ...)
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