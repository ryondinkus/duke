local Names = {
    en_us = "Hollow Heart",
    spa = "Corazon Vacio"
}
local Name = Names.en_us
local Tag = "hollowHeart"
local Id = Isaac.GetTrinketIdByName(Name)
local Descriptions = {
    en_us = "ECHO Echo echo",
    spa = "ECO Eco eco"
}
local WikiDescription = "ECHO Echo echo"--helper.GenerateEncyclopediaPage("Poops and shits everywhere.")

local function RandomlySpawnHeartFlyFromPickup(player, pickup)
    if player and player:HasTrinket(Id) then
        local chance = DukeHelpers.PercentageChance(50, 100)
        if chance then
            if DukeHelpers.IsDuke(player) then
                DukeHelpers.AddHeartFly(player, DukeHelpers.GetFlyByPickupSubType(pickup.SubType), 1)
            else
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
