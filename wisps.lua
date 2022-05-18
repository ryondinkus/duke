dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
    if familiar.SubType == DukeHelpers.Items.thePrinces.Id then
        if familiar.FrameCount == 5 then
            local familiarData = familiar:GetData()
            if familiarData.heartType and DukeHelpers.Wisps[familiarData.heartType] then
                local wisp = DukeHelpers.Wisps[familiarData.heartType]
                local sprite = familiar:GetSprite()
                sprite.Color = wisp.color
            else
                familiar:Remove()
            end
        end
        if familiar:HasMortalDamage() and familiar:GetData().spawnFlyOnDeath then
            DukeHelpers.SpawnAttackFlyBySubType(familiar:GetData().heartType, familiar.Position, familiar.Player)
        end
        if familiar:GetData().lifeTime then
            local familiarData = familiar:GetData()
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
        if familiar and familiar.SubType == DukeHelpers.Items.thePrinces.Id then
            local familiarData = familiar:GetData()
            local wisp = DukeHelpers.Wisps[familiarData.heartType]
            tear:AddTearFlags(wisp.tearFlags)
        end
    end
end, TearVariant.BLUE)
