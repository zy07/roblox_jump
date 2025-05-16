local Property = {}

function Property:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

Property["Strength"] = 0
Property["Jumpable"] = true
Property["Trainable"] = true
Property["HighestHeight"] = 0
Property["Jumping"] = false
Property["Coin"] = 0

return Property