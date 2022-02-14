local key = "FLY_BONE"
local spritesheet = "gfx/familiars/bone_heart_fly.png"
local canAttack = true
local subType = HeartSubType.HEART_BONE
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)
local fliesCount = 1

return {
    key = key,
    spritesheet = spritesheet,
    canAttack = canAttack,
    subType = subType,
    fliesCount = fliesCount
}