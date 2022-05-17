local key = "WISP_ROTTEN"
local heartType = HeartSubType.HEART_ROTTEN
local attackFlyToSpawn = DukeHelpers.GetAttackFlySubTypeBySubType(heartType)

return {
    key = key,
    heartType = heartType,
    attackFlyToSpawn = attackFlyToSpawn,
    color = Color(0.8, 0.4, 0.3, 1, 0, 0, 0),
    tearFlags = TearFlags.TEAR_POISON
}
