function DukeHelpers.IsHeart(pickup, heart)
    if not heart then
        return DukeHelpers.IsSupportedHeart(pickup)
    else
        return pickup.Variant == heart.variant and pickup.SubType == heart.subType
    end
end

function DukeHelpers.ForEachHeartVariant(callback)
    callback(PickupVariant.PICKUP_HEART)
    for _, heart in pairs(DukeHelpers.Hearts) do
        if heart.variant ~= PickupVariant.PICKUP_HEART then
            callback(heart.variant)
        end
    end
end

function DukeHelpers.GetKeyFromPickup(pickup)
    if pickup and pickup.Type == EntityType.ENTITY_PICKUP then
        local foundHeart = DukeHelpers.Find(DukeHelpers.Hearts, function(heart)
            return pickup.Variant == heart.variant and pickup.SubType == heart.subType and not heart.notCollectible
        end)
        return foundHeart and foundHeart.key
    end
end

function DukeHelpers.IsSupportedHeart(pickup)
    return not not DukeHelpers.GetKeyFromPickup(pickup)
end

local function getRemovableAmount(player, leftHearts, heart)
    return DukeHelpers.Clamp(heart.GetCount(player) - (leftHearts[heart.key] or 0), 0)
end

function DukeHelpers.RemoveUnallowedHearts(player, leftHearts, ignoreContainers)
    if not leftHearts then
        leftHearts = { SOUL = 4 }
    end

    local playerData = DukeHelpers.GetDukeData(player)
    local removedHearts = {}

    local skippedBlackHearts = playerData.removedWebHearts or 0

    local blackHearts = DukeHelpers.Clamp(getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.BLACK) -
        skippedBlackHearts, 0)

    local immortalHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.IMMORTAL)

    if immortalHearts > 0 then
        removedHearts[DukeHelpers.Hearts.IMMORTAL.key] = immortalHearts
        DukeHelpers.Hearts.IMMORTAL.Remove(player, immortalHearts)
    end

    local webHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.WEB)
    if webHearts and webHearts > 0 then
        removedHearts[DukeHelpers.Hearts.WEB.key] = webHearts / 2
        DukeHelpers.Hearts.WEB.Remove(player, webHearts)
        playerData.removedWebHearts = webHearts
    elseif skippedBlackHearts > 0 and blackHearts > 0 then
        playerData.removedWebHearts = nil
    end

    if blackHearts > 0 then
        removedHearts[DukeHelpers.Hearts.BLACK.key] = blackHearts
    end

    if DukeHelpers.Hearts.BLACK.GetCount(player) > 0 or skippedBlackHearts > 0 then
        DukeHelpers.Hearts.BLACK.Remove(player, DukeHelpers.Hearts.BLACK.GetCount(player))
    end

    local brokenHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.BROKEN)
    if brokenHearts > 0 then
        removedHearts[DukeHelpers.Hearts.BROKEN.key] = brokenHearts * 2
        DukeHelpers.Hearts.BROKEN.Remove(player, brokenHearts)
    end

    local eternalHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.ETERNAL)
    if eternalHearts > 0 then
        removedHearts[DukeHelpers.Hearts.ETERNAL.key] = eternalHearts
        DukeHelpers.Hearts.ETERNAL.Remove(player, eternalHearts)
    end

    local goldenHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.GOLDEN)
    if goldenHearts > 0 then
        removedHearts[DukeHelpers.Hearts.GOLDEN.key] = goldenHearts
        DukeHelpers.Hearts.GOLDEN.Remove(player, goldenHearts)
    end

    local rottenHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.ROTTEN)
    if rottenHearts > 0 then
        removedHearts[DukeHelpers.Hearts.ROTTEN.key] = rottenHearts
        DukeHelpers.Hearts.ROTTEN.Remove(player, rottenHearts)
    end

    local redHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.RED)
    if not ignoreContainers then
        redHearts = redHearts + player:GetMaxHearts()
    end

    if redHearts > 0 then
        removedHearts[DukeHelpers.Hearts.RED.key] = redHearts
        DukeHelpers.Hearts.RED.Remove(player, redHearts)

        if not ignoreContainers then
            player:AddMaxHearts(-player:GetMaxHearts())
        end
    end

    local soulHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.SOUL)
    if soulHearts > 0 then
        removedHearts[DukeHelpers.Hearts.SOUL.key] = soulHearts
        DukeHelpers.Hearts.SOUL.Remove(player, soulHearts)
    end

    local moonHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.MOONLIGHT)
    if moonHearts and moonHearts > 0 then
        removedHearts[DukeHelpers.Hearts.MOONLIGHT.key] = moonHearts
        DukeHelpers.Hearts.MOONLIGHT.Remove(player, DukeHelpers.Hearts.MOONLIGHT.GetCount(player))
    end

    local boneHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.BONE)
    if boneHearts > 0 then
        removedHearts[DukeHelpers.Hearts.BONE.key] = boneHearts
        DukeHelpers.Hearts.BONE.Remove(player, boneHearts)
    end

    return removedHearts
end

function DukeHelpers.CanPickUpHeart(player, pickup)
    local pickupKey = DukeHelpers.GetKeyFromPickup(pickup)

    if not pickupKey then
        return false
    end

    local heart = DukeHelpers.Hearts[pickupKey]

    if not heart then
        return false
    end

    return heart.CanPick(player)
end

function DukeHelpers.GetBaseHearts()
    return DukeHelpers.Filter(DukeHelpers.Hearts, function(heart) return heart.isBase end)
end
