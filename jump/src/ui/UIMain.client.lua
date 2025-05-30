local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local ModPlayers = require(game.StarterPlayer.StarterPlayerScripts.Player.ModPlayers)
local PlayerController = require(game.StarterPlayer.StarterPlayerScripts.Player.PlayerController)
local UIManager = require(game.StarterGui.UIScript.UIManager)

local main = UIManager:Get("主界面")

main['数据栏位']['现在高度']['文字'].Text = string.format("%.2f m", 0)
main['数据栏位']['速度']['文字'].Text = string.format("%.2f m/s", 0)
main['自动锻炼开'].Visible = false
main['自动锻炼关'].Visible = false

EventCenter:AddCEventListener(EventCenter.EventType.CUpdateStrength, function(strength)
    main['资源栏对齐']['力量资源条']['力量剩余'].Text = strength
end)

EventCenter:AddCEventListener(EventCenter.EventType.CUpdateHighestHeight, function(val)
    main['数据栏位']['最高高度']['文字'].Text = string.format("%.2f m", val)
end)

EventCenter:AddCEventListener(EventCenter.EventType.CUpdateCoin, function(val)
    main['资源栏对齐']['金币资源条']['金币剩余'].Text = val
end)

EventCenter:AddCEventListener(EventCenter.EventType.CJumping, function(speedY, height, highestHeight)
    local newHighestHeight =highestHeight
    if height == nil then
        height = 0
    end
    if height > highestHeight then
        newHighestHeight = height
    end
    main['数据栏位']['最高高度']['文字'].Text = string.format("%.2f m", newHighestHeight)
    main['数据栏位']['现在高度']['文字'].Text = string.format("%.2f m", height)
    main['数据栏位']['速度']['文字'].Text = string.format("%.2f m/s", speedY)
end)

EventCenter:AddCEventListener(EventCenter.EventType.CLand, function(highestHeight)
    main['数据栏位']['最高高度']['文字'].Text = string.format("%.2f m", highestHeight)
    main['数据栏位']['现在高度']['文字'].Text = string.format("%.2f m", 0)
    main['数据栏位']['速度']['文字'].Text = string.format("%.2f m/s", 0)
    main['立即下落'].Visible = false
end)

EventCenter:AddCEventListener(EventCenter.EventType.CKeyboard, function(keyCode)
    if keyCode == Enum.KeyCode.One then
        ClickJump()
    elseif keyCode == Enum.KeyCode.Two then
        ClickEquip()
    end
end)

EventCenter:AddCEventListener(EventCenter.EventType.CStartJumping, function()
    main['立即下落'].Visible = true
end)


-- main['跳跃'].Activated:Connect(function(inputObject: InputObject, clickCount: number)
-- 	EventCenter:SendEvent(EventCenter.EventType.CAttack)
-- end)

main['功能按钮自动对齐']['背包'].Activated:Connect(function(inputObject: InputObject, clickCount: number)
    UIManager:Show("器材背包ui")
end)

main['切换功能栏']['健身器材']['选中'].Visible = false
main['切换功能栏']['起跳下落']['选中'].Visible = false

function ClickEquip()
    local state = not main['切换功能栏']['健身器材']['选中'].Visible
    main['切换功能栏']['健身器材']['选中'].Visible = state
    main['自动锻炼开'].Visible = state
    if state then
        main['切换功能栏']['起跳下落']['选中'].Visible = false
    end
    EventCenter:SendEvent(EventCenter.EventType.CPlayerChangeState, PlayerController.StateType.EQUIP)
end

main['切换功能栏']['健身器材'].Activated:Connect(function(inputObject: InputObject, clickCount: number)
    ClickEquip()
end)

function ClickJump()
    local state = not main['切换功能栏']['起跳下落']['选中'].Visible
    main['切换功能栏']['起跳下落']['选中'].Visible = state
    main['自动锻炼开'].Visible = false
    main['自动锻炼关'].Visible = false
    if state then
        main['切换功能栏']['健身器材']['选中'].Visible = false
    end
    EventCenter:SendEvent(EventCenter.EventType.CPlayerChangeState, PlayerController.StateType.JUMP)
end

main['切换功能栏']['起跳下落'].Activated:Connect(function(inputObject: InputObject, clickCount: number)
    ClickJump()
end)

main['立即下落'].Activated:Connect(function(inputObject: InputObject, clickCount: number)
    EventCenter:SendEvent(EventCenter.EventType.CForceLand)
end)

main['自动锻炼开'].Activated:Connect(function(inputObject:InputObject, clickCount:number)
    main['自动锻炼开'].Visible = false
    main['自动锻炼关'].Visible = true
    EventCenter:SendEvent(EventCenter.EventType.CAutoTrain, true)
end)

main['自动锻炼关'].Activated:Connect(function(inputObject:InputObject, clickCount:number)
    main['自动锻炼开'].Visible = true
    main['自动锻炼关'].Visible = false
    EventCenter:SendEvent(EventCenter.EventType.CAutoTrain, false)
end)