local inv = exports.ox_inventory

ESX.RegisterServerCallback('siir_fishing:checkRod', function(source, cb, item)
    local xPlayer = ESX.GetPlayerFromId(source)

    if inv:GetItem(xPlayer.source, item, false, true) >= 1 then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('siir_fishing:removeItem')
AddEventHandler('siir_fishing:removeItem', function(bait_used)
    local xPlayer = ESX.GetPlayerFromId(source)

    local fish_bait = inv:GetItem(xPlayer.source, bait_used)
    if fish_bait.count > 0 then
        inv:RemoveItem(xPlayer.source, bait_used, 1)
    end
end)

RegisterNetEvent('siir_fishing:giveItem')
AddEventHandler('siir_fishing:giveItem', function(bait, zone)
    local xPlayer = ESX.GetPlayerFromId(source)
    math.randomseed(os.time())
    local itemSelect = math.random(1, #Config[zone].CatchItems[bait])
    local item = Config[zone].CatchItems[bait][itemSelect]
    local catchWeight = math.random(item.minWeight, item.maxWeight)
    TriggerClientEvent('siir_fishing:spawnModel', xPlayer.source, item.model)

    if xPlayer.getWeight() + catchWeight <= xPlayer.getMaxWeight() then
        
        inv:AddItem(xPlayer.source, item.catch, 1, {weight = catchWeight})
        TriggerClientEvent('t-notify:client:Custom', source, {
            style = 'info',
            message = 'You caught a ' .. exports.ox_inventory:ItemList(item.catch).label .. ' weighing ' .. catchWeight .. 'g',
            position = 'middle-right',
            duration = 600
        })
    else
        TriggerClientEvent('t-notify:client:Custom', source, {
            style = 'info',
            message = exports.ox_inventory:ItemList(item.catch).label .. ' weighing ' .. catchWeight .. 'g is too heavy',
            position = 'middle-right',
            duration = 600
        })
    end
end)