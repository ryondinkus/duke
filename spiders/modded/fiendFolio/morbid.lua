local heart = DukeHelpers.Hearts.MORBID
local subType = DukeHelpers.OffsetIdentifier(heart)

return {
	spritesheet = "morbid_heart_spider.png",
	heart = heart,
	count = 3,
	weight = 1,
	poofColor = Color(0, 0, 0, 1, 0, 0, 0),
	sacAltarQuality = 2,
	callbacks = {
	},
	tearDamageMultiplier = 2,
	tearColor = Color(0.2, 0.2, 0.2, 1, 0, 0, 0),
	uiHeart = {
		animationPath = "gfx/ui/morbid_hearts.anm2",
		animationName = "MorbidHeartFull"
	},
	variant = Isaac.GetEntityVariantByName("Attack Skuzz")
}
