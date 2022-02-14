local key = "FLY_BROKEN"
local spritesheet = "gfx/familiars/broken_heart_fly.png"
local canAttack = false
local subType = 13 -- Not a valid heart pickup
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)

return {
    key = key,
    spritesheet = spritesheet,
    canAttack = canAttack,
    subType = subType
}