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
end

function HandleUpdateEquipment(newEquipment)
    local id = newEquipment.id
    local equipment = ModEquipment.Equipments[id]
    if equipment then
        ModEquipment.Equipments[id] = newEquipment
        EventCenter:SendEvent(EventCenter.EventType.CUpdateEquipment, newEquipment)
    end
end

for _, equipment in pairs(EquipmentCfgData) do
    local newEquipment = {}
    newEquipment.id = equipment.id
    newEquipment.name = equipment.name
    newEquipment.icon = equipment.icon
    newEquipment.addStrength = equipment.addStrength
    newEquipment.prefab = equipment.prefab
    if equipment.initUnlock == nil then
        newEquipment.Lock = true
    else
        newEquipment.Lock = not equipment.initUnlock
    end
    newEquipment.Equip = false
    table.insert(ModEquipment.Equipments, newEquipment)
end

EventCenter:SendSEvent(SharedEvent.EventType.CReqEquipment)

function ModEquipment:UnlockEquipment(id)
    local equipment = ModEquipment.Equipments[id]
    if equipment then
        EventCenter:SendSEvent(SharedEvent.EventType.CReqUnlockEquipment, id)
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

EventCenter:AddSEventListener(SharedEvent.EventType.SResUpdateEquipment, HandleUpdateEquipment)
EventCenter:AddSEventListener(SharedEvent.EventType.SResEquipmentEquiped, HandleResEquipmentEquiped)

return ModEquipment