local EquipmentCfgData = require(game.ReplicatedStorage.Shared.Data.EquipmentCfgData)
local EquipmentData = {}

local EventCenter = nil
local DataStoreService = nil

local Equipments = nil

function EquipmentData:new(eventCenter, dataSourceService)
    local obj = {}
	self.__index = self
	setmetatable(obj, self)
    EventCenter = eventCenter
    DataStoreService = dataSourceService
    Equipments = DataStoreService:GetDataStore("PlayerEquipments")

    EventCenter:AddEventListener(EventCenter.EventType.CReqEquipment, HandleResAllEquipments)

	return obj
end

function HandleResAllEquipments(player)
    local success, val = pcall(function()
        Equipments:GetAsync(player.UserId)
    end)
    if success then
        if(val == nil) then
            val = {}
            for _, equipment in pairs(EquipmentCfgData) do
                local newEquipment = {}
                newEquipment.id = equipment.id
                newEquipment.name = equipment.name
                newEquipment.icon = equipment.icon
                newEquipment.addStrength = equipment.addStrength
                local lock = false
                if equipment.initUnlock == nil then
                    lock = true
                else
                    lock = not equipment.initUnlock
                end
                newEquipment.Lock = lock
                newEquipment.Equip = not lock
                table.insert(val, newEquipment)
            end
        end
        EventCenter:FireClient(player, EventCenter.EventType.SResUpdateAllEquipment, val)
    end
end

return EquipmentData