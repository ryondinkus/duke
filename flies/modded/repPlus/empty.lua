local heart = DukeHelpers.Hearts.EMPTY
local attackFlySubType = DukeHelpers.OffsetIdentifier(heart)

local function ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == attackFlySubType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
		end
	end
end

local function HEART_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == heart.subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) and
			DukeHelpers.rng:RandomInt(3) == 0 then
			e:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
		end
	end
end

local function MC_POST_NEW_LEVEL()
	DukeHelpers.ForEachPlayer(function(player)
		playerData = DukeHelpers.GetDukeData(player)
		local emptyFlyCount = DukeHelpers.CountByProperties(playerData.heartFlies, { key = DukeHelpers.Flies.EMPTY.key })
		for i = 1, emptyFlyCount do
			Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST, 7, player.Position, Vector.Zero, player) -- subtype 7 makes the locust persist between rooms for some fucked up evil reason
		end
	end)
end

return {
	spritesheet = "empty_heart_fly.png",
	canAttack = true,
	heart = heart,
	count = 1,
	weight = 1,
	poofColor = Color(0, 0.2, 0, 1, 0, 0, 0),
	sacAltarQuality = 4,
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_FLY
		},
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			HEART_FLY_MC_PRE_FAMILIAR_COLLISION,
			DukeHelpers.FLY_VARIANT
		},
		{
			ModCallbacks.MC_POST_NEW_LEVEL,
			MC_POST_NEW_LEVEL
		}
	},
	heartFlyDamageMultiplier = 1.3,
	attackFlyDamageMultiplier = 1.3,
	dropHeart = DukeHelpers.Hearts.EMPTY,
	dropHeartChance = 20
}
