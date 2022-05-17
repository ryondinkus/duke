local key = "WISP_SOUL"
local heartType = HeartSubType.HEART_SOUL
local attackFlyToSpawn = DukeHelpers.GetAttackFlySubTypeBySubType(heartType)

return {
    key = key,
    heartType = heartType,
    attackFlyToSpawn = attackFlyToSpawn,
    color = Color(0.3, 0.5, 0.7, 1, 0, 0, 0),
    tearFlags = 0
}
