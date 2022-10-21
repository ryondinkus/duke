local heart = DukeHelpers.Hearts.DAUNTLESS
local attackFlySubType = DukeHelpers.OffsetIdentifier(heart)

local function ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == attackFlySubType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddConfusion(EntityRef(f), 150, false)
		end
	end
end

local function HEART_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == heart.subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) and
			DukeHelpers.rng:RandomInt(3) == 0 then
			e:AddConfusion(EntityRef(f), 150, false)

		end
	end
end

local function MC_POST_PLAYER_UPDATE(_, player)
	local effects = player:GetEffects()
	local playerData = DukeHelpers.GetDukeData(player)
	local collectibleNum = effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_WAFER)
	local dauntlessFlyCount = DukeHelpers.CountByProperties(playerData.heartFlies,
		{ key = DukeHelpers.Flies.DAUNTLESS.key })

	if dauntlessFlyCount > 0
		and (not playerData.flyDauntlessWafer or collectibleNum <= 0) then
		if collectibleNum <= 0 then
			effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER, false)
			playerData.flyDauntlessWafer = true
		end
	elseif dauntlessFlyCount <= 0 and
		playerData.flyDauntlessWafer then
		if collectibleNum > 0 then
			effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER)
			playerData.flyDauntlessWafer = nil
		end
	end
end

local function MC_POST_NPC_DEATH(_, npc)
	if npc.MaxHitPoints <= 5 then
		return
	end

	local spawnDauntlessHearts = false

	DukeHelpers.ForEachPlayer(function(player)
		local playerData = DukeHelpers.GetDukeData(player)
		if DukeHelpers.CountByProperties(playerData.heartFlies,
			{ key = DukeHelpers.Flies.DAUNTLESS.key }) % 2 == 1 then
			spawnDauntlessHearts = true
		end
	end)

	if spawnDauntlessHearts then
		local angle = DukeHelpers.rng:RandomInt(360)

		if DukeHelpers.PercentageChance(20) then
			local fadingHeart = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,
				DukeHelpers.Hearts.HALF_DAUNTLESS.subType, npc.Position, Vector.FromAngle(angle) * 12.5, nil)
			fadingHeart:GetData().fadeTimeout = 45
		end
	end
end

return {
	spritesheet = "dauntless_heart_fly.png",
	canAttack = true,
	heart = heart,
	count = 2,
	weight = 1,
	poofColor = Color(0.6, 0.6, 0.6, 1, 0.3, 0.3, 0.3),
	sacAltarQuality = 2,
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			HEART_FLY_MC_PRE_FAMILIAR_COLLISION,
			DukeHelpers.FLY_VARIANT
		},
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_FLY
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
	heartFlyDamageMultiplier = 1.3,
	attackFlyDamageMultiplier = 1.3,
	dropHeart = DukeHelpers.Hearts.DAUNTLESS,
	dropHeartChance = 10
}
