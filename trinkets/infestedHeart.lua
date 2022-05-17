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
    if player and player:HasTrinket(Id) then
        local canPickup = pickup.Variant == PickupVariant.PICKUP_HEART
        if pickup.SubType > HeartSubType.HEART_ROTTEN then
            return
        end
        if pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_HALF or pickup.SubType == HeartSubType.HEART_DOUBLEPACK or pickup.SubType == HeartSubType.HEART_SCARED then
            canPickup = player:CanPickRedHearts()
        elseif pickup.SubType == HeartSubType.HEART_SOUL or pickup.SubType == HeartSubType.HEART_HALF_SOUL then
            canPickup = player:CanPickSoulHearts()
        elseif pickup.SubType == HeartSubType.HEART_BLACK then
            canPickup = player:CanPickBlackHearts()
        elseif pickup.SubType == HeartSubType.HEART_BONE then
            canPickup = player:CanPickBoneHearts()
        elseif pickup.SubType == HeartSubType.HEART_ROTTEN then
            canPickup = player:CanPickRottenHearts()
        elseif pickup.SubType == HeartSubType.HEART_GOLDEN then
            canPickup = player:CanPickGoldenHearts()
        elseif pickup.SubType == HeartSubType.HEART_BLENDED then
            canPickup = player:CanPickRedHearts() or player:CanPickSoulHearts()
        end

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
    }
}
