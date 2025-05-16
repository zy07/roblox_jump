local ClientEventCenter = {}

ClientEventCenter.EventType = {
    CAttack = 1,
    CTrain = 2,

    SeverEvent = 10000,
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

    --UI
    CUpdateStrength = 50001, -- 更新显示的力量
    CJumping = 50002, -- 开始跳跃
    CLand = 50003, -- 落地
    CUpdateHighestHeight = 50004, -- 更新最高高度
    CUpdateCoin = 50005, -- 更新金币

    -- GM
    CReqForceUpdateStrength = 99001, -- GM 强制更新力量
}

local event = game.ReplicatedStorage:WaitForChild("GameEventSync")

local sEventHandlers = {
}

local cEventHandlers = {
}

local player = game:GetService("Players")
local localPlayer = player.LocalPlayer

event.onClientEvent:Connect(function(eventType, ...)
    local handler = sEventHandlers[eventType]
    if handler then
        handler(...)
    end
end)

function ClientEventCenter:SendSEvent(eventType, ...)
    event:FireServer(eventType, ...)
end

function ClientEventCenter:AddSEventListener(eventType, callback)
    if not sEventHandlers[eventType] then
        sEventHandlers[eventType] = callback
    else
        warn("[NG Client] Repeated add event type "..tostring(eventType))
    end
end

function ClientEventCenter:AddCEventListener(eventType, callback)
    if not cEventHandlers[eventType] then
        cEventHandlers[eventType] = {}
        cEventHandlers[eventType][1] = callback
    else
        for _, item in cEventHandlers[eventType] do
            if item == callback then
                warn("[NG Client] Repeated add event type "..tostring(eventType))
            end
        end
    end
end

function ClientEventCenter:RemoveCEventListener(eventType, callback)
    if not cEventHandlers[eventType] then
        warn("[NG Client] Do not have event type "..tostring(eventType))
    else
        for i = #cEventHandlers[eventType], 1, -1 do
            if cEventHandlers[eventType][i] == callback then
                table.remove(cEventHandlers[eventType], i)
            end
        end
    end
end

function ClientEventCenter:SendEvent(eventType, ...)
    if cEventHandlers[eventType] then
        for _, callback in ipairs(cEventHandlers[eventType]) do
            callback(...)
        end
    else
        warn("[NG Client] Not found event type "..tostring(eventType))
    end
end

return ClientEventCenter