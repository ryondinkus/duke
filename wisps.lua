dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
    if DukeHelpers.IsValidCustomWisp(familiar) then
        local familiarData = DukeHelpers.GetDukeData(familiar)
        if familiar.FrameCount == 5 then
            if familiarData.heartType and DukeHelpers.Wisps[familiarData.heartType] then
                local wisp = DukeHelpers.Wisps[familiarData.heartType]
                local sprite = familiar:GetSprite()
                sprite.Color = wisp.color
            else
                familiar:Remove()
            end
        end
        if familiar:HasMortalDamage() then
            if familiarData.spawnFlyOnDeath then
                DukeHelpers.SpawnAttackFlyBySubType(familiarData.heartType, familiar.Position, familiar.Player)
            end
            if familiarData.spawnSpiderOnDeath then
                DukeHelpers.SpawnSpidersFromPickupSubType(familiarData.heartType, familiar.Position, familiar.Player, 1)
            end
        end
        if familiarData.lifeTime then
            familiarData.lifeTime = familiarData.lifeTime - 1
            if familiarData.lifeTime <= 0 then
                familiar:Kill()
            end
        end
    end
end, FamiliarVariant.WISP)

dukeMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
    if tear.FrameCount == 1 and tear.SpawnerEntity then
        local familiar = tear.SpawnerEntity:ToFamiliar()
        if familiar and DukeHelpers.IsValidCustomWisp(familiar) then
            local familiarData = DukeHelpers.GetDukeData(familiar)
            local wisp = DukeHelpers.Wisps[familiarData.heartType]
            tear:AddTearFlags(wisp.tearFlags)
        end
    end
end, TearVariant.BLUE)
