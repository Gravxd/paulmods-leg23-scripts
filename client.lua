local spawnCodes = { "grav_16fpiu", "car_two" }

local function addTargetOptionToVehicle(model)
    exports.ox_target:addModel(
        model,
        {
            icon = "fa-solid fa-receipt",
            label = "Toggle Evidence On Hood",
            distance = 2,
            canInteract = function(entity, distance, coords, name, bone)
                if not DoesExtraExist(entity, 12) then
                    -- on this specific pack, extra 12 is the extra for evidence
                    return false
                end

                --[[

                    add your job check here, example below

                    local job = exports.framework:getJob()
                    if job ~= "police" then
                        return false
                    end

                --]]

                return true
            end,
            onSelect = function(data)
                local vehicle = data.entity

                local properties = lib.getVehicleProperties(vehicle)
                local newState = properties.extras[12] == 0 and 1 or 0
                properties.extras[12] = newState

                if NetworkGetEntityOwner(vehicle) == cache.playerId then
                    local toggled = lib.setVehicleProperties(vehicle, properties)
                    if toggled then
                        lib.notify(
                            {
                                type = "success",
                                description = "Evidence Toggled!",
                                position = "center-right",
                                duration = 5000
                            }
                        )
                    else
                        lib.notify(
                            {
                                type = "error",
                                description = "Failed to toggle evidence!",
                                position = "center-right",
                                duration = 5000
                            }
                        )
                    end
                else
                    -- vehicle is not owned by client, send request to server
                    lib.print.debug("Sending request to server to toggle evidence as i do not own the target vehicle.")
                    TriggerServerEvent("grav_leg23interact:toggleEvidence", VehToNet(vehicle), newState)
                end
            end
        }
    )
end

RegisterNetEvent("grav_leg23interact:toggleEvidence", function(netId, state)
    local entity = NetToVeh(netId)
    local properties = lib.getVehicleProperties(entity)
    properties.extras[12] = state
    lib.setVehicleProperties(entity, properties)
end)

CreateThread(function()
    for i = 1, #spawnCodes do
        local model = GetHashKey(spawnCodes[i])
        if not IsModelInCdimage(model) then
            -- not a valid spawncode
            lib.print.error(string.format("Invalid spawncode: %s", spawnCodes[i]))
            goto skipthismodel
        end

        addTargetOptionToVehicle(model)
        lib.print.debug(string.format("Added target option to vehicle: %s", spawnCodes[i]))

        ::skipthismodel::
    end
end)
