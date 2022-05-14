dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
    if familiar.SubType == DukeHelpers.Items.thePrinces.Id then
        if familiar.FrameCount == 5 then
            local familiarData = familiar:GetData()
            if familiarData.heartType then
                local wisp = DukeHelpers.Wisps[familiarData.heartType]
                local sprite = familiar:GetSprite()
                sprite.Color = wisp.color
            end
        end
        if familiar:HasMortalDamage() then
            DukeHelpers.SpawnAttackFlyBySubType(familiar:GetData().heartType, familiar.Position, familiar.Player)
        end
    end
end, FamiliarVariant.WISP)

dukeMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
    if tear.FrameCount == 1 then
        local familiar = tear.SpawnerEntity:ToFamiliar()
        if familiar and familiar.SubType == DukeHelpers.Items.thePrinces.Id then
            local familiarData = familiar:GetData()
            local wisp = DukeHelpers.Wisps[familiarData.heartType]
            tear:AddTearFlags(wisp.tearFlags)
        end
    end
end, TearVariant.BLUE)
