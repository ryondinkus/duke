local heart = DukeHelpers.Hearts.SOILED
local attackFlySubType = DukeHelpers.OffsetIdentifier(heart)

local function ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == attackFlySubType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddPoison(EntityRef(f), 102, 1)
		end
	end
end

local function HEART_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == heart.subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) and
			DukeHelpers.rng:RandomInt(3) == 0 then
			e:AddPoison(EntityRef(f), 32, 1)
		end
	end
end

local function HEART_FLY_PRE_SPAWN_CLEAN_AWARD()
	for _, entity in pairs(Isaac.GetRoomEntities()) do
		if entity.Type == EntityType.ENTITY_FAMILIAR
			and entity.Variant == DukeHelpers.FLY_VARIANT
			and entity.SubType == heart.subType then
			for _ = 1, 2 do
				-- TODO Ryan ;)
				local spawnedEntity = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0,
					entity.Position, Vector.Zero, entity.SpawnerEntity)
				spawnedEntity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			end
		end
	end
end

return {
	spritesheet = "soiled_heart_fly.png",
	canAttack = true,
	heart = heart,
	count = 2,
	weight = 1,
	poofColor = Color(0, 0, 0, 1, 0, 0, 0),
	sacAltarQuality = 2,
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
			ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
			HEART_FLY_PRE_SPAWN_CLEAN_AWARD
		}
	},

	heartFlyDamageMultiplier = 1.3,
	attackFlyDamageMultiplier = 1.3
}
