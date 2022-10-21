local heart = DukeHelpers.Hearts.GOLDEN
local subType = DukeHelpers.OffsetIdentifier(heart)

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddMidasFreeze(EntityRef(f), 150)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, f.Position,
				Vector.FromAngle(DukeHelpers.rng:RandomInt(360)), f)
		end
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
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_SPIDER
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
