local SharedEvent = require(game.ReplicatedStorage.Shared.EventHandlesCenter)
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local PlayerData = {}

local EventCenter = nil
local DataStoreService = nil
local strength = nil
local highestHeight = nil
local coin = nil
local EquipmentData = nil
local addedPlayers = {}
local saveDataTimer = 60

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
    if addedPlayers[playerId] then
        return addedPlayers[playerId]["strength"]
    end


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

function UpdateStrength(player)
    local playerId = player.UserId
    local strengthVal = GetStrength(playerId)
    local equipment = EquipmentData:GetEquipedEquipment()
    local addVal = 1
    if equipment ~= nil then
        addVal += equipment.addStrength
    end
    if addedPlayers[playerId] then
        addedPlayers[playerId]["strength"] = strengthVal + addVal
    end

    -- local success, errorMessage = pcall(function()
    --     -- TODO: 后面这里要计算应该增加多少力量值
    --     strength:SetAsync(playerId, strengthVal + addVal)
    -- end)
    -- if not success then
    --     print(errorMessage)
    -- end
end

function GetHighestHeight(playerId)
    if addedPlayers[playerId] then
        return addedPlayers[playerId]["highestheight"]
    end
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
    if addedPlayers[playerId] then
        local curHighestHeight = GetHighestHeight()
        if curHighestHeight < height then
            addedPlayers[playerId]["highestheight"] = height
        end
    end
    AddCoin(playerId, height)
    -- local success, errorMessage = pcall(function()
    --     local oldHeight = highestHeight:GetAsync(playerId)
    --     if oldHeight == nil or height > oldHeight then
    --         highestHeight:SetAsync(playerId, height)
    --     end
    -- end)
    -- if not success then
    --     print(errorMessage)
    -- end

    FirePlayerHighestHeight(player)
    FirePlayerCoin(player)
end

function GetCoin(playerId)
    if addedPlayers[playerId] then
        return addedPlayers[playerId]["coin"]
    end

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
    if addedPlayers[playerId] then
        addedPlayers[playerId]["coin"] = curCoin + math.ceil(height)
    end
    -- local success, errorMessage = pcall(function()
    --     coin:SetAsync(playerId, curCoin + math.ceil(height))
    -- end)
    -- if not success then
    --     print(errorMessage)
    -- end
end

function ForceUpdateStrength(player, strengthVal)
    local playerId = player.UserId
    if addedPlayers[playerId] then
        addedPlayers[playerId]["strength"] = strengthVal
    end
    -- local success, errorMessage = pcall(function()
    --     strength:SetAsync(player.UserId, strengthVal)
    -- end)
    -- if not success then
    --     print(errorMessage)
    -- end
    FirePlayerStrength(player)
end

function ForceUpdateCoin(player, coinVal)
    local playerId = player.UserId
    if addedPlayers[playerId] then
        addedPlayers[playerId]["coin"] = coinVal
    end
    -- local success, errorMessage = pcall(function()
    --     coin:SetAsync(player.UserId, coinVal)
    -- end)
    -- if not success then
    --     print(errorMessage)
    -- end
    FirePlayerCoin(player)
end

function HandleUpdateStrength(player)
    UpdateStrength(player)
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

function HandlePlayerAdded(player)
    PlayerAddedInitData(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    AttachEffect("训练特效", humanoidRootPart)
    AttachEffect("准备起跳特效", humanoidRootPart)
    AttachEffect("落地特效", humanoidRootPart)
    AttachEffect("起跳特效", humanoidRootPart)
    AttachEffect("跳跃", humanoidRootPart)
end

function PlayerAddedInitData(player)
    if not addedPlayers[player.UserId] then
        local coinVal = GetCoin(player.UserId)
        local strengthVal = GetStrength(player.UserId)
        local heightestheightVal = GetHighestHeight(player.UserId)

        addedPlayers[player.UserId] = {
            ["coin"] = coinVal,
            ["strength"] = strengthVal,
            ["highestheight"] = heightestheightVal,
        }
    end
end

function AttachEffect(effectName, humanoidRootPart)
    local effTemplate = ServerStorage:FindFirstChild("特效仓库"):FindFirstChild(effectName)
    local eff = effTemplate:Clone()
    eff.Parent = humanoidRootPart
    if eff:IsA("Part") then
        eff.CFrame = humanoidRootPart.CFrame
    end
    EnableChildren(eff, false)
    -- local effChildren = eff:GetChildren()
    -- for _, child in pairs(effChildren) do
    --     if child:IsA("ParticleEmitter") then
    --         child.Enabled = false
    --     end
    -- end
end

function EnableChildren(parent, enable)
    local children = parent:GetChildren()
    local childrenCnt = #parent:GetChildren()
    if childrenCnt <= 0 then
        return
    end
    for _, child in pairs(children) do
        if child:IsA("ParticleEmitter") then
            child.Enabled = enable
        end
        EnableChildren(child, enable)
    end
end

function SaveData()
    for _, playerdata in addedPlayers do
        local success, errorMessage = pcall(function()
            coin:SetAsync(_, playerdata["coin"])
        end)
        if not success then
            print(errorMessage)
        end

        local success, errorMessage = pcall(function()
            highestHeight:SetAsync(_, playerdata["highestheight"])
        end)
        if not success then
            print(errorMessage)
        end

        local success, errorMessage = pcall(function()
            strength:SetAsync(_, playerdata["strength"])
        end)
        if not success then
            print(errorMessage)
        end
    end
end

function PlayerData:Update(dt)
    saveDataTimer -= dt
    if saveDataTimer <= 0 then
        saveDataTimer = 60
        SaveData()
    end
end

function PlayerData:SaveData()
    SaveData()
end

Players.PlayerAdded:Connect(HandlePlayerAdded)

return PlayerData