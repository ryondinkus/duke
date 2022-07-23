local Names = {
    en_us = "DUKE'S GULLET",
    spa = "La Garganta del Duque"
}
local Name = Names.en_us
local Tag = "othersGullet"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Spawns 2 Heart Attack Flies on use#Flies can be one of six random types: {{Heart}}Red, {{SoulHeart}}Soul, {{BlackHeart}}Black, {{GoldenHeart}}Gold, {{EmptyBoneHeart}}Bone, or {{RottenHeart}}Rotten",
    spa = "Caca y mierda por todos lados"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "On use, spawns 2 Heart Attack Flies of a random type.",
        "- These can be one of six types: Red, Soul, Black, Gold, Bone, or Rotten",
        "- Red and Soul flies are twice as likely to spawn than the other fly types",
        "This item has a different effect as Duke's pocket active. See Duke/Mechanics for an explanation on the different functionality."
    },
    {
        "Synergies",
        "Book of Virtues: Spawns 2 Heart Fly wisps of a random type. Heart Fly wisps will have tear effects based on whatever type they are. When a Heart Fly wisp dies, it will spawn a corresponding Heart Attack Fly of the same type.",
        "Car Battery: Spawns 4 Heart Attack Flies"
    },
    {
        "Trivia",
        "Duke's Gullet was originally unlocked by defeating ???, but was moved to Mom's Heart after co-op babies were scrapped.",
        "- The scrapped co-op baby for Mom's Heart would've been called Duke Baby, and would've fired Heart Attack Flies instead of tears."
    }
})

local function MC_USE_ITEM(_, type, rng, p)
    if DukeHelpers.Items.othersGullet.IsUnlocked() then
        DukeHelpers.sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0)
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, p.Position, Vector.Zero, nil)
        effect.Color = Color(0, 0, 0, 1)
        for _ = 1, 2 do
            local flyToSpawn = DukeHelpers.GetWeightedFly(rng)
            if p:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
                DukeHelpers.SpawnAttackFlyWisp(DukeHelpers.Wisps[flyToSpawn.key], p.Position, p, nil, true)
            else
                DukeHelpers.SpawnAttackFlyFromHeartFly(flyToSpawn, p.Position, p)
            end
        end
        return true
    end
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
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.MOMS_HEART, Tag, DukeHelpers.DUKE_NAME)
}
