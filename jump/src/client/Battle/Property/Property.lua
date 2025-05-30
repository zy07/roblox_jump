local Property = {}

function Property:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

Property["Strength"] = 0
Property["Jumpable"] = false
Property["Trainable"] = false
Property["HighestHeight"] = 0
Property["Jumping"] = false
Property["Coin"] = 0
Property["Training"] = false
Property["AutoTrain"] = false

return Property