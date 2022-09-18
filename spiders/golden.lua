local heart = DukeHelpers.Hearts.GOLDEN
local subType = DukeHelpers.OffsetIdentifier(heart)

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddMidasFreeze(EntityRef(f), 150)
		end
	end
end

local function MC_POST_ENTITY_REMOVE(_, e)
	if e.Variant == FamiliarVariant.BLUE_SPIDER and e.SubType == subType then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, e.Position,
			Vector.FromAngle(DukeHelpers.rng:RandomInt(0, 360)), e)
	end
end

local function applyTearEffects(tear)
	tear:AddTearFlags(TearFlags.TEAR_MIDAS)
end

return {
	spritesheet = "gold_heart_spider.png",
	heart = heart,
	count = 1,
	weight = 1,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.55, 0),
	sfx = SoundEffect.SOUND_GOLD_HEART,
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_SPIDER
		},
		{
			ModCallbacks.MC_POST_ENTITY_REMOVE,
			MC_POST_ENTITY_REMOVE,
			EntityType.ENTITY_FAMILIAR
		}
	},
	applyTearEffects = applyTearEffects,
	tearDamageMultiplier = 1.5,
	tearColor = Color(0.9, 0.8, 0.1, 1, 0.4, 0.2, 0),
	uiHeart = {
		animationName = "RedHeartFull",
		overlayAnimationName = "GoldHeartOverlay"
	}
}
