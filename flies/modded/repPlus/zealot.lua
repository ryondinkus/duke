local heart = DukeHelpers.Hearts.ZEALOT
local attackFlySubType = DukeHelpers.OffsetIdentifier(heart)

return {
	spritesheet = "zealot_heart_fly.png",
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
