local key = "BLENDED"
local useFlies = {
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
    useFlies = useFlies,
    subType = subType,
    count = 1
}
