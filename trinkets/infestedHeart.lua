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
    return player:HasTrinket(Id) and DukeHelpers.PercentageChance(100)
end

local function RandomlySpawnHeartFlyFromPickup(player, pickup)
    if player and DukeHelpers.IsSupportedHeart(pickup) and ShouldSpawnExtraFly(player) then
        if DukeHelpers.CanPickUpHeart(player, pickup) then
            DukeHelpers.SpawnPickupHeartFly(player, pickup)

            if DukeHelpers.IsWebHeart(pickup) then
                addWebHearts(-1, player)
            elseif DukeHelpers.IsDoubleWebHeart(pickup) then
                addWebHearts(-2, player)
            end
        end

        return true
    end
end

local function MC_PRE_PICKUP_COLLISION(_, pickup, collider)
    if not DukeHelpers.IsDuke(collider:ToPlayer()) then
        RandomlySpawnHeartFlyFromPickup(collider:ToPlayer(), pickup)
    end
end

local callbacks = {}

DukeHelpers.ForEachHeartVariant(function(variant)
    table.insert(callbacks, {
        ModCallbacks.MC_PRE_PICKUP_COLLISION,
        MC_PRE_PICKUP_COLLISION,
        variant
    })
end)

return {
    Name = Name,
    Names = Names,
    Tag = Tag,
    Id = Id,
    Descriptions = Descriptions,
    WikiDescription = WikiDescription,
    callbacks = callbacks,
    helpers = {
        RandomlySpawnHeartFlyFromPickup = RandomlySpawnHeartFlyFromPickup,
        ShouldSpawnExtraFly = ShouldSpawnExtraFly
    },
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.SATAN, Tag, DukeHelpers.DUKE_NAME)
}
