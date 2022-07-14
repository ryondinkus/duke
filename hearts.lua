DukeHelpers.Hearts = {
    RED = {
        subType = HeartSubType.HEART_FULL
    },
    HALF_RED = {
        subType = HeartSubType.HEART_HALF
    },
    SOUL = {
        subType = HeartSubType.HEART_SOUL
    },
    ETERNAL = {
        subType = HeartSubType.HEART_ETERNAL
    },
    DOUBLE_RED = {
        subType = HeartSubType.HEART_DOUBLEPACK
    },
    BLACK = {
        subType = HeartSubType.HEART_BLACK
    },
    GOLDEN = {
        subType = HeartSubType.HEART_GOLDEN
    },
    HALF_SOUL = {
        subType = HeartSubType.HEART_HALF_SOUL
    },
    SCARED = {
        subType = HeartSubType.HEART_SCARED
    },
    BLENDED = {
        subType = HeartSubType.HEART_BLENDED
    },
    BONE = {
        subType = HeartSubType.HEART_BONE
    },
    ROTTEN = {
        subType = HeartSubType.HEART_ROTTEN
    },
    BROKEN = {
        subType = 13,
        notCollectible = true
    },
    MOONLIGHT = {
        variant = 901
    },
    PATCHED = {
        subType = 3320
    },
    DOUBLE_PATCHED = {
        subType = 3321
    },
    IMMORTAL = {
        subType = 902
    },
    WEB = {
        variant = 2000
    },
    DOUBLE_WEB = {
        variant = 2002
    }
}

for key, heart in pairs(DukeHelpers.Hearts) do
    if not heart.variant then
        heart.variant = PickupVariant.PICKUP_HEART
    elseif not heart.subType then
        heart.subType = 0
    end

    if not heart.key then
        heart.key = key
    end
end
