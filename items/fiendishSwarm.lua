local Names = {
    en_us = "Fiendish Swarm",
    spa = "Enjambre Diabólico"
}
local Name = Names.en_us
local Tag = "fiendishSwarm"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Ryan has infested my fucking life",
    spa = "Ryan ha infestado mi puta vida"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Ryan has infested my fucking life.")

local function MC_USE_ITEM(_, type, rng, player, f)
    local dukeData = DukeHelpers.GetDukeData(player)
end

local function MC_USE_ITEM(_, type, rng, player, f)
    local dukeData = DukeHelpers.GetDukeData(player)
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
