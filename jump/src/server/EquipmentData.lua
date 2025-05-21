local EquipmentCfgData = require(game.ReplicatedStorage.Shared.Data.EquipmentCfgData)
local SharedEvent = require(game.ReplicatedStorage.Shared.EventHandlesCenter)
local ServerStorage = game:GetService("ServerStorage")
local EquipmentData = {}

local EventCenter = nil
local DataStoreService = nil

local Equipments = nil
local EquipId = nil
local EquipedId = nil
local LockedId = nil
local AllEquipments = nil
local LoadedEquipment = nil

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
        newEquipment.prefab = equipment.prefab
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
    
    EventCenter:AddEventListener(SharedEvent.EventType.CReqEquipment, HandleReqEquipment)
    EventCenter:AddEventListener(SharedEvent.EventType.CReqEquip, HandleReqEquip)
    EventCenter:AddEventListener(SharedEvent.EventType.CReqUnlockEquipment, HandleReqUnlockEquipment)
    EventCenter:AddEventListener(SharedEvent.EventType.CReqShowEquip, HandleReqShowEquip)
    EventCenter:AddEventListener(SharedEvent.EventType.CReqHideEquip, HandleReqHideEquip)

	return obj
end

function HandleReqEquipment(player)
    local success, value = pcall(function()
        return EquipedId:GetAsync(player.UserId)
    end)
    if success then
        for _, equipment in AllEquipments do
            if equipment.id == value then
                equipment.Equip = true
            else
                equipment.Equip = false
            end
        end
        EventCenter:FireClient(player, SharedEvent.EventType.SResEquipmentEquiped, value)
    end

    -- local success2, value2 = pcall(function()
    --     LockedId:GetAsync(player.UserId)
    -- end)
    -- if success2 then
    --     if value2 ~= nil then
    --         for _, lockId in value2 do
    --             local curEquip = AllEquipments[lockId]
    --             curEquip.Lock = true
    --             AllEquipments[lockId] = curEquip
    --         end
    --     else
    --         for _, e in AllEquipments do
    --             local lockId = e.id
    --             local lockIds = {}
    --             table.insert(lockIds, lockId)
    --         end
    --         EventCenter:FireClient(player, EventCenter.EventType.SResUpdateAllEquipment, AllEquipments)
    --     end
    -- end
end

function HandleReqEquip(player, id)
    local success, errorMessage = pcall(function()
        EquipedId:SetAsync(player.UserId, id)
    end)
    if success then
        for _, equipment in AllEquipments do
            if equipment.id == id then
                equipment.Equip = true
            else
                equipment.Equip = false
            end
        end
        EventCenter:FireClient(player, SharedEvent.EventType.SResEquipmentEquiped, id)
    end
end

function HandleReqUnlockEquipment(player, id)
    for _, equipment in AllEquipments do
        if equipment.id == id and equipment.Lock then
            equipment.Lock = false
            EventCenter.FireClient(player, SharedEvent.EventType.SResUpdateEquipment, equipment)
        end
    end

    local success, errorMessage = pcall(function()
        Equipments:SetAsync(player.UserId, AllEquipments)
    end)
    
end

function HandleReqShowEquip(player)
    for _, equipment in AllEquipments do
        if equipment.Equip then
            local equipModel = ServerStorage:FindFirstChild("锻炼器材"):FindFirstChild(equipment.prefab)
            if equipModel then
                if LoadedEquipment ~= nil then
                    LoadedEquipment:Destroy()
                    LoadedEquipment = nil
                end
                LoadedEquipment = equipModel:Clone()
                LoadedEquipment.Parent = player.Character
            end
            break
        end
    end
end

function HandleReqHideEquip()
    if LoadedEquipment ~= nil then
        LoadedEquipment:Destroy()
        LoadedEquipment = nil
    end
end

return EquipmentData