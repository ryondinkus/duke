local Names = {
    en_us = "The Invader",
    spa = "El Invador"
}
local Name = Names.en_us
local Tag = "theInvader"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Poops and shits everywhere",
    spa = "Caca y mierda por todos lados"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Poops and shits everywhere.")

local function MC_EVALUATE_CACHE(_, player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
        local familiarAmount = player:GetCollectibleNum(Id) + player:GetEffects():GetCollectibleEffectNum(Id)
        local itemConfig = Isaac.GetItemConfig():GetCollectible(Id)
        player:CheckFamiliar(DukeHelpers.EntityVariants.theInvader.Id, familiarAmount, RNG(),
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
    }
}
