local Names = {
    en_us = "Pocket of Flies",
    spa = "Poqueto de Flieze"
}
local Name = Names.en_us
local Tag = "pocketOfFlies"
local Id = Isaac.GetTrinketIdByName(Name)
local Descriptions = {
    en_us = "Devil Deal prices will now cost Heart Orbital Flies instead of HP, with 4 flies per heart cost#As Duke, all Devil Deals now only cost 4 Heart Orbital Flies, similar to {{Trinket[56]}}Judas' Tongue",
    spa = "Nom Nom Nom"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "Devil Deal prices will now cost Heart Orbital Flies instead of HP.",
        "- 1 heart deals cost 4 flies, 2 heart deals cost 8 flies.",
        "- The type of Heart Orbital Fly does not matter to the cost.",
        "As Duke, all Devil Deals will now only cost 4 Heart Orbital Flies no matter what, similar to the effect of Judas' Tongue."
    },
    {
        "Trivia",
        "This trinket was added later in development, after the great purging of all co-op babies.",
    }
})

return {
    Name = Name,
    Names = Names,
    Tag = Tag,
    Id = Id,
    Descriptions = Descriptions,
    WikiDescription = WikiDescription,
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.BLUE_BABY, Tag, DukeHelpers.DUKE_NAME)
}
