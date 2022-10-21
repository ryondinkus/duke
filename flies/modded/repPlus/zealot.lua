local heart = DukeHelpers.Hearts.ZEALOT
local attackFlySubType = DukeHelpers.OffsetIdentifier(heart)

local function ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == attackFlySubType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddEntityFlags(EntityFlag.FLAG_ICE)
		end
	end
end

local function HEART_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == heart.subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) and
			DukeHelpers.rng:RandomInt(3) == 0 then
			e:AddEntityFlags(EntityFlag.FLAG_ICE)
		end
	end
end

local function MC_POST_NEW_LEVEL()
	DukeHelpers.ForEachPlayer(function(player)
		playerData = DukeHelpers.GetDukeData(player)
		local zealotFlyCount = DukeHelpers.CountByProperties(playerData.heartFlies, { key = DukeHelpers.Flies.ZEALOT.key })
		for i = 1, zealotFlyCount do
			player:AddItemWisp(Game():GetItemPool():GetCollectible(DukeHelpers.rng:RandomInt(ItemPoolType.NUM_ITEMPOOLS)),
				player.Position, true)
		end
	end)
end

return {
	spritesheet = "zealot_heart_fly.png",
	canAttack = true,
	heart = heart,
	count = 2,
	weight = 1,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.58, 0.12, 0.80),
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
			ModCallbacks.MC_POST_NEW_LEVEL,
			MC_POST_NEW_LEVEL
		}
	},
	heartFlyDamageMultiplier = 1.3,
	attackFlyDamageMultiplier = 1.3,
	dropHeart = DukeHelpers.Hearts.ZEALOT,
	dropHeartChance = 10
}
