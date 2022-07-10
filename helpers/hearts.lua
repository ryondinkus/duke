function DukeHelpers.IsHeart(pickup, heart)
    if not heart then
        return DukeHelpers.IsSupportedHeart(pickup)
    else
        return pickup.Variant == heart.variant and pickup.SubType == heart.subType
    end
end
