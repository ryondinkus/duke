local Names = {
    en_us = "Tapeworm Card",
    spa = "Still on a plane, idfk what you want me to do"
}
local Name = Names.en_us
local Tag = "tapewormCard"
local Id = Isaac.GetCardIdByName(Name)
local Descriptions = {
    en_us = "Yummy in YOUR tummy",
    spa = "Still on a plane, idfk what you want me to do"
}
local WikiDescription = "Yummy in YOUR tummy."--helper.GenerateEncyclopediaPage("Poops and shits everywhere.")

local function MC_USE_CARD(_, type, rng, p)
    if DukeHelpers.IsDuke(p) then
        local fliesData = DukeHelpers.GetDukeData(p).heartFlies
        if fliesData and DukeHelpers.Find(fliesData, function(f) return DukeHelpers.GetFlyByHeartSubType(f.subType).canAttack end) then
            for i = #fliesData, 1, -1 do
                local fly = fliesData[i]
                local f = DukeHelpers.GetEntityByInitSeed(fly.initSeed)
                if DukeHelpers.GetFlyByHeartSubType(fly.subType).canAttack then
                    DukeHelpers.SpawnAttackFly(f)
                    DukeHelpers.RemoveHeartFly(f)
                end
            end
            DukeHelpers.sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0)
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, p.Position, Vector.Zero, nil)
            effect.Color = Color(0,0,0,1)
        else
            DukeHelpers.ForEachEntityInRoom(function(entity)
                if DukeHelpers.IsFlyOfPlayer(entity, p) then
                    DukeHelpers.AddHeartFly(p, DukeHelpers.GetFlyByAttackSubType(entity.SubType), 1)
                    entity:Remove()
                end
            end, EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY)
            DukeHelpers.sfx:Play(SoundEffect.SOUND_WORM_SPIT, 1, 0)
        end
        p:PlayExtraAnimation("DukeBarf")
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
    callbacks = {
        {
            ModCallbacks.MC_USE_CARD,
            MC_USE_CARD,
            Id
        }
    }
}
