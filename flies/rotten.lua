local key = "FLY_ROTTEN"
local spritesheet = "gfx/familiars/rotten_heart_fly.png"
local canAttack = true
local subType = HeartSubType.HEART_ROTTEN
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)

return {
    key = key,
    spritesheet = spritesheet,
    canAttack = canAttack,
    subType = subType
}