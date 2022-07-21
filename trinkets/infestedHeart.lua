local Names = {
    en_us = "Infested Heart",
    spa = "Corazon Infestado"
}
local Name = Names.en_us
local Tag = "infestedHeart"
local Id = Isaac.GetTrinketIdByName(Name)
local Descriptions = {
    en_us = "It's buzzing...",
    spa = "Esta zumbando..."
}
local WikiDescription = "It's buzzing..." --helper.GenerateEncyclopediaPage("Poops and shits everywhere.")

local function ShouldSpawnExtraFly(player)
    return player:HasTrinket(Id) and DukeHelpers.PercentageChance(50)
end

local function RandomlySpawnHeartFlyFromPickup(player, pickup)
    if player and DukeHelpers.IsSupportedHeart(pickup) and ShouldSpawnExtraFly(player) then
        if (DukeHelpers.CanPickUpHeart(player, pickup) or DukeHelpers.IsDuke(player) or DukeHelpers.IsHusk(player)) then
            DukeHelpers.SpawnPickupHeartFly(player, pickup)
        end

        return true
    end
end

local function MC_POST_PLAYER_UPDATE(_, player)
    local dukeData = DukeHelpers.GetDukeData(player)

    local updatedHearts = dukeData.health

    if not dukeData.previousHealth or not player:HasTrinket(Id) or DukeHelpers.IsDuke(player) then
        return
    end

    for heartKey, amount in pairs(updatedHearts) do
        if amount > dukeData.previousHealth[heartKey] then
            local heart = DukeHelpers.Hearts[heartKey]
            if RandomlySpawnHeartFlyFromPickup(player,
                { Type = EntityType.ENTITY_PICKUP, Variant = heart.variant, SubType = heart.subType, Price = 0 }) then
                heart.Remove(player, amount - dukeData.previousHealth[heartKey])
            end
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
            ModCallbacks.MC_POST_PLAYER_UPDATE,
            MC_POST_PLAYER_UPDATE
        }
    },
    helpers = {
        RandomlySpawnHeartFlyFromPickup = RandomlySpawnHeartFlyFromPickup,
        ShouldSpawnExtraFly = ShouldSpawnExtraFly
    },
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.SATAN, Tag, DukeHelpers.DUKE_NAME)
}
