local SharedEvent = require(game.ReplicatedStorage.Shared.EventHandlesCenter)
local PlayerData = {}

local EventCenter = nil
local DataStoreService = nil
local strength = nil
local highestHeight = nil
local coin = nil
local EquipmentData = nil

function PlayerData:new(eventCenter, equipmentData, dataStoreService)
    local obj = {}
	self.__index = self
	setmetatable(obj, self)
    EventCenter = eventCenter
    DataStoreService = dataStoreService
    EquipmentData = equipmentData
    strength = DataStoreService:GetDataStore("PlayerStrength")
    highestHeight = DataStoreService:GetDataStore("PlayerHighestHeight")
    coin = DataStoreService:GetDataStore("PlayerCoin")

    EventCenter:AddEventListener(SharedEvent.EventType.SUpdateStrength, HandleUpdateStrength)
    EventCenter:AddEventListener(SharedEvent.EventType.CReqStrength, FirePlayerStrength)
    EventCenter:AddEventListener(SharedEvent.EventType.CReqForceUpdateStrength, ForceUpdateStrength)
    EventCenter:AddEventListener(SharedEvent.EventType.CReqForceUpdateCoin, ForceUpdateCoin)
    EventCenter:AddEventListener(SharedEvent.EventType.SUpdateHighestHeight, UpdateHighestHeight)
    EventCenter:AddEventListener(SharedEvent.EventType.CReqHighestHeight, FirePlayerHighestHeight)
    EventCenter:AddEventListener(SharedEvent.EventType.CRequestCoin, FirePlayerCoin)
    EventCenter:AddEventListener(SharedEvent.EventType.CReqUnlockEquipment, HandleReqUnlockEquipment)

	return obj
end

function HandleReqUnlockEquipment(player, id)
    local equipment = EquipmentData:GetEquipmentById(id)
    if equipment.id == id and equipment.Lock and CoinEnough(player, equipment.price) then
        EquipmentData:UnlockEquipment(player, id)
        CoinCost(player, equipment.price)
    end
end

function GetStrength(playerId)
    local success, strengthVal = pcall(function()
        return strength:GetAsync(playerId)
    end)
    if success then
        if strengthVal == nil then
            return 0
        end
        return strengthVal
    end
end

function UpdateStrength(playerId)
    local strengthVal = GetStrength(playerId)
    local success, errorMessage = pcall(function()
        -- TODO: 后面这里要计算应该增加多少力量值
        local equipment = EquipmentData:GetEquipedEquipment()
        local addVal = 1
        if equipment ~= nil then
            addVal += equipment.addStrength
        end
        strength:SetAsync(playerId, strengthVal + addVal)
    end)
    if not success then
        print(errorMessage)
    end
end

function GetHighestHeight(playerId)
    local success, val = pcall(function()
        return highestHeight:GetAsync(playerId)
    end)
    if success then
        if val == nil then
            return 0
        end
        return val
    end
end

function UpdateHighestHeight(player)
    local playerId = player.UserId
    local height = player.Character.HumanoidRootPart.CFrame.Position.Y
    AddCoin(playerId, height)
    local success, errorMessage = pcall(function()
        local oldHeight = highestHeight:GetAsync(playerId)
        if oldHeight == nil or height > oldHeight then
            highestHeight:SetAsync(playerId, height)
        end
    end)
    if not success then
        print(errorMessage)
    end

    FirePlayerHighestHeight(player)
    FirePlayerCoin(player)
end

function GetCoin(playerId)
    local success, val = pcall(function()
        return coin:GetAsync(playerId)
    end)
    if success then
        if val == nil then
            return 0
        end
        return val
    end
end

-- 结算金币
function AddCoin(playerId, height)
    local curCoin = GetCoin(playerId)
    local success, errorMessage = pcall(function()
        coin:SetAsync(playerId, curCoin + math.ceil(height))
    end)
    if not success then
        print(errorMessage)
    end
end

function ForceUpdateStrength(player, strengthVal)
    local success, errorMessage = pcall(function()
        strength:SetAsync(player.UserId, strengthVal)
    end)
    if not success then
        print(errorMessage)
    end
    FirePlayerStrength(player)
end

function ForceUpdateCoin(player, coinVal)
    local success, errorMessage = pcall(function()
        coin:SetAsync(player.UserId, coinVal)
    end)
    if not success then
        print(errorMessage)
    end
    FirePlayerCoin(player)
end

function HandleUpdateStrength(player)
    UpdateStrength(player.UserId)
    FirePlayerStrength(player)
end


function FirePlayerStrength(player)
    local strength = GetStrength(player.UserId)
    EventCenter:FireClient(player, SharedEvent.EventType.SResStrength, strength)
end

function FirePlayerHighestHeight(player)
    local val = GetHighestHeight(player.UserId)
    EventCenter:FireClient(player, SharedEvent.EventType.SResHighestHeight, val)
end

function FirePlayerCoin(player)
    local val = GetCoin(player.UserId)
    EventCenter:FireClient(player, SharedEvent.EventType.SResCoin, val)
end

function CoinEnough(player, cost)
    local val = GetCoin(player.UserId)
    if val ~= nil and cost ~= nil then
        local valNum = tonumber(val)
        local costNum = tonumber(cost)
        return costNum <= valNum
    end
    return false
end

function CoinCost(player, cost)
    local val = GetCoin(player.UserId)
    if val ~= nil and cost ~= nil then
        local valNum = tonumber(val)
        local costNum = tonumber(cost)
        local success, errorMessage = pcall(function()
            coin:SetAsync(player.UserId, valNum - costNum)
        end)
        if not success then
            print(errorMessage)
        else
            FirePlayerCoin(player)
        end
    end
end

return PlayerData