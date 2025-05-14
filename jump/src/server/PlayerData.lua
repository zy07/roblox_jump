local PlayerData = {}

local DataStoreService = nil

function PlayerData:new(dataStoreService)
    local obj = {}
	self.__index = self
	setmetatable(obj, self)
    DataStoreService = dataStoreService
	return obj
end

function PlayerData:UpdateData()
    
end

return PlayerData