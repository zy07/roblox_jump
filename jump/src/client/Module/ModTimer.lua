local ModTimer = {}

local id = 0

local timers = {}
local removeIds = {}

function ModTimer:AddTimer(time, callback)
    timers[id] = {
        ["time"] = time,
        ["callback"] = callback
    }
    id += 1
end

function ModTimer:Update(dt)
    for _, timer in timers do
        timer["time"] = timer["time"] - dt
        if timer["time"] <= 0 then
            timer["callback"]()
            timers[_] = nil
        end
    end
end

return ModTimer