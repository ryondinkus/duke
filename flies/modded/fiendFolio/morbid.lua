local heart = DukeHelpers.Hearts.MORBID
local attackFlySubType = DukeHelpers.OffsetIdentifier(heart)

return {
	spritesheet = "morbid_heart_fly.png",
	canAttack = true,
	heart = heart,
	count = 3,
	weight = 1,
	poofColor = Color(0, 0, 0, 1, 0, 0, 0),
	sacAltarQuality = 2,
	callbacks = {
	},
	heartFlyDamageMultiplier = 1.3,
	attackFlyDamageMultiplier = 1.3
}
