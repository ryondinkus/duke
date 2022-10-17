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
        leftHearts = { SOUL = 6 }
    end

    local playerData = DukeHelpers.GetDukeData(player)
    local removedHearts = {}

    local dauntlessHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.DAUNTLESS)
    if dauntlessHearts > 0 then
        removedHearts[DukeHelpers.Hearts.DAUNTLESS.key] = dauntlessHearts
        DukeHelpers.Hearts.DAUNTLESS.Remove(player, dauntlessHearts)
    end

    local soiledHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.SOILED)
    if soiledHearts > 0 then
        removedHearts[DukeHelpers.Hearts.SOILED.key] = soiledHearts
        DukeHelpers.Hearts.SOILED.Remove(player, soiledHearts)
    end

    local balefulHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.BALEFUL)
    if balefulHearts > 0 then
        removedHearts[DukeHelpers.Hearts.BALEFUL.key] = balefulHearts
        DukeHelpers.Hearts.BALEFUL.Remove(player, balefulHearts)
    end

    local miserHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.MISER)
    if miserHearts > 0 then
        removedHearts[DukeHelpers.Hearts.MISER.key] = miserHearts
        DukeHelpers.Hearts.MISER.Remove(player, miserHearts)
    end

    local emptyHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.EMPTY)
    if emptyHearts > 0 then
        removedHearts[DukeHelpers.Hearts.EMPTY.key] = emptyHearts
        DukeHelpers.Hearts.EMPTY.Remove(player, emptyHearts)
    end

    local zealotHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.ZEALOT)
    if zealotHearts > 0 then
        removedHearts[DukeHelpers.Hearts.ZEALOT.key] = zealotHearts
        DukeHelpers.Hearts.ZEALOT.Remove(player, zealotHearts)
    end

    local immoralHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.IMMORAL)
    if immoralHearts > 0 then
        removedHearts[DukeHelpers.Hearts.IMMORAL.key] = immoralHearts
        DukeHelpers.Hearts.IMMORAL.Remove(player, immoralHearts)
    end

    local morbidHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.MORBID)
    if morbidHearts > 0 then
        removedHearts[DukeHelpers.Hearts.MORBID.key] = morbidHearts
        DukeHelpers.Hearts.MORBID.Remove(player, morbidHearts)
    end

    local skippedBlackHearts = playerData.removedWebHearts or 0
    if playerData.extraSoulHearts then
        DukeHelpers.Hearts.SOUL.Remove(player, playerData.extraSoulHearts)
        playerData.extraSoulHearts = nil
    end

    local blackHearts = DukeHelpers.Clamp(getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.BLACK) -
        skippedBlackHearts, 0)

    local immortalHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.IMMORTAL)

    if immortalHearts > 0 then
        removedHearts[DukeHelpers.Hearts.IMMORTAL.key] = immortalHearts
        DukeHelpers.Hearts.IMMORTAL.Remove(player, immortalHearts)
        if playerData.previousSoulHearts and playerData.previousSoulHearts % 2 == 1 then
            DukeHelpers.Hearts.SOUL.Add(player, 1)
        end
    end

    local webHearts = getRemovableAmount(player, leftHearts, DukeHelpers.Hearts.WEB)
    if webHearts and webHearts > 0 then
        removedHearts[DukeHelpers.Hearts.WEB.key] = webHearts / 2
        DukeHelpers.Hearts.WEB.Remove(player, webHearts)
        if playerData.previousSoulHearts then
            playerData.extraSoulHearts = playerData.previousSoulHearts % 2
        end
        playerData.removedWebHearts = webHearts
    elseif skippedBlackHearts > 0 then
        playerData.removedWebHearts = nil
    end

    if blackHearts > 0 then
        removedHearts[DukeHelpers.Hearts.BLACK.key] = blackHearts
    end

    if DukeHelpers.Hearts.BLACK.GetCount(player) > 0 or skippedBlackHearts > 0 then
        if leftHearts.BLACK then
            DukeHelpers.Hearts.BLACK.Remove(player, blackHearts)
        else
            DukeHelpers.Hearts.BLACK.Remove(player, DukeHelpers.Hearts.BLACK.GetCount(player))
        end
        if playerData.previousSoulHearts and playerData.previousSoulHearts % 2 == 1 then
            if DukeHelpers.Hearts.SOUL.GetCount(player) > playerData.previousSoulHearts then
                DukeHelpers.Hearts.SOUL.Remove(player, 1)
            elseif DukeHelpers.Hearts.SOUL.GetCount(player) < playerData.previousSoulHearts then
                DukeHelpers.Hearts.SOUL.Add(player, 1)
            end
        end
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
    if redHearts > 0 then
        removedHearts[DukeHelpers.Hearts.RED.key] = redHearts
        DukeHelpers.Hearts.RED.Remove(player, redHearts)
    end

    if not ignoreContainers then
        local maxHearts = player:GetMaxHearts()
        player:AddMaxHearts(-maxHearts)
        player:AddSoulHearts(maxHearts)
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

    if not pickupKey or not DukeHelpers.IsSupportedHeart(pickup) or not DukeHelpers.Hearts[pickupKey].CanPick then
        return false
    end

    local canPickHealth = DukeHelpers.Hearts[pickupKey].CanPick(player)

    return not not canPickHealth
end

function DukeHelpers.GetBaseHearts()
    return DukeHelpers.Filter(DukeHelpers.Hearts, function(heart) return heart.isBase end)
end

function DukeHelpers.MakeFakePickup(pickup)
    return { Price = 0, Variant = pickup.Variant, SubType = pickup.SubType, Type = pickup.Type }
end

function DukeHelpers.GetBaseHeartKey(heart)
    local h = heart

    while h.uses do
        h = heart.uses
    end

    return h.key
end
