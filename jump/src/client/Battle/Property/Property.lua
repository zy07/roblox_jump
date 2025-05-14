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

return Property