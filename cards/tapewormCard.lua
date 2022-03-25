local Names = {
    en_us = "Tapeworm Card",
    spa = "Tarjeta de Tenia"
}
local Name = Names.en_us
local Tag = "tapewormCard"
local Id = Isaac.GetCardIdByName(Name)
local Descriptions = {
    en_us = "Yummy in YOUR tummy",
    spa = "Delicioso en TU barriga"
}
local WikiDescription = "Yummy in YOUR tummy."--helper.GenerateEncyclopediaPage("Poops and shits everywhere.")

local function MC_USE_CARD(_, card, player, flags)
    local enemies = DukeHelpers.ListEnemiesInRoom(true, function(entity) return not EntityRef(entity).IsCharmed end)

    for _, enemy in pairs(enemies) do
        DukeHelpers.AddHeartFly(player, DukeHelpers.GetWeightedFly(), 1)
        enemy:Remove()
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
