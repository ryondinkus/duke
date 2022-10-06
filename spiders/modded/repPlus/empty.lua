local heart = DukeHelpers.Hearts.EMPTY
local subType = DukeHelpers.OffsetIdentifier(heart)

return {
	spritesheet = "empty_heart_spider.png",
	heart = heart,
	count = 2,
	weight = 1,
	poofColor = Color(0, 0, 0, 1, 0, 0, 0),
	sacAltarQuality = 2,
	callbacks = {
	},
	damageMultiplier = 1.3,
	tearDamageMultiplier = 2,
	tearColor = Color(0.2, 0.2, 0.2, 1, 0, 0, 0),
	uiHeart = {
		animationPath = "gfx/ui/ui_taintedhearts.anm2",
		animationName = "EmptyHeart"
	},
}
