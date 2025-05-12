local StateMachine = {}

local curStateName = nil
local states = {}

function StateMachine:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function StateMachine:Run(stateName)
    if curStateName ~= nil and states[curStateName] then
        states[curStateName]:OnLeave()
    end

    if states[stateName] then
        curStateName = stateName
        states[curStateName]:OnEnter()
    else
        warn("State " .. stateName .. " does not exist.")
    end
end

function StateMachine:AddState(name, state)
    if states[name] then
        warn("State " .. name .. " already exists.")
    else
        states[name] = state
    end
end

function StateMachine:ChangeState(stateName)
    if states[stateName] and states[curStateName] then
        states[curStateName]:OnLeave()
        curStateName = stateName
        states[curStateName]:OnEnter()
    else
        warn("State " .. stateName .. " does not exist or cannot be changed from " .. curStateName)
    end
end

function StateMachine:Update()
    if states[curStateName] then
        states[curStateName]:OnUpdate()
    end
end

return StateMachine