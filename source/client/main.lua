local variables = {
    ["Rented Vehicles"] = {},
    ["Peds"] = {},
    ["Vehicle"] = nil,
    ["Target Options"] = {
        ["Open Menu"] = {
            label = "Open Menu",
            onSelect = function()
                lib.showContext(tostring(location.name) .. '_menu')
            end,
            icon = "car-rear"
        },
        ["Return Vehicle"] = {
            label = "Return Last Vehicle",
            onSelect = function()
                if variables["Rented Vehicles"].vehicle then
                    if GetVehicleBodyHealth(variables["Vehicle"]) >= 300 and DoesEntityExist(variables["Vehicle"]) then
                        TriggerServerEvent(cache.resource .. ":server:returned", cache.serverId, SelectedCar.price, true, Netid)
                        lib.notify({
                            title = "Wrench Leo Rental",
                            description = "Thank you for returning your vehicle.",
                            icon = "hand-fist",
                        })
                    else
                        TriggerServerEvent(cache.resource .. ":server:returned", cache.serverId, SelectedCar.price, false, Netid)
                        lib.notify({
                            title = "Wrench Leo Rental",
                            description = "Your car is severely damaged or has been destroyed, please repair it before returning next time!",
                            icon = "hand-fist",
                        })
                    end
                    variables["Rented Vehicles"] = {}
                else
                    lib.notify({
                        title = "Wrench Leo Rental",
                        description = "You haven't rented a vehicle yet!!!",
                        icon = "hand-fist",
                    })
                end
            end,
            icon = "caret-right"
        }
    },
    ["Target"] = exports.ox_target
}

local function getcars(location)
    local cars = {}
    local cartable = {}
    for _, job in pairs(location.jobs) do
        if tostring(NDCore.getPlayer().job) == tostring(job) then   
        for _, i in pairs(location.categories) do
            for _, car in pairs(config["Available Vehicles"][i]) do
                cartable[#cartable + 1] = (car)
            end
            for id, car in pairs(cartable) do
                if type(car) ~= "boolean" then
                    cars[#cars + 1] = {
                        title = car.name,
                        onSelect = function()
                            local tbl = {
                                location = location.vehspawnlocation,
                                car = config["Available Vehicles"][i][id],
                                plrid = cache.serverId
                            }
                            TriggerServerEvent(cache.resource .. ":server:pay", id, tbl)
                        end,
                        metadata = {
                            {label = 'Deposit', value = car.price},
                        }
                    }
                end
            end
            end
        end
    end
    return(cars)
end

local function registerPeds()
    for _, ped in pairs(variables["Peds"]) do
        DeletePed(ped)
    end
    for _, location in pairs(config["Locations"]) do
        local isgood = false
        for _, job in pairs(location.jobs) do
            if NDCore.getPlayer().job == tostring(job) then
                isgood = true
            end
        end
            if isgood == true then
                local model = lib.requestModel(location.pedhash)
                local ped = CreatePed(4, model, location.pedlocation.x, location.pedlocation.y, location.pedlocation.z-1, location.pedlocation.w, false, false)
                FreezeEntityPosition(ped, true)
                SetEntityInvincible(created_ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)
                TaskStartScenarioInPlace(ped, "WORLD_HUMAN_COP_IDLES", 0, true)
                variables["Target"]:addLocalEntity(ped, variables["Target Options"]["Open Menu"])
                variables["Target"]:addLocalEntity(ped, variables["Target Options"]["Return Vehicle"])
                variables["Peds"][#variables["Peds"]+1] = ped
         end
    end
end

RegisterNetEvent(cache.resource .. ":client:confirm", function(table)
    local veh = 0
    local car = table.car
    SelectedCar = table.car
    RequestModel(car.hash)
    while not HasModelLoaded(car.hash) do
        Wait(10)
    end
    veh = CreateVehicle(car.hash, table.location.x, table.location.y, table.location.z, table.location.w, true, false)
    if car.vehicleextras then
        for eid, extra in pairs(car.vehicleextras) do
            SetVehicleExtra(veh, eid, extra)
        end
    else
        for num=1, 14 do 
            SetVehicleExtra(veh, num , 1)
        end
    end
    if car.livery then
        SetVehicleLivery(veh, car.livery)
    end
    variables["Vehicle"] = veh
    SetVehicleEngineOn(veh, true, true, false)
    if DoesEntityExist(veh) then     
        SetVehicleDirtLevel(veh, 0.00)
        lib.notify({
            title = "Wrench Leo Rental",
            description = "Successfully rented vehicle for $" .. tostring(car.price) .. "!",
            icon = "hand-fist",
        })
        local netid = NetworkGetNetworkIdFromEntity(veh)
        Netid = netid
        local tbl = {
            veh = netid,
            src = cache.serverId,
        }
        Wait(200)
        TriggerServerEvent(cache.resource .. ":server:sold", tbl)
        lib.hideTextUI()
        variables["Rented Vehicles"].vehicle = veh
    end
end)

AddEventHandler("ND:characterLoaded", function()
    for _, location in pairs(config["Locations"]) do
        location.menu = lib.registerContext({
            id = tostring(location.name) .. '_menu',
            title = location.name .. " Rental",
            options = getcars(location),
        })
    end
    registerPeds()
end)

RegisterCommand("fixinventory", function()
    NDCore.revivePlayer(false, false)
end)