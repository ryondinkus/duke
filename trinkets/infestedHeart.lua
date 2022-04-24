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

local function RandomlySpawnHeartFlyFromPickup(player, pickup)
    if player and player:HasTrinket(Id) then
        local canPickup = true

        if pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_HALF then
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
        end

        if canPickup and DukeHelpers.PercentageChance(50, 100) then
            local heartSubType = DukeHelpers.GetFlyByPickupSubType(pickup.SubType)
            if pickup.SubType == HeartSubType.HEART_BLENDED then
                if DukeHelpers.PercentageChance(50, 100) then
                    heartSubType = HeartSubType.HEART_FULL
                else
                    heartSubType = HeartSubType.HEART_SOUL
                end
            end
            if DukeHelpers.IsDuke(player) then
                if pickup.SubType == HeartSubType.HEART_BLENDED then
                    if DukeHelpers.PercentageChance(50, 100) then
                        heartSubType = HeartSubType.HEART_FULL
                    else
                        heartSubType = HeartSubType.HEART_SOUL
                    end
                end

                if type(heartSubType) == "number" then
                    DukeHelpers.AddHeartFly(player, DukeHelpers.GetFlyByHeartSubType(heartSubType), 1)
                end
                return true
            else
                if type(heartSubType) ~= "number" then
                    heartSubType = heartSubType.heartFlySubType
                end
                DukeHelpers.SpawnPickupHeartFly(player, pickup)
            end
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
            MC_PRE_PICKUP_COLLISION
        }
    },
    helpers = {
        RandomlySpawnHeartFlyFromPickup = RandomlySpawnHeartFlyFromPickup
    }
}
