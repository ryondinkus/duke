local key = "FLY_RED"
local subType = HeartSubType.HEART_FULL
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)

return {
    key = key,
    spritesheet = "gfx/familiars/red_heart_fly.png",
    canAttack = true,
    subType = subType,
    fliesCount = 2,
	weight = 2
}