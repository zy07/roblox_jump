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
    print("State On Enter")
end

function StateBase:OnUpdate()
    print("State On Update")
end

function StateBase:OnLeave()
    print("State On Leave")
end

function StateBase:ChangeState(stateName)
    stateMachine:ChangeState(stateName)
end

return StateBase