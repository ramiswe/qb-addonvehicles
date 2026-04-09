local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand("addonmenu", function()
    TriggerEvent("qb-addonvehicles:client:OpenMenu")
end)

RegisterNetEvent("qb-addonvehicles:client:OpenMenu", function()


    -- Menu por marcas
    local brands = {}

    -- Crear lista de marcas únicas
    for model, data in pairs(QBAddonVehicles) do
        if data.brand then
            brands[data.brand] = true
        end
    end

    -- Convertir marcas a lista ordenada
    local sortedBrands = {}
    for brand, _ in pairs(brands) do
        table.insert(sortedBrands, brand)
    end
    table.sort(sortedBrands)

    -- Crear menú
    local options = {}

    for _, brand in ipairs(sortedBrands) do
        options[#options+1] = {
            title = brand,
            icon = "car",
            onSelect = function()
                TriggerEvent("qb-addonvehicles:client:OpenBrandMenu", brand)
            end
        }
    end

    lib.registerContext({
        id = 'addon_vehicle_menu',
        title = '🚗 Vehículos Addon',
        options = options
    })

    lib.showContext('addon_vehicle_menu')
end)

RegisterNetEvent("qb-addonvehicles:client:OpenBrandMenu", function(brand)
    local models = {}

    -- Recoger modelos de esa marca
    for model, data in pairs(QBAddonVehicles) do
        if data.brand == brand then
            table.insert(models, { model = model, name = data.name })
        end
    end

    -- Ordenar modelos por nombre
    table.sort(models, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    -- Crear menú
    local options = {}

    -- 🔙 BOTÓN VOLVER ATRÁS
    options[#options+1] = {
        title = "Volver",
        icon = "arrow-left",
        onSelect = function()
            TriggerEvent("qb-addonvehicles:client:OpenMenu")
        end
    }

    -- Añadir modelos
    for _, v in ipairs(models) do
        options[#options+1] = {
            title = v.name,
            description = ("Modelo: %s"):format(v.model),
            icon = "car",
            onSelect = function()
                TriggerServerEvent("qb-addonvehicles:server:PreviewVehicle", v.model)
            end
        }
    end

    lib.registerContext({
        id = 'addon_brand_menu',
        title = "🚗 " .. brand,
        options = options
    })

    lib.showContext('addon_brand_menu')
end)

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

RegisterNetEvent('qb-addonvehicles:client:PreviewVehicle', function(model)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local veh = GetVehiclePedIsIn(ped, false)

    -- Si está en un vehículo, comprobamos si es de preview
    if veh ~= 0 then
        local plate = GetVehicleNumberPlateText(veh)

        -- Si es un coche de preview, lo eliminamos
        if plate and plate:sub(1, 4) == "PREV" then
            DeleteVehicle(veh)
        else
            -- Si es un coche real, movemos el spawn para no destruirlo
            coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 3.5, 0.0)
        end
    else
        -- Si no está en un coche, spawneamos delante
        coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 3.5, 0.0)
    end

    -- Spawnear vehículo de preview
    QBCore.Functions.SpawnVehicle(model, function(veh)
        local plate = "PREV"..math.random(1000,9999)
        SetVehicleNumberPlateText(veh, plate)
        SetEntityHeading(veh, GetEntityHeading(ped))

        -- Solo meter al jugador si no estaba en un coche real
        if GetVehiclePedIsIn(ped, false) == 0 then
            TaskWarpPedIntoVehicle(ped, veh, -1)
        end

        TriggerEvent("vehiclekeys:client:SetOwner", plate)
        QBCore.Functions.Notify("Vehículo de visualización generado", "primary")
    end, coords, true)
end)