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
