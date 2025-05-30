local ClientEventCenter = {}

ClientEventCenter.EventType = {
    CFire = 1,

    --UI
    CUpdateStrength = 50001, -- 更新显示的力量
    CJumping = 50002, -- 开始跳跃
    CLand = 50003, -- 落地
    CUpdateHighestHeight = 50004, -- 更新最高高度
    CUpdateCoin = 50005, -- 更新金币
    CUpdateEquipment = 50006, -- 更新装备
    CUpdateAllEquipment = 50007, -- 更新所有装备
    CPlayerChangeState = 50008, -- 玩家改变状态
    CPlayerChangeEquipAnim = 50009, -- 玩家改变动画
    CKeyboard = 50010, -- 玩家按下键盘
    CEquipmentChanged = 50011, -- 更换装备
    CStartJumping = 50012, -- 玩家开始跳跃
    CForceLand = 50013, -- 直接落地
    CGainResources = 50014, -- 获得资源
    CAutoTrain = 50015, -- 自动锻炼
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