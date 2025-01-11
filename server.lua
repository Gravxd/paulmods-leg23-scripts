RegisterNetEvent('grav_leg23interact:toggleEvidence', function(netId, state)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then return end

    local owner = NetworkGetEntityOwner(entity)
    TriggerClientEvent('grav_leg23interact:toggleEvidence', owner, netId, state)
end)