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

local function MC_PRE_PICKUP_COLLISION(_, pickup, collider)
    local player = collider:ToPlayer()
    if player and not DukeHelpers.IsDuke(player) and not DukeHelpers.IsHusk(player) and
        DukeHelpers.Trinkets.infestedHeart.IsUnlocked() and player:HasTrinket(Id) and
        DukeHelpers.IsSupportedHeart(pickup) then
        local heartKey = DukeHelpers.GetKeyFromPickup(pickup)
        local heart = DukeHelpers.Hearts[heartKey]
        local fly = DukeHelpers.Flies[heartKey]

        if not fly then
            return
        end

        if DukeHelpers.CanPickUpHeart(player, pickup) and
            RandomlySpawnHeartFlyFromPickup(player, DukeHelpers.MakeFakePickup(pickup), fly.count) then
            if heart.OnPickup then
                heart.OnPickup(player)
            end
            pickup:Remove()
            if not heart.ignore then
                return false
            else
                DukeHelpers.GetDukeData(player)[Tag] = DukeHelpers.MakeFakePickup(pickup)
            end
        end
    end
end

local function MC_POST_PLAYER_UPDATE(_, player)
    local data = DukeHelpers.GetDukeData(player)
    if data[Tag] and data.health and data.previousHealth then
        local heartKey = DukeHelpers.GetKeyFromPickup(data[Tag])
        local heart = DukeHelpers.Hearts[heartKey]
        local baseHeartKey = DukeHelpers.GetBaseHeartKey(heart)
        local heartsToRemove = math.max(data.health[baseHeartKey] - data.previousHealth[baseHeartKey], 0)

        if heart then
            if heart.Remove then
                heart.Remove(player, heartsToRemove)
            elseif heart.ignore then
                for key, value in pairs(data.health) do
                    if value > data.previousHealth[key] then
                        local heartToRemove = DukeHelpers.Hearts[key]

                        if heartToRemove.Remove then
                            heartToRemove.Remove(player, value - data.previousHealth[key])
                        end
                    end
                end
            end
        end
        data[Tag] = nil
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
        },
        {
            ModCallbacks.MC_PRE_PICKUP_COLLISION,
            MC_PRE_PICKUP_COLLISION
        }
    },
    helpers = {
        RandomlySpawnHeartFlyFromPickup = RandomlySpawnHeartFlyFromPickup,
        ShouldSpawnExtraFly = ShouldSpawnExtraFly
    },
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.SATAN, Tag, DukeHelpers.DUKE_NAME)
}
