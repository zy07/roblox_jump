local SharedEvent = require(game.ReplicatedStorage.Shared.EventHandlesCenter)
local EventHandlersCenter = {}

local EventSync = nil
function EventHandlersCenter:Init(eventSync)
    EventSync = eventSync
end

local players = game:GetService("Players")

local EventHandlers = {
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

