local EquipmentCfgData = require(game.ReplicatedStorage.Shared.Data.EquipmentCfgData)
local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local ModEquipment = {}

ModEquipment.Equipments = {}

function HandleUpdateAllEquipment(equipments)
    for _, equipment in pairs(equipments) do
        if ModEquipment.Equipments[equipment.id] then
            ModEquipment.Equipments[equipment.id] = equipment
        end
    end
end

function HandleUpdateEquipment(newEquipment)
    local id = newEquipment.id
    local equipment = ModEquipment.Equipments[id]
    if equipment then
        ModEquipment.Equipments[id] = newEquipment
        EventCenter:SendEvent(EventCenter.EventType.CUpdateEquipment, newEquipment)
    end
end

EventCenter:AddSEventListener(EventCenter.EventType.SResUpdateEquipment, HandleUpdateEquipment)
EventCenter:AddSEventListener(EventCenter.EventType.SResUpdateAllEquipment, HandleUpdateAllEquipment)

for _, equipment in pairs(EquipmentCfgData) do
    local newEquipment = {}
    newEquipment.id = equipment.id
    newEquipment.name = equipment.name
    newEquipment.icon = equipment.icon
    newEquipment.addStrength = equipment.addStrength
    if equipment.initUnlock == nil then
        newEquipment.Lock = true
    else
        newEquipment.Lock = not equipment.initUnlock
    end
    newEquipment.Equip = false
    table.insert(ModEquipment.Equipments, newEquipment)
end

EventCenter:SendSEvent(EventCenter.EventType.CReqEquipment)

function ModEquipment:UnlockEquipment(id)
    local equipment = ModEquipment.Equipments[id]
    if equipment then
        EventCenter:SendSEvent(EventCenter.EventType.CReqUnlockEquipment, id)
    end
end

function ModEquipment:EquipEquipment(id)
    local equipment = ModEquipment.Equipments[id]
    if equipment then
        EventCenter:SendSEvent(EventCenter.EventType.CReqEquip, id)
    end
end

return ModEquipment