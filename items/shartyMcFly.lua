local Names = {
    en_us = "Sharty McFly",
    spa = "Duque Pequeño"
}
local Name = Names.en_us
local Tag = "shartyMcFly"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Follows behind the player#The first time you shoot in a new room, Sharty McFly spawns a Love Poop, which attracts enemies and explodes after 5 seconds",
    spa = "Caca y mierda por todos lados"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "Sharty McFly will follow the player from behind.",
        "Once per room, when the player starts firing, Sharty McFly will spit out a Love Poop at his current position.",
        "- Love Poops are unique poop types that cannot be broken. Instead, it will slowly take damage on its own.",
        "- Love Poops draw enemies in to attack it, similar to the Rotten Tomato effect",
        "- When a Love Poop dies, it explodes into a pink fart, dealing 40 damage to nearby enemies."
    },
    {
        "Synergies",
        "BFFs! or Hive Mind: The Love Poop fart deals 80 damage",
        "- These effects do not stack with each other"
    },
    {
        "Sewing Machine",
        "Sewing Machine is a mod that allows the player to upgrade their familiars, giving them unique buffs that make them much more powerful.",
        "- Super Upgrade: Love Poop farts have doubled range.",
        "- Ultra Upgrade: Sharty McFly can spawn two Love Poops per room.",
    },
    {
        "Trivia",
        "Sharty McFly was a familiar idea that the mod creators had a long time ago to be included in some sort of familiar pack. After the familiar pack idea was scrapped, Sharty was brought over to the Duke mod due to his status as a fly.",
        "During early development, Duke's nickname was “sharty mcflies.” This nickname was soon repurposed to be used for Sharty.",
        "Sharty McFly's name is a reference to Marty McFly, protagonist of the Back to the Future films, very cleverly combined with the word ''shart,'' meaning to accidentally shit while farting."
    }
})

local function MC_EVALUATE_CACHE(_, player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
        local familiarAmount = player:GetCollectibleNum(Id) + player:GetEffects():GetCollectibleEffectNum(Id)
        local itemConfig = Isaac.GetItemConfig():GetCollectible(Id)

        local rng = RNG()
        rng:SetSeed(Random(), 1)

        player:CheckFamiliar(DukeHelpers.EntityVariants.shartyMcFly.Id, familiarAmount, rng, itemConfig)
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
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.GREEDIER, Tag, DukeHelpers.DUKE_NAME,
        DukeHelpers.Cards.tapewormCard.unlock)
}
