local EventCenter = require(game.StarterPlayer.StarterPlayerScripts.Event.ClientEventCenter)
local SharedEvent = require(game.ReplicatedStorage.Shared.EventHandlesCenter)
local playerCtrlTemplate = require(game.StarterPlayer.StarterPlayerScripts.Player.PlayerController)
local ModPlayers = {}
local Players = game:GetService("Players")
local players = Players:GetPlayers()
local playerCtrls = {}
local localPlayer = Players.LocalPlayer

local function HandlePlayerAdded(player)
    local playerCtrl = playerCtrlTemplate:new(player)
    if not playerCtrls[player] then
        playerCtrls[player] = playerCtrl
    end
end

for _, existPlayer in players do
    HandlePlayerAdded(existPlayer)
end

Players.PlayerAdded:Connect(HandlePlayerAdded)

function ModPlayers:Update()
    for _, playerCtrl in playerCtrls do
        playerCtrl:Update()
    end
end

EventCenter:AddCEventListener(EventCenter.EventType.CPlayerChangeState, function(state)
    playerCtrls[localPlayer]:HandleChangeEquipAnim(state)
end)

EventCenter:AddCEventListener(EventCenter.EventType.CEquipmentChanged, function()
    playerCtrls[localPlayer]:HandleEuiqpmentChanged()
end)

return ModPlayers