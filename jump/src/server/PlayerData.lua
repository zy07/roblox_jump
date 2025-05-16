local PlayerData = {}

local EventCenter = nil
local DataStoreService = nil
local strength = nil
local highestHeight = nil
local coin = nil

function PlayerData:new(eventCenter, dataStoreService)
    local obj = {}
	self.__index = self
	setmetatable(obj, self)
    EventCenter = eventCenter
    DataStoreService = dataStoreService
    strength = DataStoreService:GetDataStore("PlayerStrength")
    highestHeight = DataStoreService:GetDataStore("PlayerHighestHeight")
    coin = DataStoreService:GetDataStore("PlayerCoin")

    EventCenter:AddEventListener(EventCenter.EventType.SUpdateStrength, HandleUpdateStrength)
    EventCenter:AddEventListener(EventCenter.EventType.CReqStrength, FirePlayerStrength)
    EventCenter:AddEventListener(EventCenter.EventType.CReqForceUpdateStrength, ForceUpdateStrength)
    EventCenter:AddEventListener(EventCenter.EventType.SUpdateHighestHeight, UpdateHighestHeight)
    EventCenter:AddEventListener(EventCenter.EventType.CReqHighestHeight, FirePlayerHighestHeight)
    EventCenter:AddEventListener(EventCenter.EventType.CRequestCoin, FirePlayerCoin)

	return obj
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
        local addVal = 1
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

function HandleUpdateStrength(player)
    UpdateStrength(player.UserId)
    FirePlayerStrength(player)
end


function FirePlayerStrength(player)
    local strength = GetStrength(player.UserId)
    EventCenter:FireClient(player, EventCenter.EventType.SResStrength, strength)
end

function FirePlayerHighestHeight(player)
    local val = GetHighestHeight(player.UserId)
    EventCenter:FireClient(player, EventCenter.EventType.SResHighestHeight, val)
end

function FirePlayerCoin(player)
    local val = GetCoin(player.UserId)
    EventCenter:FireClient(player, EventCenter.EventType.SResCoin, val)
end

return PlayerData