local key = "RED"
local pickupSubType = HeartSubType.HEART_FULL
local subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(pickupSubType)

return {
    key = key,
    spritesheet = "red_heart_spider.png",
    pickupSubType = pickupSubType,
    count = 2,
    weight = 2,
    poofColor = Color(0.62, 0.62, 0.62, 1, 0.61, 0, 0.12),
    tearDamageMultiplier = 1.5,
    tearColor = Color(0.72, 0.20, 0.20, 1, 0.1, 0, 0.1),
    uiHeart = {
        animationName = "RedHeartHalf"
    }
}
