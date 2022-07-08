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
    if player and player:HasTrinket(Id) and pickup.Variant == PickupVariant.PICKUP_HEART then
        local canPickup = DukeHelpers.CanPickUpHeart(player, pickup)

        if (DukeHelpers.IsDuke(player) or canPickup) and ShouldSpawnExtraFly(player) then
            if DukeHelpers.IsDuke(player) then
                return true
            end
            DukeHelpers.SpawnPickupHeartFly(player, pickup)

            return true
        end
    end
end

local function MC_PRE_PICKUP_COLLISION(_, pickup, collider)
    if not DukeHelpers.IsDuke(collider:ToPlayer()) then
        return RandomlySpawnHeartFlyFromPickup(collider:ToPlayer(), pickup)
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
            ModCallbacks.MC_PRE_PICKUP_COLLISION,
            MC_PRE_PICKUP_COLLISION,
            PickupVariant.PICKUP_HEART
        }
    },
    helpers = {
        RandomlySpawnHeartFlyFromPickup = RandomlySpawnHeartFlyFromPickup,
        ShouldSpawnExtraFly = ShouldSpawnExtraFly
    },
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.SATAN, Tag, DukeHelpers.DUKE_NAME)
}
