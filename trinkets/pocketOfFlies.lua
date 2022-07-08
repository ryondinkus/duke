local Names = {
    en_us = "Pocket of Flies",
    spa = "Poqueto de Flieze"
}
local Name = Names.en_us
local Tag = "pocketOfFlies"
local Id = Isaac.GetTrinketIdByName(Name)
local Descriptions = {
    en_us = "Nom Nom Nom",
    spa = "Nom Nom Nom"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Nom Nom Nom")

return {
    Name = Name,
    Names = Names,
    Tag = Tag,
    Id = Id,
    Descriptions = Descriptions,
    WikiDescription = WikiDescription,
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.BLUE_BABY, Tag, DukeHelpers.DUKE_NAME)
}
