local key = "SPIDER_SOUL"
local pickupSubType = HeartSubType.HEART_SOUL
local subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(pickupSubType)

return {
    key = key,
    spritesheet = "soul_heart_spider.png",
    pickupSubType = pickupSubType,
    count = 2,
    weight = 2,
    poofColor = Color(0.62, 0.62, 0.62, 1, 0, 0.25, 0.43),
    sfx = SoundEffect.SOUND_HOLY,
    tearDamageMultiplier = 1.5
}
