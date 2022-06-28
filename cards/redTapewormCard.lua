local Names = {
    en_us = "Red Tapeworm Card",
    spa = "Tarjeta de Tenia Roja"
}
local Name = Names.en_us
local Tag = "redTapewormCard"
local Id = Isaac.GetCardIdByName(Name)
local Descriptions = {
    en_us = "Red go grrrr",
    spa = "Red go grrrr"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Red go grrrr.")

local function MC_USE_CARD(_, card, player, flags)
    DukeHelpers.GetDukeData(player)[Tag] = 1
end

local function MC_POST_PEFFECT_UPDATE(_, player)
    if DukeHelpers.GetDukeData(player)[Tag] then
        DukeHelpers.Stagger(Tag, player, 15, 10, function()
            DukeHelpers.Items.rottenGullet.helpers.fireRottenGulletShot(player,
                DukeHelpers.GetWeightedSpider(player:GetCardRNG(Id)).pickupSubType, player:GetCardRNG(Id))
            player:AnimateCard(Id)
        end)
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
        },
        {
            ModCallbacks.MC_POST_PEFFECT_UPDATE,
            MC_POST_PEFFECT_UPDATE
        }
    },
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.GREEDIER, Tag, DukeHelpers.HUSK_ID)
}
