local key = "WISP_BLACK"
local heartType = HeartSubType.HEART_BLACK
local attackFlyToSpawn = DukeHelpers.GetAttackFlySubTypeBySubType(heartType)

return {
    key = key,
    heartType = heartType,
    attackFlyToSpawn = attackFlyToSpawn,
    color = Color(0.1, 0.1, 0.1, 1, 0, 0, 0),
    tearFlags = TearFlags.TEAR_FEAR
}
