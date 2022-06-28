local key = "FIENDISH"
local subType = 102
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)

return {
    key = key,
    spritesheet = "fiendish_heart_fly.png",
    canAttack = false,
    subType = subType,
    poofColor = Color(0.62, 0.62, 0.62, 1, 0.68, 0.22, 0.90),
    sacAltarQuality = 6,
    heartFlyDamageMultiplier = 1.3
}
