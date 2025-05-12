local EventHandlersCenter = {}

local EventHandlers = {
    ["PlayerJumped"] = function(player, height)
        print(player.Name.." Jump Height "..height)
    end,
}

function EventHandlersCenter:HandleEvents(EventSync, eventType, player, ...)
    local handler = EventHandlers[eventType]
    if handler then
        handler(player, ...)
        EventSync.FireAllClients(eventType, player.UserId, ...) 
    else
        warn("[NG] Not find eventType "..tostring(eventType))
    end
end

return EventHandlersCenter