local Names = {
    en_us = "Soul of Duke",
    spa = "Alma de Duque"
}
local Name = Names.en_us
local Tag = "soulOfDuke"
local Id = Isaac.GetCardIdByName(Name)
local Descriptions = {
    en_us = "Spawns 10 Heart Orbital Flies and 10 Heart Spiders of random types#Flies can be one of six random types: {{Heart}}Red, {{SoulHeart}}Soul, {{BlackHeart}}Black, {{GoldenHeart}}Gold, {{EmptyBoneHeart}}Bone, or {{RottenHeart}}Rotten",
    spa = "Ghosty"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "On use, spawns 10 Heart Orbital Flies and 10 Heart Spiders of random types. These types can be Red, Soul, Black, Golden, Bone, or Rotten, with Red and Blue being twice as likely to spawn."
    }
})

local function MC_USE_CARD(_, card, player, flags)
    for _ = 1, 10 do
        DukeHelpers.AddHeartFly(player, DukeHelpers.GetWeightedFly(DukeHelpers.rng), 1)
        DukeHelpers.SpawnSpidersFromKey(DukeHelpers.GetWeightedSpider(DukeHelpers.rng).key,
            player.Position, player, 1)
    end
    DukeHelpers.sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0)
    DukeHelpers.sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE, 1, 0)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, player.Position, Vector.Zero, player)
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 3, player.Position, Vector.Zero, player)
    effect.Color = Color(0, 0, 0, 1)
    Game():ShakeScreen(10)
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
    },
    unlock = DukeHelpers.GetUnlock({
        DukeHelpers.Unlocks.BOSS_RUSH,
        DukeHelpers.Unlocks.HUSH
    }, Tag, DukeHelpers.HUSK_NAME)
}
