local QBCore = exports['qb-core']:GetCoreObject()
local vehicles = {}

RegisterNetEvent('keep-oilwell:server_lib:update_vehicle', function(vehiclePlate, items)
    local src = source
    if not vehicles[src] then
        vehicles[src] = {}
    end
    vehicles[src][vehiclePlate] = vehiclePlate
    
    -- Create trunk inventory for the vehicle
    exports.ox_inventory:RegisterStash(
        'trunk_' .. vehiclePlate, -- unique identifier
        'Trunk ' .. vehiclePlate, -- display name
        Oilwell_config.Delivery.trunkSize or 100, -- slots (adjust as needed)
        Oilwell_config.Delivery.trunkWeight or 100000, -- weight (adjust as needed)
        nil, -- owner (nil for public)
        nil, -- jobs
        nil -- coords (nil for vehicle trunk)
    )
    
    -- Add items to the trunk
    local trunk = exports.ox_inventory:GetInventory('trunk_' .. vehiclePlate)
    if trunk then
        for _, item in pairs(items) do
            exports.ox_inventory:AddItem('trunk_' .. vehiclePlate, item.name, item.amount, item.metadata)
        end
    end
end)

QBCore.Functions.CreateCallback('keep-oilwell:server:refund_truck', function(source, cb, vehiclePlate)
    if vehicles[source] and vehicles[source][vehiclePlate] then
        local player = QBCore.Functions.GetPlayer(source)
        
        -- Remove the trunk inventory
        exports.ox_inventory:RemoveInventory('trunk_' .. vehiclePlate)
        
        -- Add refund money
        player.Functions.AddMoney('bank', Oilwell_config.Delivery.refund, 'oil_barells')
        vehicles[source][vehiclePlate] = nil
        cb(true)
        return
    end
    cb(false)
end)
