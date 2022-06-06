local key = "FLY_SOUL"
local subType = HeartSubType.HEART_SOUL
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)

return {
    key = key,
    spritesheet = "soul_heart_fly.png",
    canAttack = true,
    subType = subType,
    fliesCount = 2,
    weight = 2,
    poofColor = Color(0.62, 0.62, 0.62, 1, 0, 0.25, 0.43),
    sacAltarQuality = 2,
    sfx = SoundEffect.SOUND_HOLY
}
