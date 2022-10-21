local heart = DukeHelpers.Hearts.MISER
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

local function MC_POST_PICKUP_INIT(_, pickup)
	if pickup.Price <= 0 then return end

	DukeHelpers.ForEachPlayer(function(player)
		local filledSlots = DukeHelpers.GetFilledRottenGulletSlots(player)
		local miserHearts = DukeHelpers.CountOccurencesInTable(filledSlots, DukeHelpers.Spiders.MISER.key)

		pickup.Price = math.max(1, math.floor(pickup.Price * (1 - 0.1 * ((miserHearts + 1) // 2))))
		pickup.AutoUpdatePrice = false
	end)
end

local function applyTearEffects(tear)
	local function tearCollision(_, t)
		if tear.InitSeed == t.InitSeed and DukeHelpers.PercentageChance(50) then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, tear.Position,
				Vector.FromAngle(DukeHelpers.rng:RandomInt(360)), tear)
			dukeMod:RemoveCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, tearCollision)
		end
	end

	dukeMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, tearCollision)
end

local function onRelease(player)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, UseFlag.USE_NOANIM)
	DukeHelpers.sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY)
end

return {
	spritesheet = "miser_heart_spider.png",
	heart = heart,
	count = 2,
	weight = 1,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.55, 0),
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_SPIDER
		},
		{
			ModCallbacks.MC_POST_PICKUP_INIT,
			MC_POST_PICKUP_INIT
		}
	},
	applyTearEffects = applyTearEffects,
	onRelease = onRelease,
	tearDamageMultiplier = 1.5,
	tearColor = Color(0.9, 0.8, 0.1, 1, 0.4, 0.2, 0),
	uiHeart = {
		animationPath = "gfx/ui/ui_taintedhearts.anm2",
		animationName = "MiserHeartHalf"
	},
}
