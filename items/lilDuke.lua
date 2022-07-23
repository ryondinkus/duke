local Names = {
    en_us = "Lil Duke",
    spa = "Duque Pequeño"
}
local Name = Names.en_us
local Tag = "lilDuke"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Orbits around the player, blocking bullets#After blocking a bullet, spawns 1-2 random Heart Attack Flies",
    spa = "Caca y mierda por todos lados"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "Lil Duke will orbit the player, blocking any bullets that collide with him.",
        "After blocking a bullet, Lil Duke will spawn 1 or 2 random Heart Attack Flies.",
        "- The Heart Attack Flies can be the following types: Red, Soul, Black, Gold, Bone, and Rotten. Red and Soul flies are twice as likely to spawn.",
    },
    {
        "Synergies",
        "BFFs!: Flies spawned will be 1.2x larger and deal double damage, essentially giving them the Hive Mind effect.",
        "- This effect does not stack with Hive Mind"
    },
    {
        "Sewing Machine",
        "Sewing Machine is a mod that allows the player to upgrade their familiars, giving them unique buffs that make them much more powerful.",
        "- Super Upgrade: Lil Duke will spawn 2 or 4 flies per hit.",
        "- Ultra Upgrade: Lil Duke will also spawn 1 or 2 random Heart Orbital Flies.",
    },
    {
        "Trivia",
        "Lil Duke was originally designed to have no arms or legs, but he looks much cuter with them.",
    }
})

local function MC_EVALUATE_CACHE(_, player, flag)
    if DukeHelpers.Items.lilDuke.IsUnlocked() then
        if flag == CacheFlag.CACHE_FAMILIARS then
            local familiarAmount = player:GetCollectibleNum(Id) + player:GetEffects():GetCollectibleEffectNum(Id)
            local itemConfig = Isaac.GetItemConfig():GetCollectible(Id)

            local rng = RNG()
            rng:SetSeed(Random(), 1)

            player:CheckFamiliar(DukeHelpers.EntityVariants.lilDuke.Id, familiarAmount, rng, itemConfig)
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
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.BOSS_RUSH, Tag, DukeHelpers.DUKE_NAME)
}
