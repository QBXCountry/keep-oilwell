local QBCore = exports['qb-core']:GetCoreObject()

local function showCDU(data)
    if not data then return end
    
    local state = data.metadata.state and 'Active' or 'Inactive'
    local CDU_Temperature = data.metadata.temp
    local CDU_Gal = data.metadata.oil_storage

    lib.registerContext({
        id = 'cdu_menu',
        title = string.format('Crude oil distillation unit (%s)', state),
        options = {
            {
                title = 'Temperature',
                description = CDU_Temperature .. " °C",
                icon = 'temperature-high',
                disabled = true
            },
            {
                title = 'Crude Oil inside CDU',
                description = CDU_Gal .. " Gallons",
                icon = 'oil-can',
                disabled = true
            },
            {
                title = 'Pump Crude Oil to CDU',
                icon = 'arrows-spin',
                onSelect = function()
                    TriggerEvent("keep-oilrig:CDU_menu:pumpCrudeOil_to_CDU")
                end
            },
            {
                title = 'Change Temperature',
                icon = 'temperature-arrow-up',
                onSelect = function()
                    TriggerEvent("keep-oilrig:CDU_menu:set_CDU_temp")
                end
            },
            {
                title = 'Toggle CDU',
                icon = 'sliders',
                onSelect = function()
                    TriggerEvent("keep-oilrig:CDU_menu:switchPower_of_CDU")
                end
            }
        }
    })

    lib.showContext('cdu_menu')
end

AddEventHandler('keep-oilrig:CDU_menu:ShowCDU', function()
    QBCore.Functions.TriggerCallback('keep-oilrig:server:get_CDU_Data', function(result)
        showCDU(result)
    end)
end)

AddEventHandler('keep-oilrig:CDU_menu:switchPower_of_CDU', function()
    QBCore.Functions.TriggerCallback('keep-oilrig:server:switchPower_of_CDU', function(result)
        showCDU(result)
    end)
end)

AddEventHandler('keep-oilrig:CDU_menu:set_CDU_temp', function()
    local input = lib.inputDialog('CDU Temperature', {
        {
            type = 'number',
            label = 'Temperature',
            description = 'Enter new temperature',
            required = true,
            min = 0 -- Adjust min/max based on your needs
        }
    })

    if input then
        local temp = input[1]
        if temp then
            QBCore.Functions.TriggerCallback('keep-oilrig:server:set_CDU_temp', function(result)
                showCDU(result)
            end, {temp = temp})
        end
    end
end)

AddEventHandler('keep-oilrig:CDU_menu:pumpCrudeOil_to_CDU', function()
    local input = lib.inputDialog('Pump crude oil to CDU', {
        {
            type = 'number',
            label = 'Amount',
            description = 'Enter amount to pump',
            required = true,
            min = 1 -- Ensures amount is more than 0
        }
    })

    if input then
        local amount = tonumber(input[1])
        if amount then
            QBCore.Functions.TriggerCallback('keep-oilrig:server:pumpCrudeOil_to_CDU', function(result)
                showCDU(result)
            end, {amount = amount})
        end
    end
end)
