local key = "FLY_SOUL"
local subType = HeartSubType.HEART_SOUL
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)

return {
    key = key,
    spritesheet =  "gfx/familiars/soul_heart_fly.png",
    canAttack = true,
    subType = subType,
    fliesCount = 2,
	weight = 2,
    sfx = SoundEffect.SOUND_HOLY
}