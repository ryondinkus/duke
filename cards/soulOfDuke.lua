local Names = {
    en_us = "Soul of Duke",
    spa = "Alma de Duque"
}
local Name = Names.en_us
local Tag = "soulOfDuke"
local Id = Isaac.GetCardIdByName(Name)
local Descriptions = {
    en_us = "Ghosty",
    spa = "Ghosty"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Ghosty")

local function MC_USE_CARD(_, card, player, flags)
    for _ = 1, 10 do
        DukeHelpers.AddHeartFly(player, DukeHelpers.GetWeightedFly(DukeHelpers.rng), 1)
        DukeHelpers.SpawnSpidersFromPickupSubType(DukeHelpers.GetWeightedSpider(DukeHelpers.rng).pickupSubType,
            player.Position, player, 1)
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
            ModCallbacks.MC_USE_CARD,
            MC_USE_CARD,
            Id
        }
    }
}
