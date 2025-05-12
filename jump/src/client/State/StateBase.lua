local StateBase = {}

local stateMachine = nil

function StateBase:new(machine)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    self.stateMachine = machine
    return obj
end

function StateBase:OnEnter()
end

function StateBase:OnUpdate()
end

function StateBase:OnLeave()
end

function StateBase:ChangeState(stateName)
    stateMachine:ChangeState(stateName)
end

return StateBase