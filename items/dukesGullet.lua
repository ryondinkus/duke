local Names = {
    en_us = "Duke's Gullet",
    spa = "La Garganta del Duque"
}
local Name = Names.en_us
local Tag = "dukesGullet"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Poops and shits everywhere",
    spa = "Caca y mierda por todos lados"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Poops and shits everywhere.")

local function MC_USE_ITEM(_, type, rng, p, flags)
    if DukeHelpers.IsDuke(p) then
        local fliesData = DukeHelpers.GetDukeData(p).heartFlies
        if fliesData and
            DukeHelpers.Find(fliesData,
                function(f) return DukeHelpers.Flies[f.key].canAttack end) then
            for i = #fliesData, 1, -1 do
                local fly = fliesData[i]
                local f = DukeHelpers.GetEntityByInitSeed(fly.initSeed)
                if DukeHelpers.Flies[fly.key].canAttack then
                    DukeHelpers.SpawnAttackFlyFromHeartFlyEntity(f)
                    DukeHelpers.RemoveHeartFlyEntity(f)
                    if p:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
                        DukeHelpers.SpawnAttackFlyWisp(DukeHelpers.Wisps[fly.key], p.Position, p, 60)
                    end
                end
            end
            DukeHelpers.sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0)
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, p.Position, Vector.Zero, nil)
            effect.Color = Color(0, 0, 0, 1)
        else
            DukeHelpers.ForEachEntityInRoom(function(entity)
                local outerLayer = DukeHelpers.OUTER
                local outerLayerCount = 12
                if p:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                    outerLayer = DukeHelpers.BIRTHRIGHT
                    outerLayerCount = 18
                end
                if DukeHelpers.IsFlyOfPlayer(entity, p) and
                    DukeHelpers.CountByProperties(fliesData, { layer = outerLayer }) < outerLayerCount then
                    DukeHelpers.AddHeartFly(p, DukeHelpers.GetHeartFlyByAttackFlySubType(entity.SubType), 1)
                    entity:Remove()
                end
            end, EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY)
            DukeHelpers.sfx:Play(SoundEffect.SOUND_WORM_SPIT, 1, 0)
        end
        if (flags & UseFlag.USE_NOANIM == 0) then
            p:PlayExtraAnimation("DukeBarf")
        end
        return false
    end
end

return {
    Name = Name,
    Names = Names,
    Tag = Tag,
    Id = Id,
    Descriptions = Descriptions,
    WikiDescription = WikiDescription,
    Hide = true,
    callbacks = {
        {
            ModCallbacks.MC_USE_ITEM,
            MC_USE_ITEM,
            Id
        }
    }
}
