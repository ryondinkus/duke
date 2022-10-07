local heart = DukeHelpers.Hearts.DAUNTLESS
local subType = DukeHelpers.OffsetIdentifier(heart)

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddConfusion(EntityRef(f), 150)
		end
	end
end

local function applyTearEffects(tear)
	tear:AddTearFlags(TearFlags.TEAR_CONFUSION)
end

local function MC_POST_PLAYER_UPDATE(_, player)
	local effects = player:GetEffects()
	local playerData = DukeHelpers.GetDukeData(player)
	local collectibleNum = effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_WAFER)
	local filledSlots = DukeHelpers.GetFilledRottenGulletSlots(player)
	local dauntlessHearts = DukeHelpers.CountOccurencesInTable(filledSlots, DukeHelpers.Spiders.DAUNTLESS.key)

	if dauntlessHearts > 0
		and (not playerData.dauntlessWafer or collectibleNum <= 0) then
		if collectibleNum <= 0 then
			effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER, false)
			playerData.dauntlessWafer = true
		end
	elseif dauntlessHearts <= 0 and
		playerData.dauntlessWafer then
		if collectibleNum > 0 then
			effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER)
			playerData.dauntlessWafer = nil
		end
	end
end

local function MC_POST_NPC_DEATH(_, npc)
	if npc.MaxHitPoints <= 5 then
		return
	end

	local spawnDauntlessHearts = false

	DukeHelpers.ForEachPlayer(function(player)
		local filledSlots = DukeHelpers.GetFilledRottenGulletSlots(player)
		local dauntlessHearts = DukeHelpers.CountOccurencesInTable(filledSlots, DukeHelpers.Spiders.DAUNTLESS.key)

		if dauntlessHearts % 2 == 1 then
			spawnDauntlessHearts = true
		end
	end)

	if spawnDauntlessHearts then
		local angle = DukeHelpers.rng:RandomInt(360)

		if DukeHelpers.PercentageChance(20) then
			local fadingHeart = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,
				DukeHelpers.Hearts.HALF_DAUNTLESS.subType, npc.Position, Vector.FromAngle(angle) * 12.5, nil) -- 101 is the half dauntless heart lol!!!
			fadingHeart:GetData().fadeTimeout = 45
		end
	end
end

return {
	spritesheet = "dauntless_heart_spider.png",
	heart = heart,
	count = 2,
	weight = 1,
	poofColor = Color(0.6, 0.6, 0.6, 1, 0.3, 0.3, 0.3),
	sfx = SoundEffect.SOUND_DIVINE_INTERVENTION,
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_SPIDER
		},
		{
			ModCallbacks.MC_POST_PLAYER_UPDATE,
			MC_POST_PLAYER_UPDATE
		},
		{
			ModCallbacks.MC_POST_NPC_DEATH,
			MC_POST_NPC_DEATH
		}

	},
	applyTearEffects = applyTearEffects,
	damageMultiplier = 1.3,
	tearDamageMultiplier = 2,
	tearColor = Color(0.4, 0.4, 0.4, 1, 0.4, 0.4, 0.4),
	uiHeart = {
		animationPath = "gfx/ui/ui_taintedhearts.anm2",
		animationName = "DauntlessHeartHalf"
	}
}
