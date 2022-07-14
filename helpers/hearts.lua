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

function DukeHelpers.IsMoonlightHeart(pickup)
    return DukeHelpers.IsHeart(pickup, DukeHelpers.Hearts.MOONLIGHT)
end

function DukeHelpers.IsImmortalHeart(pickup)
    return DukeHelpers.IsHeart(pickup, DukeHelpers.Hearts.IMMORTAL)
end

function DukeHelpers.IsPatchedHeart(pickup)
    return DukeHelpers.IsHeart(pickup, DukeHelpers.Hearts.PATCHED) or
        DukeHelpers.IsHeart(pickup, DukeHelpers.Hearts.DOUBLE_PATCHED)
end

function DukeHelpers.IsWebHeart(pickup)
    return DukeHelpers.IsHeart(pickup, DukeHelpers.Hearts.WEB)
end

function DukeHelpers.IsDoubleWebHeart(pickup)
    return DukeHelpers.IsHeart(pickup, DukeHelpers.Hearts.DOUBLE_WEB)
end
