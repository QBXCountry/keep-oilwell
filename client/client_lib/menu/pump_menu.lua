local QBCore = exports['qb-core']:GetCoreObject()

local function showInfo(data)
     QBCore.Functions.TriggerCallback('keep-oilwell:server:oilwell_metadata', function(selected_oilrig)
          local duration = math.floor(selected_oilrig.duration / 60)
          local partInfoString = string.format("Belt: %s Polish: %s Clutch: %s",
               selected_oilrig.part_info.belt,
               selected_oilrig.part_info.polish,
               selected_oilrig.part_info.clutch
          )

          lib.registerContext({
               id = 'oilwell_info',
               title = "Name: " .. data.name,
               options = {
                    {
                         title = 'Speed',
                         description = selected_oilrig.speed .. " RPM",
                         icon = 'gauge',
                         disabled = true
                    },
                    {
                         title = 'Duration',
                         description = duration .. " Min",
                         icon = 'clock',
                         disabled = true
                    },
                    {
                         title = 'Temperature',
                         description = selected_oilrig.temp .. " °C",
                         icon = 'temperature-high',
                         disabled = true
                    },
                    {
                         title = 'Oil Storage',
                         description = selected_oilrig.oil_storage .. "/Gal",
                         icon = 'oil-can',
                         disabled = true
                    },
                    {
                         title = 'Part Info',
                         description = partInfoString,
                         icon = 'oil-can',
                         disabled = true
                    },
                    {
                         title = 'Pump oil to storage',
                         icon = 'arrows-spin',
                         onSelect = function()
                              TriggerEvent('keep-oilrig:storage_menu:PumpOilToStorage', {
                                   oilrig_hash = data.oilrig_hash
                              })
                         end
                    },
                    {
                         title = 'Manage Employees',
                         icon = 'people-group',
                         onSelect = function()
                              TriggerEvent('keep-oilwell:menu:ManageEmployees', data.oilrig_hash)
                         end
                    }
               }
          })

          lib.showContext('oilwell_info')
     end, data.oilrig_hash)
end

RegisterNetEvent('keep-oilwell:menu:ManageEmployees', function(oilrig_hash)
     QBCore.Functions.TriggerCallback('keep-oilwell:server:employees_list', function(result)
          if not result then return end

          local options = {
               {
                    title = 'Add A New Employee',
                    icon = 'person-circle-plus',
                    onSelect = function()
                         TriggerEvent('keep-oilwell:client:add_employee', {
                              oilrig_hash = oilrig_hash,
                              state_id = 1
                         })
                    end
               }
          }

          for index, employee in ipairs(result) do
               local name = employee.charinfo.firstname .. ' ' .. employee.charinfo.lastname
               local gender = (employee.charinfo.gender == 0 and 'Male' or 'Female')
               local online = (employee.online and '🟢' or '🔴')

               options[#options + 1] = {
                    title = 'Employee #' .. index .. ' ' .. online,
                    description = string.format('Name: %s\nPhone: %s\nGender: %s',
                         name, employee.charinfo.phone, gender),
                    icon = 'person',
                    onSelect = function()
                         TriggerEvent('keep-oilwell:menu:remove_employee', {
                              employee = employee,
                              oilrig_hash = oilrig_hash
                         })
                    end
               }
          end

          lib.registerContext({
               id = 'manage_employees',
               title = 'Oilwell Employees',
               options = options
          })

          lib.showContext('manage_employees')
     end, oilrig_hash)
end)

RegisterNetEvent('keep-oilwell:client:add_employee', function(data)
     local input = lib.inputDialog('Enter Employee State Id', {
          {
               type = 'number',
               label = 'State ID',
               description = 'Enter state id',
               required = true
          }
     })

     if input then
          local stateId = tonumber(input[1])
          if stateId then
               TriggerServerEvent('keep-oilwell:server:add_employee', data.oilrig_hash, stateId)
          end
     end
end)

RegisterNetEvent('keep-oilwell:menu:remove_employee', function(data)
     local employee = data.employee
     local name = employee.charinfo.firstname .. ' ' .. employee.charinfo.lastname

     lib.registerContext({
          id = 'fire_employee',
          title = 'Fire Employee',
          menu = 'manage_employees',
          options = {
               {
                    title = 'Fire ' .. name,
                    description = 'Are you sure you want to fire this employee?',
                    icon = 'circle-check',
                    onSelect = function()
                         TriggerEvent('keep-oilwell:menu:fire_employee', {
                              employee = data.employee,
                              oilrig_hash = data.oilrig_hash
                         })
                    end
               }
          }
     })

     lib.showContext('fire_employee')
end)

RegisterNetEvent('keep-oilwell:menu:fire_employee', function(data)
     TriggerServerEvent('keep-oilwell:server:remove_employee', data.oilrig_hash, data.employee.citizenid)
end)

local function show_oilwell_stash(data)
     QBCore.Functions.TriggerCallback('keep-oilwell:server:oilwell_metadata', function(selected_oilrig)
          local partInfoString = string.format("Belt: %s Polish: %s Clutch: %s",
               selected_oilrig.part_info.belt,
               selected_oilrig.part_info.polish,
               selected_oilrig.part_info.clutch
          )

          lib.registerContext({
               id = 'oilwell_stash',
               title = "Name: " .. data.name,
               options = {
                    {
                         title = 'Part Info',
                         description = partInfoString,
                         icon = 'oil-can',
                         disabled = true
                    },
                    {
                         title = 'Open Stash',
                         icon = 'cart-flatbed',
                         onSelect = function()
                              TriggerEvent('keep-oilwell:client:openOilPump', {
                                   oilrig_hash = data.oilrig_hash
                              })
                         end
                    },
                    {
                         title = 'Fix Oilwell',
                         icon = 'screwdriver-wrench',
                         onSelect = function()
                              TriggerEvent('keep-oilwell:client:fix_oilwell', {
                                   oilrig_hash = data.oilrig_hash
                              })
                         end
                    }
               }
          })

          lib.showContext('oilwell_stash')
     end, data.oilrig_hash)
end

-- Events remain the same
AddEventHandler('keep-oilrig:storage_menu:PumpOilToStorage', function(data)
     QBCore.Functions.TriggerCallback('keep-oilrig:server:PumpOilToStorageCallback', function(result)
     end, data.oilrig_hash)
end)

AddEventHandler('keep-oilrig:client:viewPumpInfo', function(qbtarget)
     OilRigs:startUpdate(function()
          showInfo(OilRigs:getByEntityHandle(qbtarget.entity))
     end)
end)

AddEventHandler('keep-oilrig:client:show_oilwell_stash', function(qbtarget)
     OilRigs:startUpdate(function()
          show_oilwell_stash(OilRigs:getByEntityHandle(qbtarget.entity))
     end)
end)

RegisterNetEvent("keep-oilwell:client:openOilPump", function(data)
     if not data then return end
     TriggerServerEvent("inventory:server:OpenInventory", "stash", "oilPump_" .. data.oilrig_hash,
          { maxweight = 100000, slots = 5 })
     TriggerEvent("inventory:client:SetCurrentStash", "oilPump_" .. data.oilrig_hash)
end)

AddEventHandler('keep-oilwell:client:fix_oilwell', function(data)
     QBCore.Functions.TriggerCallback('keep-oilwell:server:fix_oil_well', function(result)
          print(result)
     end, data.oilrig_hash)
end)
