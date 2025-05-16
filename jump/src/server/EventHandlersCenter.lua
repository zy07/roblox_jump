local EventHandlersCenter = {}

local EventSync = nil
function EventHandlersCenter:Init(eventSync)
    EventSync = eventSync
end

local players = game:GetService("Players")

EventHandlersCenter.EventType = {
    None = 10000,
    SAttack = 10001,

    -- Data
    SUpdateStrength = 11001,
    SUpdateHighestHeight = 11002, -- 更新最高高度数据

    -- Request
    CReqStrength = 20001, -- 请求力量
    CReqHighestHeight = 20002, -- 请求最高高度
    CRequestCoin = 20003, -- 请求金币
    CReqUnlockEquipment = 20004, -- 请求装备解锁
    CReqEquipment = 20005, -- 请求所有装备信息

    -- Response
    SResStrength = 30001, -- 返回力量
    SResHighestHeight = 30002, -- 返回最高高度
    SResCoin = 30003, -- 返回金币
    SResUpdateEquipment = 30004, -- 更新装备
    SResUpdateAllEquipment = 30005, -- 更新所有装备信息

    -- GM
    CReqForceUpdateStrength = 99001, -- GM 强制更新力量
}

local EventHandlers = {
    [EventHandlersCenter.EventType.SAttack] = function(player)
        print(player.Name.." 123")
        broadcastToNearbyPlayersWithoutSource(player, EventHandlersCenter.EventType.SAttack)
    end,
}

function EventHandlersCenter:AddEventListener(eventType, callback)
    if not EventHandlers[eventType] then
        EventHandlers[eventType] = callback
    else
        warn("[NG] Repeated add event type "..tostring(eventType))
    end
end

function EventHandlersCenter:FireClient(player, eventType, ...)
    EventSync:FireClient(player, eventType, ...)
end

function EventHandlersCenter:HandleEvents(player, eventType, ...)
    local handler = EventHandlers[eventType]
    if handler then
        handler(player, ...)
        EventSync:FireAllClients(eventType, player.UserId, ...) 
    else
        warn("[NG] Not found eventType "..tostring(eventType))
    end
end

function broadcastToNearbyPlayersWithoutSource(sourcePlayer, eventType, ...)
    local sourcePos = sourcePlayer.Character.HumanoidRootPart.Position
    for _, player in ipairs(players:GetPlayers()) do
        if player == sourcePlayer then
            continue
        end
        if player ~= sourcePlayer and player.Character then
            local distance = (player.Character.HumanoidRootPart.Position - sourcePos).Magnitude
            if distance < 50 then
                EventSync:FireClient(player, eventType, ...)
            end
        end
    end
end

return EventHandlersCenter

