local key = "SPIDER_RED"
local pickupSubType = HeartSubType.HEART_FULL
local subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(pickupSubType)

return {
    key = key,
    spritesheet = "gfx/familiars/red_heart_spider.png",
    pickupSubType = pickupSubType,
    count = 2,
    weight = 2,
    poofColor = Color(0.62, 0.62, 0.62, 1, 0.61, 0, 0.12)
}
