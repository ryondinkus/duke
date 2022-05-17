local key = "WISP_RED"
local heartType = HeartSubType.HEART_FULL
local attackFlyToSpawn = DukeHelpers.GetAttackFlySubTypeBySubType(heartType)

return {
    key = key,
    heartType = heartType,
    attackFlyToSpawn = attackFlyToSpawn,
    color = Color(0.8, 0.2, 0.3, 1, 0, 0, 0),
    tearFlags = 0
}
