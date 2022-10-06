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
			local player = entity.SpawnerEntity:ToPlayer()
			for _ = 1, DukeHelpers.rng:RandomInt(3) do
				player:AddFriendlyDip(0, player.Position)
			end
		end
	end
end

return {
	spritesheet = "soiled_heart_fly.png",
	canAttack = true,
	heart = heart,
	count = 1,
	weight = 1,
	poofColor = Color(2, 1, 1, 1, 0, 0, 0),
	sacAltarQuality = 4,
	sfx = SoundEffect.SOUND_ROTTEN_HEART,
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
	dropHeart = DukeHelpers.Hearts.SOILED,
	dropHeartChance = 20
}
