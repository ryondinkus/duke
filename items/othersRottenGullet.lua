local Names = {
    en_us = "ROTTEN GULLET",
    spa = "La Garganta del Duque"
}
local Name = Names.en_us
local Tag = "othersRottenGullet"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Spawns 2 Heart Spiders on use#Spiders can be one of six random types: {{Heart}}Red, {{SoulHeart}}Soul, {{BlackHeart}}Black, {{GoldenHeart}}Gold, {{EmptyBoneHeart}}Bone, or {{RottenHeart}}Rotten",
    spa = "Caca y mierda por todos lados"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "On use, spawns 2 Heart Spiders of a random type.",
        "- These can be one of six types: Red, Soul, Black, Gold, Bone, or Rotten",
        "- Red and Soul spiders are twice as likely to spawn than the other spider types",
        "This item has a different effect as Tainted Duke's pocket active. See Tainted Duke/Mechanics for an explanation on the different functionality."
    },
    {
        "Synergies",
        "Book of Virtues: Spawns 2 Heart Spider wisps of a random type. Heart Spider wisps will have tear effects based on whatever type they are. When a Heart Spider wisp dies, it will spawn a corresponding Heart Spider of the same type.",
        "Car Battery: Spawns 4 Heart Spiders"
    },
    {
        "Trivia",
        "Rotten Gullet is meant to be the rotted version of Duke’s Gullet.",
    }
})

local function MC_USE_ITEM(_, type, rng, p)
    DukeHelpers.sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0)
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, p.Position, Vector.Zero, nil)
    effect.Color = Color(0, 0, 0, 1)
    for _ = 1, 2 do
        local spiderToSpawn = DukeHelpers.GetWeightedSpider(rng)
        if p:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
            DukeHelpers.SpawnSpiderWisp(DukeHelpers.Wisps[spiderToSpawn.key], p.Position, p, nil, true)
        else
            DukeHelpers.SpawnSpidersFromKey(spiderToSpawn.key, p.Position, p, 1)
        end
    end
    return true
end

local function MC_FAMILIAR_INIT(_, familiar)
    if familiar.SubType == Id then
        familiar:Remove()
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
        },
        {
            ModCallbacks.MC_FAMILIAR_INIT,
            MC_FAMILIAR_INIT,
            FamiliarVariant.WISP
        }
    },
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.DELIRIUM, Tag, DukeHelpers.HUSK_NAME)
}
