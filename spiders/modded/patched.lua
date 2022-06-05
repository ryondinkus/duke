local key = "SPIDER_PATCHED" -- from patched hearts mod
local use = include("spiders/red").key
local pickupSubType = 3320
local subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(pickupSubType)

return {
    key = key,
    use = use,
    pickupSubType = pickupSubType,
    count = 2
}
