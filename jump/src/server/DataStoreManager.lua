local DataStoreManager = {}
local dsService = nil

local JumpData = nil
local PlayerData = {
    ["coin"] = 0,
    ["strength"] = 0,
    ["highestheight"] = 0,
    ["equipId"] = 0,
    ["unlockIds"] = {}
}

function DataStoreManager:new(dataSourceService)
    dsService = dataSourceService
    JumpData = dsService:GetDataStore("JumpData")
end

return DataStoreManager