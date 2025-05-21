local UIManager = require(game.StarterGui.UIScript.UIManager)
local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local SharedEvent = require(game.ReplicatedStorage.Shared.EventHandlesCenter)
local ModEquipment = require(game.StarterPlayer.StarterPlayerScripts.Module.ModEquipment)
local ui = UIManager:Get("器材背包ui")
local curSelectEquipment = nil
local curSelectEquipmentId = nil

ui["黑色背景"]["关闭"].Activated:Connect(function(inputObject: InputObject, clickCount: number)
    ui.Visible = false
end)

local itemTemplate = ui["黑色背景"]["背包"]["背包"]["模板"]
local chosenEquipmentIcon = ui["黑色背景"]["已选中的道具"]["物品图片"]
local equipBtn = ui["黑色背景"]["装备"]
local equipingBtn = ui["黑色背景"]["装备中"]
local unlockBtn = ui["黑色背景"]["购买"]

itemTemplate.Visible = false

-- 初始化所有装备
local equipments = ModEquipment.Equipments
local equipmentUITemplates = {}

function InitEquipmentItem(newTemplate, equipment, _)
    if equipment.icon ~= nil then
        newTemplate["物品图片"].Image = equipment.icon
    end
    if equipment.price ~= nil then
        newTemplate["价钱"]["数量"].Text = equipment.price
    else
        newTemplate["价钱"]["数量"].Text = "缺少配置"
    end
    newTemplate["价钱"].Visible = equipment.Lock
    newTemplate["当前装备"].Visible = equipment.Equip
    newTemplate["未购买"].Visible = not equipment.Lock
    newTemplate["选择"].Visible = _ == 1
    newTemplate.Name = equipment.id
    if _ == 1 then
        curSelectEquipment = newTemplate
        -- 初始化右侧装备
        if equipment.icon ~= nil then
            chosenEquipmentIcon.Image = equipment.icon
        end
        equipBtn.Visible = not equipment.Equip and not equipment.Lock
        equipingBtn.Visible = equipment.Equip
        unlockBtn.Visible = equipment.Lock
    end
    newTemplate.Activated:Connect(function(inputObject: InputObject, clickCount: number)
        newTemplate["选择"].Visible = true
        curSelectEquipment["选择"].Visible = false
        curSelectEquipment = newTemplate
        curSelectEquipmentId = equipment.id
        -- 点击进行切换
        if equipment.icon ~= nil then
            chosenEquipmentIcon.Image = equipment.icon
        end
        equipBtn.Visible = not equipment.Equip and not equipment.Lock
        equipingBtn.Visible = equipment.Equip
        unlockBtn.Visible = equipment.Lock
    end)
end

function UpdateEquipmentItem(newTemplate, equipment, _)
    if equipment.icon ~= nil then
        newTemplate["物品图片"].Image = equipment.icon
    end
    if equipment.price ~= nil then
        newTemplate["价钱"]["数量"].Text = equipment.price
    else
        newTemplate["价钱"]["数量"].Text = "缺少配置"
    end
    newTemplate["价钱"].Visible = equipment.Lock
    newTemplate["当前装备"].Visible = equipment.Equip
    newTemplate["未购买"].Visible = not equipment.Lock
    newTemplate["选择"].Visible = _ == 1
    newTemplate.Name = equipment.id
    equipBtn.Visible = not equipment.Equip and not equipment.Lock
    equipingBtn.Visible = equipment.Equip
    unlockBtn.Visible = equipment.Lock
end

for _, equipment in pairs(equipments) do
    
    local newTemplate = itemTemplate:Clone()
    newTemplate.Parent = itemTemplate.Parent
    newTemplate.Visible = true
    InitEquipmentItem(newTemplate, equipment, _)
    table.insert(equipmentUITemplates, newTemplate)
end

function HandleUpdateEquipment(newEquipment)
    for _, equipment in equipments do
        if equipment.id == newEquipment.id then
            UpdateEquipmentItem(equipmentUITemplates[_], newEquipment, _)
        end
    end
end

function HandleUpdateAllEquipment()
    for _, equipment in pairs(equipments) do
        local template = equipmentUITemplates[_]
        UpdateEquipmentItem(template, equipment, _)
    end
end

EventCenter:AddCEventListener(EventCenter.EventType.CUpdateEquipment, HandleUpdateEquipment)
EventCenter:AddCEventListener(EventCenter.EventType.CUpdateAllEquipment, HandleUpdateAllEquipment)

equipBtn.Activated:Connect(function(inputObject: InputObject, clickCount: number)
    if curSelectEquipment["当前装备"].Visible == false then
        curSelectEquipment["当前装备"].Visible = true
        equipBtn.Visible = false
        equipingBtn.Visible = true
        EventCenter:SendSEvent(SharedEvent.EventType.CReqEquip, curSelectEquipmentId)
    end
end)

unlockBtn.Activated:Connect(function(inputObject: InputObject, clickCount: number)
    ModEquipment:UnlockEquipment(curSelectEquipmentId)
end)