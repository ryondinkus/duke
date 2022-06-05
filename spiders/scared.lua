local key = "SPIDER_SCARED"
local use = include("spiders/red").key
local pickupSubType = HeartSubType.HEART_SCARED
local subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(pickupSubType)

return {
    key = key,
    use = use,
    pickupSubType = pickupSubType,
    count = 2
}
