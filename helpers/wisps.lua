function DukeHelpers.SpawnWisp(wisp, pos, spawner, spawnTag, lifeTime, customId)
    local player = spawner:ToPlayer()
    if player then
        local wispEntity = spawner:ToPlayer():AddWisp(customId, pos)

        if wispEntity then
            local wispData = DukeHelpers.GetDukeData(wispEntity)
            wispData.heartKey = wisp.key
            if spawnTag then
                wispData[spawnTag] = true
            end
            wispData.lifeTime = lifeTime
            return wispEntity
        end
    end
end

function DukeHelpers.IsValidCustomWisp(familiar)
    if (familiar.Variant == FamiliarVariant.WISP) then
        if (familiar.SubType == DukeHelpers.Items.dukeOfEyes.Id) or
            (familiar.SubType == DukeHelpers.Items.thePrinces.Id
            ) then
            return true
        end
    end
    return false
end
