local key = "MOONLIGHT" -- From Moonlight Hearts Mod
local pickupSubType = 901
local subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(pickupSubType)

local function onRelease(player)
	local data = player:GetData()
	local effect = DukeHelpers.rng:RandomInt(6)
	if effect == 0 then
		Game():GetLevel():ApplyBlueMapEffect()
	elseif effect == 1 then
		Game():GetLevel():ApplyCompassEffect()
	elseif effect == 2 then
		Game():GetLevel():ApplyMapEffect()
	elseif effect == 3 then
		Game():GetLevel():RemoveCurses(LevelCurse.CURSE_OF_DARKNESS | LevelCurse.CURSE_OF_BLIND | LevelCurse.CURSE_OF_THE_LOST | LevelCurse.CURSE_OF_THE_UNKNOWN | LevelCurse.CURSE_OF_MAZE)
	elseif effect == 4 then
		player:UseCard(Card.CARD_SOUL_CAIN, (UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOANIM))
	elseif effect == 5 then
		data.moontears = data.moontears + 2
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
	end
end

return {
	key = key,
	spritesheet = "moonlight_heart_spider.png",
	pickupSubType = pickupSubType,
	count = 1,
	weight = 0,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.90, 0.78, 1),
	sfx = SoundEffect.SOUND_SOUL_PICKUP,
	damageMultiplier = 1.3,
	tearDamageMultiplier = 2,
	tearColor = Color(0.9, 0.8, 1, 1, 0.7, 0.5, 0.9),
	uiHeart = {
		animationPath = "gfx/ui/moon hearts ui.anm2",
		animationName = "1",
		renderAbove = {
			animationName = "RedHeartFull"
		},
		spriteOffset = Vector(0, -1)
	},
	onRelease = onRelease
}
