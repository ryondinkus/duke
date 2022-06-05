local key = "SPIDER_DOUBLE"
local use = include("spiders/red").key
local pickupSubType = HeartSubType.HEART_DOUBLEPACK
local subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(pickupSubType)

return {
    key = key,
    use = use,
    pickupSubType = pickupSubType,
    count = 4
}
