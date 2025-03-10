local QBCore = exports['qb-core']:GetCoreObject()

local function show_transport_menu()
    lib.registerContext({
        id = 'transport_menu',
        title = 'Transport',
        description = 'Sell your crude oil to make a profit',
        options = {
            {
                title = 'Check Current Price/Stock',
                icon = 'hand-holding-dollar',
                onSelect = function()
                    TriggerEvent('keep-oilwell:menu:show_transport_menu:ask_stock_price')
                end
            },
            {
                title = 'Request Sell Order',
                icon = 'diagram-successor',
                onSelect = function()
                    TriggerEvent('keep-oilwell:menu:show_transport_menu:ask_to_sell_amount')
                end
            }
        }
    })

    lib.showContext('transport_menu')
end

AddEventHandler('keep-oilwell:menu:show_transport_menu', function()
    show_transport_menu()
end)

AddEventHandler('keep-oilwell:menu:show_transport_menu:ask_stock_price', function()
    TriggerServerEvent('keep-oilrig:server:oil_transport:checkPrice')
end)

-- Combat disable function remains the same
local function disableCombat()
    DisablePlayerFiring(PlayerId(), true)
    DisableControlAction(0, 24, true)
    DisableControlAction(0, 25, true)
    DisableControlAction(1, 37, true)
    DisableControlAction(0, 47, true)
    DisableControlAction(0, 58, true)
    DisableControlAction(0, 140, true)
    DisableControlAction(0, 141, true)
    DisableControlAction(0, 142, true)
    DisableControlAction(0, 143, true)
    DisableControlAction(0, 263, true)
    DisableControlAction(0, 264, true)
    DisableControlAction(0, 257, true)
end

-- Animation loading functions remain the same
function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

function LoadPropDict(model)
    while not HasModelLoaded(GetHashKey(model)) do
        RequestModel(GetHashKey(model))
        Wait(10)
    end
end

-- Prop attachment functions remain the same
local active_prop = nil
function AttachProp(model, bone, x, y, z, rot1, rot2, rot3)
    local playerped = PlayerPedId()
    local model_hash = GetHashKey(model)
    local playercoord = GetEntityCoords(playerped)
    local bone_index = GetPedBoneIndex(playerped, bone)
    local _x, _y, _z = table.unpack(playercoord)

    if not HasModelLoaded(model) then
        LoadPropDict(model)
    end

    active_prop = CreateObject(model_hash, _x, _y, _z + 0.2, true, true, true)
    AttachEntityToEntity(active_prop, playerped, bone_index, x, y, z, rot1, rot2, rot3, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(model)
end

-- Barrel animation functions remain the same
local function start_barell_animation()
    local playerped = PlayerPedId()
    local dict = 'anim@heists@box_carry@'
    local anim = 'idle'
    local PropName = 'prop_barrel_exp_01a'
    local PropBone = 60309

    LoadAnim(dict)
    ClearPedTasks(playerped)
    RemoveAnimDict(dict)
    Wait(250)
    AttachProp(PropName, PropBone, 0.0, 0.41, 0.3, 130.0, 290.0, 0.0)
    
    CreateThread(function()
        while active_prop do
            local not_animation = IsEntityPlayingAnim(playerped, dict, anim, 3)
            if not_animation ~= 1 then
                TaskPlayAnim(playerped, dict, anim, 2.0, 2.0, -1, 51, 0, false, false, false)
                DisableControlAction(0, 22, true)
            end
            Wait(1500)
        end
    end)
    
    CreateThread(function()
        while active_prop do
            disableCombat()
            Wait(1)
        end
    end)
end

local function end_barell_animaiton()
    local playerped = PlayerPedId()
    local dict = 'anim@heists@box_carry@'
    local anim = 'idle'

    if active_prop then
        DeleteObject(active_prop)
        active_prop = nil
    end
    StopAnimTask(playerped, dict, anim, 1.0)
end

-- Convert input dialog to ox_lib
AddEventHandler('keep-oilwell:menu:show_transport_menu:ask_to_sell_amount', function()
    local input = lib.inputDialog('Enter number of Barrels', {
        {
            type = 'number',
            label = 'Amount',
            description = 'Enter the amount of barrels',
            required = true,
            min = 1
        }
    })

    if input then
        local amount = math.floor(tonumber(input[1]))
        
        if lib.progressBar({
            duration = Oilwell_config.Transport.duration * 1000,
            label = 'Filling',
            useWhileDead = false,
            canCancel = false,
            disable = {
                move = true,
                car = false,
                mouse = false,
                combat = true
            }
        }) then
            QBCore.Functions.TriggerCallback('keep-oilrig:server:oil_transport:fillTransportWell', function(res)
                -- Callback handling
            end, amount)
        end
    end
end)

-- Inventory checking functions remain the same
local inventory_max_size = Oilwell_config.inventory_max_size

local function isBarellInInventory()
    local items = QBCore.Functions.GetPlayerData().items
    for slot = 1, inventory_max_size, 1 do
        if items[slot] and items[slot].name == 'oilbarell' then
            return true
        end
    end
    return false
end

local already_started = false
function StartBarellAnimation()
    if already_started then return end
    already_started = true
    CreateThread(function()
        while true do
            local b = isBarellInInventory()
            if b then
                if not active_prop then
                    start_barell_animation()
                end
            else
                if active_prop then
                    end_barell_animaiton()
                end
            end
            Wait(1500)
        end
    end)
end
