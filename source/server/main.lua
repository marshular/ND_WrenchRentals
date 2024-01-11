RegisterNetEvent(cache.resource .. ":server:pay", function(id, table)
    if table ~= nil then
        local car = table.car
        if not car then return end
        local src = table.plrid
        local player = NDCore.getPlayer(src)
        if player then
            if player.cash >= car.price then
                player.deductMoney("cash", car.price, "Car Rental")
                TriggerClientEvent(cache.resource .. "client:confirm", src, table)
                return
            elseif player.bank >= car.price then
                return player.deductMoney("bank", car.price, "Car Rental") and TriggerClientEvent(cache.resource .. "client:confirm", src, table)
            elseif player.cash < car.price or player.bank < car.price then
                return TriggerClientEvent('ox_lib:notify', id, {
                    title = "Wrench Leo Rental",
                    description = "You don't have the required amount of money to rent a this vehicle!",
                    icon = "hand-fist",
                })
            end    
            return TriggerClientEvent('ox_lib:notify', id, {
                title = 'Purchase Error',
                description = 'Not enough cash. - $' .. car.price .. " needed.",
                position = 'bottom',
                style = {
                    backgroundColor = '#141517',
                    color = '#909296'
                },
                icon = 'ban',
                iconColor = '#C53030'
            })
        end
    end
end)

RegisterNetEvent(cache.resource .. ":server:returned", function(source, amount, tf, netid)
    local player = NDCore.getPlayer(tonumber(source))
    if config["Debug"] then print(tostring(tonumber(source)) .. " returned a LEO vehicle") end
    if tf == true then
        player.addMoney("cash", tonumber(amount), "Returned Vehicle")
    end
    local vehicle = NetworkGetEntityFromNetworkId(netid)
    DeleteEntity(vehicle)  
    NDCore.giveVehicleAccess(tonumber(source), vehicle, false)
end)

RegisterNetEvent(cache.resource .. ":server:sold", function(table)
    local netid = NetworkGetEntityFromNetworkId(table.veh)
    if config["Debug"] then print(tostring(table.src) .. " Rented an LEO Vehicle")end
    NDCore.giveVehicleAccess(tonumber(table.src), netid, true)
end)
