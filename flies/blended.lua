local key = "BLENDED"
local uses = {
    {
        key = include("flies/red").key,
        count = 1
    },
    {
        key = include("flies/soul").key,
        count = 1
    }
}
local subType = HeartSubType.HEART_BLENDED

return {
    key = key,
    uses = uses,
    subType = subType,
    count = 1
}
