local EquipmentCfgData = require(game.ReplicatedStorage.Shared.Data.EquipmentCfgData)
local EquipmentData = {}

local EventCenter = nil
local DataStoreService = nil

local Equipments = nil
local EquipId = nil
local EquipedId = nil
local LockedId = nil
local AllEquipments = nil

function EquipmentData:new(eventCenter, dataSourceService)
    local obj = {}
	self.__index = self
	setmetatable(obj, self)
    EventCenter = eventCenter
    DataStoreService = dataSourceService
    Equipments = DataStoreService:GetDataStore("PlayerEquipments")
    EquipedId = DataStoreService:GetDataStore("PlayerEquipedId")
    LockedId = DataStoreService:GetDataStore("PlayerLockedId")

    AllEquipments = {}
    for _, equipment in pairs(EquipmentCfgData) do
        local newEquipment = {}
        newEquipment.id = equipment.id
        newEquipment.name = equipment.name
        newEquipment.icon = equipment.icon
        newEquipment.addStrength = equipment.addStrength
        local lock = false
        if equipment.initUnlock == nil then
            lock = false
        else
            lock = not equipment.initUnlock
        end
        newEquipment.Lock = lock
        newEquipment.Equip = not lock
        table.insert(AllEquipments, newEquipment)
    end
    
    EventCenter:AddEventListener(EventCenter.EventType.CReqEquipment, HandleResAllEquipments)
    EventCenter:AddEventListener(EventCenter.EventType.CReqEquip, HandleReqEquip)
    EventCenter:AddEventListener(EventCenter.EventType.CReqUnlockEquipment, HandleReqUnlockEquipment)

	return obj
end

function HandleResAllEquipments(player)
    local success, value = pcall(function()
        EquipedId:GetAsync(player.UserId)
    end)
    if success then
        if value ~= nil then
            for _, equipment in AllEquipments do
                if value == equipment.id then
                    equipment.Equip = true
                else
                    equipment.Equip = false
                end
            end
        end
        EventCenter:FireClient(player, EventCenter.EventType.SResUpdateAllEquipment, AllEquipments)
    end

    local success2, value2 = pcall(function()
        LockedId:GetAsync(player.UserId)
    end)
    if success2 then
        if value2 ~= nil then
            for _, lockId in value2 do
                local curEquip = AllEquipments[lockId]
                curEquip.Lock = true
                AllEquipments[lockId] = curEquip
            end
        else
            for _, e in AllEquipments do
                local lockId = e.id
                local lockIds = {}
                table.insert(lockIds, lockId)
            end
            EventCenter:FireClient(player, EventCenter.EventType.SResUpdateAllEquipment, AllEquipments)
        end
    end
end

function HandleReqEquip(player, id)
    for _, equipment in AllEquipments do
        if equipment.Equip and equipment.id ~= id then
            equipment.Equip = false
            EventCenter:FireClient(player, EventCenter.EventType.SResUpdateEquipment, equipment)
        end

        if equipment.id == id and not equipment.Equip then
            equipment.Equip = true
            EventCenter:FireClient(player, EventCenter.EventType.SResUpdateEquipment, equipment)
        end
    end

    local success, errorMessage = pcall(function()
        EquipedId:SetAsync(player.UserId, id)
    end)
end

function HandleReqUnlockEquipment(player, id)
    for _, equipment in AllEquipments do
        if equipment.id == id and equipment.Lock then
            equipment.Lock = false
            EventCenter.FireClient(player, EventCenter.EventType.SResUpdateEquipment, equipment)
        end
    end

    local success, errorMessage = pcall(function()
        Equipments:SetAsync(player.UserId, AllEquipments)
    end)
    
end

return EquipmentData