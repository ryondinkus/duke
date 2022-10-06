local Names = {
    en_us = "Infested Heart",
    spa = "Corazon Infestado"
}
local Name = Names.en_us
local Tag = "infestedHeart"
local Id = Isaac.GetTrinketIdByName(Name)
local Descriptions = {
    en_us = "Hearts picked up have a 50% chance of becoming Heart Orbital Flies#As Duke, hearts picked up have a 50% chance of granting an extra Heart Orbital Fly",
    spa = "Esta zumbando..."
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "Hearts you pick up have a 50% chance of being converted into Heart Orbital Flies.",
        "- The effect will not occur if the heart cannot be picked up.",
        "As Duke, hearts picked up have a 50% chance of granting an extra Heart Orbital Fly of the same type."
    },
    {
        "Trivia",
        "This trinket was originally going to be called “Hollow Heart,” but then we remembered there was already a trinket in the game with that exact name.",
    }
})

local function ShouldSpawnExtraFly(player)
    return player:HasTrinket(Id) and DukeHelpers.PercentageChance(50)
end

local function RandomlySpawnHeartFlyFromPickup(player, pickup, customAmount)
    if player and DukeHelpers.IsSupportedHeart(pickup) and ShouldSpawnExtraFly(player) then
        if (DukeHelpers.CanPickUpHeart(player, pickup) or DukeHelpers.IsDuke(player) or DukeHelpers.IsHusk(player)) then
            DukeHelpers.SpawnPickupHeartFly(player, pickup, nil, customAmount)
        end

        return true
    end
end

local function MC_POST_PLAYER_UPDATE(_, player)
    if DukeHelpers.Trinkets.infestedHeart.IsUnlocked() then
        local dukeData = DukeHelpers.GetDukeData(player)

        local updatedHearts = dukeData.health

        if not dukeData.previousHealth or not player:HasTrinket(Id) or DukeHelpers.IsDuke(player) or
            DukeHelpers.IsHusk(player) then
            return
        end

        for heartKey, amount in pairs(updatedHearts) do
            if amount > dukeData.previousHealth[heartKey] then
                local heart = DukeHelpers.Hearts[heartKey]
                local fakePickup = { Type = EntityType.ENTITY_PICKUP, Variant = heart.variant, SubType = heart.subType,
                    Price = 0 }
                local removableAmount = amount - dukeData.previousHealth[heartKey]
                local customAmount

                if DukeHelpers.Hearts.WEB.IsHeart(fakePickup) then
                    customAmount = removableAmount / 2
                end
                if RandomlySpawnHeartFlyFromPickup(player, fakePickup, customAmount) then
                    heart.Remove(player, removableAmount)
                end
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
