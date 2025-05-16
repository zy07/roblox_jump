local UIManager = require(game.StarterGui.UIScript.UIManager)
local ModEquipment = require(game.StarterPlayer.StarterPlayerScripts.Module.ModEquipment)
local ui = UIManager:Get("器材背包ui")

ui["黑色背景"]["关闭"].Activated:Connect(function(inputObject: InputObject, clickCount: number)
    ui.Visible = false
end)

local itemTemplate = ui["黑色背景"]["背包"]["背包"]["模板"]
itemTemplate.Visible = false

local equipments = ModEquipment.Equipments
for _, equipment in pairs(equipments) do
    local newTemplate = itemTemplate:Clone()
    newTemplate.Parent = itemTemplate.Parent
    newTemplate.Visible = true
    if equipment.icon ~= nil then
        newTemplate["物品图片"].Image = equipment.icon
    end
    if equipment.price ~= nil then
        newTemplate["价钱"]["数量"].Text = equipment.price
    else
        newTemplate["价钱"]["数量"].Text = "缺少配置"
    end
    newTemplate["价钱"].Visible = equipment.Lock
    newTemplate["当前装备"].Visible = equipment.Equip
    newTemplate["未购买"].Visible = not equipment.Lock
    newTemplate["选择"].Visible = false
end