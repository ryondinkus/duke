local key = "SPIDER_MOONLIGHT" -- From Moonlight Hearts Mod
local pickupSubType = 901
local subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(pickupSubType)

return {
	key = key,
	spritesheet = "gfx/familiars/moonlight_heart_spider.png",
	pickupSubType = pickupSubType,
	count = 1,
	weight = 0,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.90, 0.78, 1),
	sfx = SoundEffect.SOUND_SOUL_PICKUP,
	damageMultiplier = 1.3
}
