local heart = DukeHelpers.Hearts.ETERNAL
local subType = DukeHelpers.CalculateAttackFlySubType(heart)

local function MC_POST_ENTITY_REMOVE(_, e)
	if e.Variant == FamiliarVariant.BLUE_SPIDER and e.SubType == subType then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, e.Position, Vector.Zero, e)
	end
end

local function applyTearEffects(tear)
	tear:AddTearFlags(TearFlags.TEAR_PIERCING)
end

return {
	spritesheet = "eternal_heart_spider.png",
	heart = heart,
	count = 1,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.78, 0.78),
	sfx = SoundEffect.SOUND_SUPERHOLY,
	callbacks = {
		{
			ModCallbacks.MC_POST_ENTITY_REMOVE,
			MC_POST_ENTITY_REMOVE,
			EntityType.ENTITY_FAMILIAR
		}
	},
	damageMultiplier = 1.5,
	applyTearEffects = applyTearEffects,
	tearDamageMultiplier = 4,
	tearColor = Color(1, 1, 1, 1, 0.78, 0.78, 0.78),
	uiHeart = {
		animationName = "WhiteHeartHalf"
	}
}
