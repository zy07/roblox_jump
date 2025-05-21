local EventHandlersCenter = {}

local EventHandlers = {
    ["PlayerJumped"] = function(player, height)
        print(player.Name.." Jump Height "..height)
    end,
}

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
    CReqEquip = 20006, -- 请求装备
    CReqShowEquip = 20007, -- 请求显示装备
    CReqHideEquip = 20008, -- 请求隐藏装备

    -- Response
    SResStrength = 30001, -- 返回力量
    SResHighestHeight = 30002, -- 返回最高高度
    SResCoin = 30003, -- 返回金币
    SResUnlockEquipment = 30004, -- 解锁装备
    SResEquipmentEquiped = 30005, -- 返回装备已装备
    SResEquipmentLock = 30006, -- 返回目前还是锁定的装备

    -- GM
    CReqForceUpdateStrength = 99001, -- GM 强制更新力量
    CReqForceUpdateCoin = 99002, -- GM 强制更新金币
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