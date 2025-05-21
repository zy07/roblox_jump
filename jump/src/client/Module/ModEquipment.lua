local EquipmentCfgData = require(game.ReplicatedStorage.Shared.Data.EquipmentCfgData)
local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local SharedEvent = require(game.ReplicatedStorage.Shared.EventHandlesCenter)
local ModEquipment = {}

ModEquipment.Equipments = {}

function HandleResEquipmentEquiped(id)
    for _, equipment in pairs(ModEquipment.Equipments) do
        if equipment.id == id then
            equipment.Equip = true
        else
            equipment.Equip = false
        end
    end

    EventCenter:SendEvent(EventCenter.EventType.CUpdateAllEquipment)
    EventCenter:SendEvent(EventCenter.EventType.CEquipmentChanged)
end

function HandleUnlockEquipment(id)
    for _, equipment in ModEquipment.Equipments do
        if equipment.id == id then
            equipment.Lock = false
            EventCenter:SendEvent(EventCenter.EventType.CUpdateEquipment, equipment)
            break
        end
    end
end

function HandleResEquipmentLock(lockIds)
    print(lockIds)
    for _, equipment in pairs(ModEquipment.Equipments) do
        local isLock = false
        for __, lockId in lockIds do
            if equipment.id == lockId then
                isLock = true
            end
        end
        equipment.Lock = isLock
    end
    EventCenter:SendEvent(EventCenter.EventType.CUpdateAllEquipment)
end

for _, equipment in pairs(EquipmentCfgData) do
    local newEquipment = {}
    newEquipment.id = equipment.id
    newEquipment.name = equipment.name
    newEquipment.icon = equipment.icon
    newEquipment.addStrength = equipment.addStrength
    newEquipment.prefab = equipment.prefab
    newEquipment.price = equipment.price
    newEquipment.Lock = false
    newEquipment.Equip = false
    table.insert(ModEquipment.Equipments, newEquipment)
end

EventCenter:SendSEvent(SharedEvent.EventType.CReqEquipment)

function ModEquipment:UnlockEquipment(id)
    for _, equipment in ModEquipment.Equipments do
        if equipment.id == id then
            EventCenter:SendSEvent(SharedEvent.EventType.CReqUnlockEquipment, id)
            break
        end
    end
end

function ModEquipment:EquipEquipment(id)
    local equipment = ModEquipment.Equipments[id]
    if equipment then
        EventCenter:SendSEvent(SharedEvent.EventType.CReqEquip, id)
    end
end

function ModEquipment:GetEquipedEquipment()
    for _, equipment in pairs(ModEquipment.Equipments) do
        if equipment.Equip then
            return equipment
        end
    end
end

function ModEquipment:GetEquipmentById(id)
    for _, equipment in pairs(ModEquipment.Equipments) do
        if equipment.id == id then
            return equipment
        end
    end
end

EventCenter:AddSEventListener(SharedEvent.EventType.SResUnlockEquipment, HandleUnlockEquipment)
EventCenter:AddSEventListener(SharedEvent.EventType.SResEquipmentEquiped, HandleResEquipmentEquiped)
EventCenter:AddSEventListener(SharedEvent.EventType.SResEquipmentLock, HandleResEquipmentLock)

return ModEquipment