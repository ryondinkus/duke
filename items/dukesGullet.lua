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
local WikiDescription = "Poops and shits everywhere."--helper.GenerateEncyclopediaPage("Poops and shits everywhere.")

local function MC_USE_ITEM(_, type, rng, p)
    if DukeHelpers.IsDuke(p) then
        local fliesData = p:GetData().heartFlies
        if fliesData and #fliesData > 0 then
            for i = #fliesData, 1, -1 do
                local fly = fliesData[i]
                local f = DukeHelpers.GetEntityByInitSeed(fly.initSeed)
                if DukeHelpers.GetFlyByHeartSubType(fly.subType).canAttack then
                    DukeHelpers.SpawnAttackFly(f)
                    DukeHelpers.RemoveHeartFly(f)
                end
            end
        else
            DukeHelpers.ForEachEntityInRoom(function(entity)
                if DukeHelpers.IsFlyOfPlayer(entity, p) then
                    DukeHelpers.AddHeartFly(p, DukeHelpers.GetFlyByAttackSubType(entity.SubType), 1)
                    entity:Remove()
                end
            end, EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY)
        end

        p:PlayExtraAnimation("DukeBarf")
        DukeHelpers.sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0)
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, p.Position, Vector.Zero, nil)
        effect.Color = Color(0,0,0,1)
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
            ModCallbacks.MC_USE_ITEM,
            MC_USE_ITEM,
            Id
        }
    }
}
