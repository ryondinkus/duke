local key = "FLY_BLENDED"
local useFlies = {
    {
        key = include("flies/red").key,
        amount = 1
    },
    {
        key = include("flies/soul").key,
        amount = 1
    }
}
local subType = HeartSubType.HEART_BLENDED

return {
    key = key,
    useFlies = useFlies,
    subType = subType,
    fliesCount = 1
}
