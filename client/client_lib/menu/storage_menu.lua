local QBCore = exports['qb-core']:GetCoreObject()

local function showStorage(storage_data)
    local options = {
        {
            title = 'Crude oil',
            description = storage_data.metadata.crudeOil .. " /gal",
            icon = 'oil-can',
            onSelect = function()
                TriggerEvent('keep-oilrig:storage_menu:StorageActions', {
                    type = 'crudeOil',
                    storage_data = storage_data
                })
            end
        },
        {
            title = 'Gasoline',
            description = string.format("%s /gal | Octane: %s", 
                storage_data.metadata.gasoline, 
                storage_data.metadata.avg_gas_octane
            ),
            icon = 'oil-can',
            onSelect = function()
                TriggerEvent('keep-oilrig:storage_menu:StorageActions', {
                    type = 'gasoline',
                    storage_data = storage_data
                })
            end
        }
    }

    if storage_data.metadata.fuel_oil then
        options[#options + 1] = {
            title = 'Fuel Oil',
            description = storage_data.metadata.fuel_oil .. " /gal",
            icon = 'oil-can',
            onSelect = function()
                TriggerEvent('keep-oilrig:storage_menu:StorageActions', {
                    type = 'fuel_oil',
                    storage_data = storage_data
                })
            end
        }
    end

    lib.registerContext({
        id = 'storage_menu',
        title = storage_data.name,
        options = options
    })

    lib.showContext('storage_menu')
end

local function showStorageActions(data)
    lib.registerContext({
        id = 'storage_actions',
        title = "Actions " .. data.type,
        menu = 'storage_menu',
        options = {
            {
                title = 'Withdraw from storage',
                description = '',
                icon = 'truck-ramp-box',
                onSelect = function()
                    TriggerEvent('keep-oilrig:storage_menu:StorageWithdraw', data)
                end
            },
            {
                title = 'Storage action',
                icon = 'arrow-right-arrow-left',
                disabled = true
            }
        }
    })

    lib.showContext('storage_actions')
end

local function showStorageWithdraw(data)
    local currentWithdrawTarget = data.storage_data.metadata[data.type]

    lib.registerContext({
        id = 'storage_withdraw',
        title = "Storage withdraw (" .. data.type .. ")",
        menu = 'storage_actions',
        options = {
            {
                title = 'Current Amount',
                description = string.format('You have %s gal of %s', currentWithdrawTarget, data.type),
                icon = 'boxes-packing',
                disabled = true
            },
            {
                title = 'Store in Barrel',
                description = "deposit: $500   Capacity: 5000 /gal",
                icon = 'bottle-droplet',
                onSelect = function()
                    TriggerEvent('keep-oilrig:storage_menu:Callback', {
                        eventName = 'keep-oilrig:server:Withdraw',
                        citizenid = data.storage_data.citizenid,
                        type = data.type,
                        truck = false
                    })
                end
            },
            {
                title = 'Load in Truck',
                description = "deposit: $25,000k   Capacity: 100,000 /gal",
                icon = 'truck-droplet',
                onSelect = function()
                    TriggerEvent('keep-oilrig:storage_menu:Callback', {
                        eventName = 'keep-oilrig:server:Withdraw',
                        citizenid = data.storage_data.citizenid,
                        type = data.type,
                        truck = true
                    })
                end
            }
        }
    })

    lib.showContext('storage_withdraw')
end

-- Vehicle functions remain largely the same
MakeVehicle = function(model, Coord, TriggerLocation, DinstanceToTrigger, items)
    -- Keep existing implementation
    -- Just update the targeting system:
    Targets.ox_target.truck(vehiclePlate, veh)
end

-- Events
AddEventHandler('keep-oilrig:storage_menu:ShowStorage', function(data)
    QBCore.Functions.TriggerCallback('keep-oilrig:server:getStorageData', function(result)
        showStorage(result)
    end)
end)

AddEventHandler('keep-oilrig:storage_menu:StorageActions', function(storage_data)
    showStorageActions(storage_data)
end)

AddEventHandler('keep-oilrig:storage_menu:StorageWithdraw', function(data)
    showStorageWithdraw(data)
end)

AddEventHandler('keep-oilrig:storage_menu:Callback', function(data)
    local input = lib.inputDialog('Enter withdraw value', {
        {
            type = 'number',
            label = 'Amount',
            description = 'Enter amount to withdraw',
            required = true
        }
    })

    if input then
        data.amount = input[1]
        QBCore.Functions.TriggerCallback(data.eventName, function(res)
        end, data)
    end
end)

-- Withdraw spot events
AddEventHandler("keep-oilwell:client:openWithdrawStash", function(data)
    local player = QBCore.Functions.GetPlayerData()
    if not data then return end
    local settings = { maxweight = 100000, slots = 5 }
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "Withdraw_" .. player.citizenid, settings)
    TriggerEvent("inventory:client:SetCurrentStash", "Withdraw_" .. player.citizenid)
end)

-- Purge menu
local function purge_menu()
    lib.registerContext({
        id = 'purge_menu',
        title = 'PURGE',
        options = {
            {
                title = 'Do you want to purge withdraw stash?',
                description = 'This action cannot be undone',
                icon = 'trash-can',
                disabled = true
            },
            {
                title = 'Confirm Purge!',
                icon = 'square-check',
                onSelect = function()
                    TriggerEvent('keep-oilwell:client:purgeWithdrawStash')
                end
            }
        }
    })

    lib.showContext('purge_menu')
end

AddEventHandler('keep-oilwell:client:open_purge_menu', function()
    purge_menu()
end)

local purge_conf = 0
AddEventHandler('keep-oilwell:client:purgeWithdrawStash', function()
    if purge_conf == 0 then
        QBCore.Functions.Notify('Try again to confirm Purge! (confirmation will reset in 5sec)', "primary")
        purge_conf = purge_conf + 1
        SetTimeout(5000, function()
            purge_conf = 0
        end)
        purge_menu()
        return
    end
    purge_conf = 0
    TriggerServerEvent('keep-oilwell:server:purgeWithdrawStash')
end)
