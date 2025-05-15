local PlayerData = {}

local DataStoreService = nil
local strength = nil
local highestHeight = nil

function PlayerData:new(dataStoreService)
    local obj = {}
	self.__index = self
	setmetatable(obj, self)
    DataStoreService = dataStoreService
    strength = DataStoreService:GetDataStore("PlayerStrength")
    highestHeight = DataStoreService:GetDataStore("PlayerHighestHeight")
	return obj
end

function PlayerData:GetStrength(playerId)
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

function PlayerData:UpdateStrength(playerId)
    local strengthVal = self:GetStrength(playerId)
    local success, errorMessage = pcall(function()
        -- TODO: 后面这里要计算应该增加多少力量值
        local addVal = 1
        strength:SetAsync(playerId, strengthVal + addVal)
    end)
    if not success then
        print(errorMessage)
    end
end

function PlayerData:GetHighestHeight(playerId)
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

function PlayerData:UpdateHighestHeight(playerId, height)
    local res = height
    local success, errorMessage = pcall(function()
        local oldHeight = highestHeight:GetAsync(playerId)
        if oldHeight == nil or height > oldHeight then
            strength:SetAsync(playerId, height)
        else
            res = oldHeight
        end
    end)
    if not success then
        print(errorMessage)
    end

    return res
    
end

function PlayerData:ForceUpdateStrength(playerId, strengthVal)
    local success, errorMessage = pcall(function()
        strength:SetAsync(playerId, strengthVal)
    end)
    if not success then
        print(errorMessage)
    end
    
end

return PlayerData