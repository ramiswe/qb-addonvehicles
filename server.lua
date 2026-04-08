local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    for model, data in pairs(QBAddonVehicles) do
        QBCore.Shared.Vehicles[model] = data
    end
end)

QBCore.Commands.Add("givecar", "Dar coche addon a un jugador", {
    {name="id", help="ID del jugador"},
    {name="model", help="Modelo del coche addon"}
}, true, function(source, args)
    local targetId = tonumber(args[1])
    local model = tostring(args[2])

    if not targetId or targetId == 0 then
        TriggerClientEvent('QBCore:Notify', source, "ID del jugador inválido", "error")
        return
    end

    targetId = math.floor(targetId)

    if not QBCore.Shared.Vehicles[model] then
        TriggerClientEvent('QBCore:Notify', source, "Ese coche no existe en la lista addon", "error")
        return
    end

    TriggerClientEvent('qb-addonvehicles:client:GiveVehicle', targetId, model)
end, "admin")


RegisterNetEvent('qb-addonvehicles:server:RegisterVehicle', function(plate, model)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    local license = Player.PlayerData.license

    exports.oxmysql:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, fuel, engine, body, state, depotprice, balance, drivingdistance, fakeplate, financetime, paymentamount, paymentsleft, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
            license,
            citizenid,
            model,
            GetHashKey(model),
            '{}',
            plate,
            "pillboxgarage",
            100,
            1000,
            1000,
            0,
            0,
            0,
            0,
            nil,
            0,
            0,
            0,
            '{}'
        })
end)