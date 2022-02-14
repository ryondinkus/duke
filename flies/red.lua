local key = "FLY_RED"
local spritesheet = "gfx/familiars/red_heart_fly.png"
local canAttack = true
local subType = HeartSubType.HEART_FULL
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)
local fliesCount = 2

return {
    key = key,
    spritesheet = spritesheet,
    canAttack = canAttack,
    subType = subType,
    fliesCount = fliesCount
}