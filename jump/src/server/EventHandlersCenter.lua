local EventHandlersCenter = {}

local EventSync = nil
function EventHandlersCenter:Init(eventSync)
    EventSync = eventSync
end

local players = game:GetService("Players")

EventHandlersCenter.EventType = {
    None = 10000,
    SAttack = 10001,
}

local EventHandlers = {
    [EventHandlersCenter.EventType.SAttack] = function(player)
        print(player.Name.." 123")
        broadcastToNearbyPlayersWithoutSource(player, EventHandlersCenter.EventType.SAttack)
    end,
}

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

