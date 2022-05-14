local key = "WISP_GOLDEN"
local heartType = HeartSubType.HEART_GOLDEN
local attackFlyToSpawn = DukeHelpers.GetAttackFlySubTypeBySubType(heartType)

return {
    key = key,
    heartType = heartType,
    attackFlyToSpawn = attackFlyToSpawn,
    color = Color(0.8, 0.7, 0.2, 1, 0, 0, 0),
    tearFlags = TearFlags.TEAR_MIDAS
}
