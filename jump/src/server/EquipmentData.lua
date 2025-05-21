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
        newEquipment.price = equipment.price
        local lock = true
        if equipment.initUnlock == nil then
            lock = true
        else
            lock = not equipment.initUnlock
        end
        newEquipment.Lock = lock
        newEquipment.Equip = not lock   
        table.insert(AllEquipments, newEquipment)
    end
    
    EventCenter:AddEventListener(SharedEvent.EventType.CReqEquipment, HandleReqEquipment)
    EventCenter:AddEventListener(SharedEvent.EventType.CReqEquip, HandleReqEquip)
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

    -- LockedId:RemoveAsync(player.UserId)

    local success2, value2 = pcall(function()
        return LockedId:GetAsync(player.UserId)
    end)
    if success2 then
        if value2 ~= nil then
            for _, lockId in value2 do
                for index, equipment in AllEquipments do
                    if lockId == equipment.id then
                        equipment.Lock = true
                    end
                end
            end

            EventCenter:FireClient(player, SharedEvent.EventType.SResEquipmentLock, value2)
        else
            local lockIds = {}
            for _, e in AllEquipments do
                local lockId = e.id
                if e.Lock then
                    table.insert(lockIds, lockId)
                end
            end
            local success3, errMsg3 = pcall(function()
                    LockedId:SetAsync(player.UserId, lockIds)
            end)
            if success3 then
                EventCenter:FireClient(player, SharedEvent.EventType.SResEquipmentLock, lockIds)
            end
        end
    end
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

function EquipmentData:GetEquipedEquipment()
    for _, equipment in AllEquipments do
        if equipment.Equip then
            return equipment
        end
    end
end

function EquipmentData:GetEquipmentById(id)
    for _, equipment in AllEquipments do
        if equipment.id == id then
            return equipment
        end
    end
end

function EquipmentData:UnlockEquipment(player, id)
    local equipment = self:GetEquipmentById(id)
    equipment.Lock = false
    EventCenter:FireClient(player, SharedEvent.EventType.SResUnlockEquipment, id)

    local succ1, lockIds = pcall(function()
        return LockedId:GetAsync(player.UserId)
    end)
    if succ1 then
        for _, lockId in lockIds do
            if lockId == id then
                table.remove(lockIds, _)
                break;
            end
        end
        local success, errorMessage = pcall(function()
            LockedId:SetAsync(player.UserId, lockIds)
        end)
    end

end

return EquipmentData