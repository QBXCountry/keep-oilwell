local QBCore = exports['qb-core']:GetCoreObject()
local debugPoly = true

Targets = {}
Targets.ox_target = {}

function Targets.ox_target.storage(coords, name)
    local tmp_coord = vector3(coords.x, coords.y, coords.z + 2)

    exports.ox_target:addSphereZone({
        coords = tmp_coord,
        radius = 1,
        debug = debugPoly,
        options = {
            {
                event = "keep-oilrig:storage_menu:ShowStorage",
                icon = "fa-solid fa-arrows-spin",
                label = "View Storage",
                canInteract = function(entity)
                    if not CheckJob() then return false end
                    if not CheckOnduty() then
                        QBCore.Functions.Notify('You must be on duty!', "error")
                        Wait(2000)
                        return false
                    end
                    return true
                end,
            }
        }
    })
end

function Targets.ox_target.distillation(coords, name)
    local tmp_coord = vector3(coords.x, coords.y, coords.z + 1.1)

    exports.ox_target:addSphereZone({
        coords = tmp_coord,
        radius = 1.2,
        debug = debugPoly,
        options = {
            {
                event = "keep-oilrig:CDU_menu:ShowCDU",
                icon = "fa-solid fa-gear",
                label = "Open CDU panel",
                distance = 1.5,
                canInteract = function(entity)
                    if not CheckJob() then return false end
                    if not CheckOnduty() then
                        QBCore.Functions.Notify('You must be on duty!', "error")
                        Wait(2000)
                        return false
                    end
                    return true
                end,
            }
        }
    })
end

function Targets.ox_target.toggle_job(coords, name)
    local tmp_coord = vector3(coords.x, coords.y, coords.z + 1.1)

    exports.ox_target:addSphereZone({
        coords = tmp_coord,
        radius = 0.75,
        debug = debugPoly,
        options = {
            {
                event = "keep-oilrig:client:goOnDuty",
                icon = "fa-solid fa-boxes-packing",
                label = "Toggle Duty",
                distance = 2.5,
                canInteract = function(entity)
                    return CheckJob()
                end,
            }
        }
    })
end

function Targets.ox_target.barrel_withdraw(coords, name)
    local tmp_coord = vector3(coords.x, coords.y, coords.z + 1.1)

    exports.ox_target:addSphereZone({
        coords = tmp_coord,
        radius = 1.0,
        debug = debugPoly,
        options = {
            {
                event = "keep-oilrig:client_lib:withdraw_from_queue",
                icon = "fa-solid fa-boxes-packing",
                label = "Transfer withdraw to stash",
                distance = 2.5,
                truck = false,
                canInteract = function(entity)
                    if not CheckJob() then return false end
                    if not CheckOnduty() then
                        QBCore.Functions.Notify('You must be on duty!', "error")
                        Wait(2000)
                        return false
                    end
                    return true
                end,
            },
            {
                event = "keep-oilwell:client:openWithdrawStash",
                icon = "fa-solid fa-boxes-packing",
                label = "Open Withdraw Stash",
                canInteract = function(entity)
                    if not CheckJob() then return false end
                    if not CheckOnduty() then
                        QBCore.Functions.Notify('You must be on duty!', "error")
                        Wait(2000)
                        return false
                    end
                    return true
                end,
            },
            {
                event = "keep-oilwell:client:open_purge_menu",
                icon = "fa-solid fa-trash-can",
                label = "Purge Withdraw Stash",
                canInteract = function(entity)
                    if not CheckJob() then return false end
                    if not CheckOnduty() then
                        QBCore.Functions.Notify('You must be on duty!', "error")
                        Wait(2000)
                        return false
                    end
                    return true
                end,
            }
        }
    })
end

function Targets.ox_target.blender(coords, name)
    local tmp_coord = vector3(coords.x, coords.y, coords.z + 2.5)

    exports.ox_target:addSphereZone({
        coords = tmp_coord,
        radius = 3.5,
        debug = debugPoly,
        options = {
            {
                event = "keep-oilrig:blender_menu:ShowBlender",
                icon = "fa-solid fa-gear",
                label = "Open blender panel",
                distance = 2.5,
                canInteract = function(entity)
                    if not CheckJob() then return false end
                    if not CheckOnduty() then
                        QBCore.Functions.Notify('You must be on duty!', "error")
                        Wait(2000)
                        return false
                    end
                    return true
                end,
            }
        }
    })
end

function Targets.ox_target.crude_oil_transport(coords, name)
    local tmp_coord = vector3(coords.x, coords.y, coords.z + 2.5)

    exports.ox_target:addSphereZone({
        coords = tmp_coord,
        radius = 2.0,
        debug = debugPoly,
        options = {
            {
                event = "keep-oilwell:menu:show_transport_menu",
                icon = "fa-solid fa-boxes-packing",
                label = "Fill transport well",
                distance = 2.5,
                canInteract = function(entity)
                    if not CheckJob() then return false end
                    if not CheckOnduty() then
                        QBCore.Functions.Notify('You must be on duty!', "error")
                        Wait(2000)
                        return false
                    end
                    return true
                end,
            }
        }
    })
end

function Targets.ox_target.oilwell(coords, name)
    local coord = vector3(coords.x, coords.y, coords.z + 2.5)

    exports.ox_target:addSphereZone({
        coords = coord,
        radius = 3.5,
        debug = debugPoly,
        options = {
            {
                event = "keep-oilrig:client:viewPumpInfo",
                icon = "fa-solid fa-info",
                label = "View Pump Info",
                canInteract = function(entity)
                    return true
                end,
            },
            {
                event = "keep-oilrig:client:changeRigSpeed",
                icon = "fa-solid fa-gauge-high",
                label = "Modifiy Pump Settings",
                canInteract = function(entity)
                    if not CheckJob() then return false end
                    if not CheckOnduty() then return false end
                    return isOwner(entity)
                end,
            },
            {
                event = "keep-oilrig:client:show_oilwell_stash",
                icon = "fa-solid fa-gears",
                label = "Manange Parts",
                canInteract = function(entity)
                    if not CheckJob() then return false end
                    if not CheckOnduty() then return false end
                    return isOwner(entity)
                end,
            },
            {
                event = "keep-oilwell:client:remove_oilwell",
                icon = "fa-regular fa-file-lines",
                label = "Remove Oilwell",
                canInteract = function(entity)
                    if not CheckJob() then return false end
                    if not (PlayerJob.grade.level == 4) then return false end
                    if not CheckOnduty() then return false end
                    return true
                end,
            }
        }
    })
end

function Targets.ox_target.truck(plate, truck)
    exports.ox_target:addEntityZone({
        name = "device-" .. plate,
        entity = truck,
        debug = debugPoly,
        options = {
            {
                event = "keep-oilwell:client:refund_truck",
                icon = "fa-solid fa-location-arrow",
                label = "refund Truck",
                distance = 2.5,
                vehiclePlate = plate
            }
        }
    })
end
