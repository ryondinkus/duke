local Names = {
    en_us = "The Invader",
    spa = "El Invador"
}
local Name = Names.en_us
local Tag = "theInvader"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Hops around in short bursts, targeting nearby enemies#On collision with an enemy, enters them and permacharms them#When the permacharmed enemy dies, The Invader will fall to the ground and target a new enemy",
    spa = "Caca y mierda por todos lados"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "The Invader will hop around the room in short bursts, targeting nearby enemies.",
        "When The Invader collides with an enemy, he will enter them, permacharming them.",
        "When the permacharmed enemy dies, The Invader will fall to the ground and target a new enemy.",
    },
    {
        "Synergies",
        "BFFs! or Hive Mind: Possessed enemies will have 2x health.",
        "- These effects do not stack with each other.",
        "Forgotten Lullaby: The Invader hops around the room at a faster rate."
    },
    {
        "Sewing Machine",
        "Sewing Machine is a mod that allows the player to upgrade their familiars, giving them unique buffs that make them much more powerful.",
        "- Super Upgrade: Possessed enemies will turn into random champions when possessed.",
        "- Ultra Upgrade: Possessed enemies explode on death. This explosion does not hurt the player.",
    },
    {
        "Trivia",
        "The Invader was originally unlocked for beating Mother as Tainted Duke, but was displaced once Duke of Eyes was swapped to an all-completion mark reward."
    }
})

local function MC_EVALUATE_CACHE(_, player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
        local familiarAmount = player:GetCollectibleNum(Id) + player:GetEffects():GetCollectibleEffectNum(Id)
        local itemConfig = Isaac.GetItemConfig():GetCollectible(Id)

        local rng = RNG()
        rng:SetSeed(Random(), 1)

        player:CheckFamiliar(DukeHelpers.EntityVariants.theInvader.Id, familiarAmount, rng,
            itemConfig)
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
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.BEAST, Tag, DukeHelpers.HUSK_NAME)
}
