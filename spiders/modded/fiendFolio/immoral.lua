local heart = DukeHelpers.Hearts.IMMORAL
local subType = DukeHelpers.OffsetIdentifier(heart)

return {
	spritesheet = "immoral_heart_spider.png",
	heart = heart,
	count = 2,
	weight = 1,
	poofColor = Color(0, 0, 0, 1, 0, 0, 0),
	sacAltarQuality = 2,
	callbacks = {
	},
	tearDamageMultiplier = 2,
	tearColor = Color(0.2, 0.2, 0.2, 1, 0, 0, 0),
	uiHeart = {
		animationPath = "gfx/ui/immoral_hearts.anm2",
		animationName = "ImmoralHeartHalf"
	},
}
