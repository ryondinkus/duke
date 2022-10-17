local heart = DukeHelpers.Hearts.ETERNAL
local subType = DukeHelpers.OffsetIdentifier(heart)

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, f.Position, Vector.Zero, f.Player)
		end
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
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_SPIDER
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
