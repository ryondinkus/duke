local key = "FLY_SOUL"
local spritesheet = "gfx/familiars/soul_heart_fly.png"
local canAttack = true
local subType = HeartSubType.HEART_SOUL
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)

return {
    key = key,
    spritesheet = spritesheet,
    canAttack = canAttack,
    subType = subType
}