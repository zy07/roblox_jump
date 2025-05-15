local EventHandlersCenter = {}

local EventSync = nil
local PlayerData = nil
function EventHandlersCenter:Init(eventSync, playerData)
    EventSync = eventSync
    PlayerData = playerData
end

local players = game:GetService("Players")

EventHandlersCenter.EventType = {
    None = 10000,
    SAttack = 10001,

    -- Data
    SUpdateStrength = 11001,
    SUpdateHighestHeight = 11002, -- 更新最高高度数据

    -- Request
    SRequestStrength = 20001, -- 请求力量
    SRequestHighestHeight = 20002, -- 请求最高高度

    -- Response
    SResponseStrength = 30001, -- 返回力量
    SResponseHighestHeight = 30002, -- 返回最高高度

    -- GM
    SForceUpdateStrength = 99001, -- GM 强制更新力量
}

local EventHandlers = {
    [EventHandlersCenter.EventType.SAttack] = function(player)
        print(player.Name.." 123")
        broadcastToNearbyPlayersWithoutSource(player, EventHandlersCenter.EventType.SAttack)
    end,
    [EventHandlersCenter.EventType.SUpdateStrength] = function(player)
        PlayerData:UpdateStrength(player.UserId)
        FirePlayerStrength(player)
    end,
    [EventHandlersCenter.EventType.SRequestStrength] = function(player)
        FirePlayerStrength(player)
    end,
    [EventHandlersCenter.EventType.SForceUpdateStrength] = function(player, strength)
        PlayerData:ForceUpdateStrength(player.UserId, strength)
        FirePlayerStrength(player)
    end,
    [EventHandlersCenter.EventType.SUpdateHighestHeight] = function(player)
        PlayerData:UpdateHighestHeight(player.UserId, player.Character.HumanoidRootPart.Position.Y)
        FirePlayerHighestHeight(player)
    end,
    [EventHandlersCenter.EventType.SRequestHighestHeight] = function(player)
        FirePlayerHighestHeight(player)
    end
}

function FirePlayerStrength(player)
    local strength = PlayerData:GetStrength(player.UserId)
    EventSync:FireClient(player, EventHandlersCenter.EventType.SResponseStrength, strength)
end

function FirePlayerHighestHeight(player)
    local val = PlayerData:GetHighestHeight(player.UserId)
    EventSync:FireClient(player, EventHandlersCenter.EventType.SResponseHighestHeight, val)
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

