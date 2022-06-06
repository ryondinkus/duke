local key = "SPIDER_IMMORTAL" -- From Team Compliance Immortal Heart Mod
local pickupSubType = HeartSubType.HEART_IMMORTAL
local subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(pickupSubType)

return {
    key = key,
    spritesheet = "immortal_heart_spider.png",
    pickupSubType = pickupSubType,
    count = 2,
    weight = 0,
    poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.78, 1),
    sfx = Isaac.GetSoundIdByName("immortal"),
    damageMultiplier = 1.3
}
