local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-addonvehicles:client:GiveVehicle', function(model)
    local QBCore = exports['qb-core']:GetCoreObject()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    QBCore.Functions.SpawnVehicle(model, function(veh)
        local plate = "AD"..math.random(1000,9999)
        SetVehicleNumberPlateText(veh, plate)
        SetEntityHeading(veh, GetEntityHeading(ped))
        TaskWarpPedIntoVehicle(ped, veh, -1)

        TriggerEvent("vehiclekeys:client:SetOwner", plate)

        -- REGISTRO EN LA BASE DE DATOS
        TriggerServerEvent("qb-addonvehicles:server:RegisterVehicle", plate, model)

        QBCore.Functions.Notify("Vehículo entregado y registrado correctamente", "success")
    end, coords, true)
end)