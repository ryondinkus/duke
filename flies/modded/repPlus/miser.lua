local heart = DukeHelpers.Hearts.MISER
local attackFlySubType = DukeHelpers.OffsetIdentifier(heart)

return {
	spritesheet = "miser_heart_fly.png",
	canAttack = true,
	heart = heart,
	count = 2,
	weight = 1,
	poofColor = Color(0, 0, 0, 1, 0, 0, 0),
	sacAltarQuality = 2,
	callbacks = {
	},

	heartFlyDamageMultiplier = 1.3,
	attackFlyDamageMultiplier = 1.3
}
