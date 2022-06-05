local key = "SPIDER_BLENDED"
local uses = {
    {
        key = include("spiders/red").key,
        count = 1
    },
    {
        key = include("spiders/soul").key,
        count = 1
    }
}
local pickupSubType = HeartSubType.HEART_BLENDED

return {
    key = key,
    uses = uses,
    pickupSubType = pickupSubType,
    count = 1
}
