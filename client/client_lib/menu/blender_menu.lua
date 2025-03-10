local QBCore = exports['qb-core']:GetCoreObject()

local function showblender(data)
    if not data then return end
    
    local state = data.metadata.state and 'Active' or 'Inactive'
    local start_btn = state == 'Active' and 'Stop' or 'Start'
    local start_icon = state == 'Active' and 'circle-stop' or 'square-caret-right'

    local options = {
        {
            title = 'Heavy Naphtha',
            description = data.metadata.heavy_naphtha .. " Gallons",
            icon = 'circle',
            disabled = true
        },
        {
            title = 'Light Naphtha',
            description = data.metadata.light_naphtha .. " Gallons",
            icon = 'circle',
            disabled = true
        },
        {
            title = 'Other Gases',
            description = data.metadata.other_gases .. " Gallons",
            icon = 'circle',
            disabled = true
        }
    }

    -- Add optional elements
    if data.metadata.diesel then
        options[#options + 1] = {
            title = 'Diesel',
            description = data.metadata.diesel .. " Gallons",
            icon = 'circle',
            disabled = true
        }
    end

    if data.metadata.kerosene then
        options[#options + 1] = {
            title = 'Kerosene',
            description = data.metadata.kerosene .. " Gallons",
            icon = 'circle',
            disabled = true
        }
    end

    if data.metadata.fuel_oil then
        options[#options + 1] = {
            title = 'Fuel oil',
            description = data.metadata.fuel_oil .. " Gallons (no use in blending process)",
            icon = 'circle',
            disabled = true
        }
    end

    -- Add action buttons
    options[#options + 1] = {
        title = 'Change Recipe',
        icon = 'scroll',
        onSelect = function()
            TriggerEvent("keep-oilrig:blender_menu:recipe_blender")
        end
    }

    options[#options + 1] = {
        title = start_btn .. ' Blending',
        icon = start_icon,
        onSelect = function()
            TriggerEvent("keep-oilrig:blender_menu:toggle_blender")
        end
    }

    options[#options + 1] = {
        title = 'Pump Fuel-Oil to Storage',
        icon = 'arrows-spin',
        onSelect = function()
            TriggerEvent("keep-oilrig:blender_menu:pump_fueloil")
        end
    }

    lib.registerContext({
        id = 'blender_menu',
        title = string.format("Blender unit (%s)", state),
        options = options
    })

    lib.showContext('blender_menu')
end

AddEventHandler('keep-oilrig:blender_menu:pump_fueloil', function()
    QBCore.Functions.TriggerCallback('keep-oilrig:server:pump_fueloil', function(result)
        showblender(result)
    end)
end)

AddEventHandler('keep-oilrig:blender_menu:ShowBlender', function()
    QBCore.Functions.TriggerCallback('keep-oilrig:server:ShowBlender', function(result)
        showblender(result)
    end)
end)

AddEventHandler('keep-oilrig:blender_menu:toggle_blender', function()
    QBCore.Functions.TriggerCallback('keep-oilrig:server:toggle_blender', function(result)
        showblender(result)
    end)
end)

local function inRange(x, min, max)
    return (x >= min and x <= max)
end

AddEventHandler('keep-oilrig:blender_menu:recipe_blender', function()
    local input = lib.inputDialog('Blender Recipe', {
        {
            type = 'number',
            label = 'Heavy Naphtha',
            description = 'Enter value (0-100)',
            required = true,
            min = 0,
            max = 100
        },
        {
            type = 'number',
            label = 'Light Naphtha',
            description = 'Enter value (0-100)',
            required = true,
            min = 0,
            max = 100
        },
        {
            type = 'number',
            label = 'Other Gases',
            description = 'Enter value (0-100)',
            required = true,
            min = 0,
            max = 100
        },
        {
            type = 'number',
            label = 'Diesel',
            description = 'Enter value (0-100)',
            required = true,
            min = 0,
            max = 100
        },
        {
            type = 'number',
            label = 'Kerosene',
            description = 'Enter value (0-100)',
            required = true,
            min = 0,
            max = 100
        }
    })

    if input then
        local inputData = {
            heavy_naphtha = input[1],
            light_naphtha = input[2],
            other_gases = input[3],
            diesel = input[4],
            kerosene = input[5]
        }

        -- Additional validation if needed
        for _, value in pairs(inputData) do
            if not inRange(value, 0, 100) then
                QBCore.Functions.Notify('Numbers must be between 0-100', "primary")
                return
            end
        end

        QBCore.Functions.TriggerCallback('keep-oilrig:server:recipe_blender', function(result)
            showblender(result)
        end, inputData)
    end
end)
