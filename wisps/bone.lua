local key = "WISP_BONE"
local heartType = HeartSubType.HEART_BONE
local attackFlyToSpawn = DukeHelpers.GetAttackFlySubTypeBySubType(heartType)

return {
    key = key,
    heartType = heartType,
    attackFlyToSpawn = attackFlyToSpawn,
    color = Color(0.8, 0.8, 0.8, 1, 0, 0, 0),
    tearFlags = TearFlags.TEAR_CONFUSION
}
