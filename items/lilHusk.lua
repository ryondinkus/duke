local Names = {
    en_us = "Lil Husk",
    spa = "Husque Pequeño"
}
local Name = Names.en_us
local Tag = "lilHusk"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Follows the player from behind#When the player fires tears, spawns a random Heart Spider, similar to {{Collectible[268]}}Rotten Baby",
    spa = "Caca y mierda por todos lados"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "Lil Husk will follow the player from behind.",
        "When the player fires tears, Lil Husk will spawn a random Heart Spider.",
        "- Heart Spiders can be one of six types: Red, Soul, Black, Gold, Bone, and Rotten. Red and Soul are twice as likely to spawn.",
        "Lil Husk cannot fire more spiders until the one he fired previously has died, similar to Rotten Baby."
    },
    {
        "Interactions",
        "Forgotten Lullaby: Increases the spawn rate of spiders, but this can rarely be seen since Lil Husk waits until his first spider dies to spawn another"
    },
    {
        "Synergies",
        "BFFs!: Spiders spawned will be 1.2x larger and deal double damage, essentially giving them the Hive Mind effect.",
        "- This effect does not stack with Hive Mind"
    },
    {
        "Sewing Machine",
        "Sewing Machine is a mod that allows the player to upgrade their familiars, giving them unique buffs that make them much more powerful.",
        "- Super Upgrade: Lil Husk can have two spiders active at a time instead of one.",
        "- Ultra Upgrade: Lil Husk will spawn a corresponding Heart Attack Fly for every Heart Spider spawned. The Heart Attack Flies do not affect when Lil Husk is able to spawn more Heart Spiders.",
    },
    {
        "Trivia",
        "Lil Husk was originally designed to be a co-op baby unlocked for beating Mega Satan as Duke, but was turned into a familiar when the existence of co-op babies was scrapped.",
        "Lil Husk might be the posthumous version of Lil Duke, or they might just be two different beings who are friends. Please choose whichever option you prefer."
    }
})

local function MC_EVALUATE_CACHE(_, player, flag)
    if DukeHelpers.Items.lilHusk.IsUnlocked() then
        if flag == CacheFlag.CACHE_FAMILIARS then
            local familiarAmount = player:GetCollectibleNum(Id) + player:GetEffects():GetCollectibleEffectNum(Id)
            local itemConfig = Isaac.GetItemConfig():GetCollectible(Id)

            local rng = RNG()
            rng:SetSeed(Random(), 1)

            player:CheckFamiliar(DukeHelpers.EntityVariants.lilHusk.Id, familiarAmount, rng, itemConfig)
        end
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
            ModCallbacks.MC_EVALUATE_CACHE,
            MC_EVALUATE_CACHE
        }
    },
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.MOTHER, Tag, DukeHelpers.HUSK_NAME)
}
