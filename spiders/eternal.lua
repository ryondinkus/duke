local key = "SPIDER_ETERNAL"
local pickupSubType = HeartSubType.HEART_ETERNAL
local subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(pickupSubType)

local function MC_POST_NPC_DEATH(_, e)
	if e.Variant == FamiliarVariant.BLUE_SPIDER and e.SubType == subType then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, e.Position, Vector.Zero, e)
	end
end

local function applyTearEffects(tear)
	tear:AddTearFlags(TearFlags.TEAR_PIERCING)
end

return {
	key = key,
	spritesheet = "eternal_heart_spider.png",
	pickupSubType = pickupSubType,
	count = 1,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.78, 0.78),
	sfx = SoundEffect.SOUND_SUPERHOLY,
	callbacks = {
		{
			ModCallbacks.MC_POST_NPC_DEATH,
			MC_POST_NPC_DEATH,
			EntityType.ENTITY_FAMILIAR
		}
	},
	damageMultiplier = 1.5,
	applyTearEffects = applyTearEffects,
	tearDamageMultiplier = 4
}
