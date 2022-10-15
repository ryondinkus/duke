local heart = DukeHelpers.Hearts.BALEFUL
local attackFlySubType = DukeHelpers.OffsetIdentifier(heart)

local function ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == attackFlySubType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			local explosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART, 0, f.Position,
				Vector.Zero, f)
			DukeHelpers.sfx:Stop(SoundEffect.SOUND_FART)
			DukeHelpers.sfx:Play(SoundEffect.SOUND_DEMON_HIT)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, f.Position,
				Vector.Zero, f)
			explosion.Color = Color(1, 0, 0, 1, 0.2, 0, 0)
			local damage = 40
			local player = f.Player
			local radius = 75
			for _, enemy in ipairs(Isaac.FindInRadius(f.Position, radius, EntityPartition.ENEMY)) do
				enemy:TakeDamage(damage, DamageFlag.DAMAGE_EXPLOSION, EntityRef(player), 0)
			end
		end
	end
end

local function HEART_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == heart.subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			data = DukeHelpers.GetDukeData(f)
			if not data.purgatoryGhost then
				local player = f.Player
				data.purgatoryGhost = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, f.Position, Vector.Zero, f)
				data.purgatoryGhost.CollisionDamage = player.Damage / 1.25
			end
		end
	end
end

local function MC_POST_ENTITY_REMOVE(_, entity)
	if entity.Variant == EffectVariant.PURGATORY and entity.SubType == 1
	and entity.SpawnerEntity and entity.SpawnerType == EntityType.ENTITY_FAMILIAR
	and entity.SpawnerVariant == DukeHelpers.FLY_VARIANT and entity.SpawnerEntity.SubType == attackFlySubType then
		local fly = entity.SpawnerEntity
		local data = DukeHelpers.GetDukeData(fly)
		data.purgatoryGhost = nil
	end
end

return {
	spritesheet = "baleful_heart_fly.png",
	canAttack = true,
	heart = heart,
	count = 2,
	weight = 1,
	poofColor = Color(1, 1, 1, 1, 1, 1, 1),
	sacAltarQuality = 6,
	sfx = SoundEffect.SOUND_SUPERHOLY,
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
			ModCallbacks.MC_POST_ENTITY_REMOVE,
			MC_POST_ENTITY_REMOVE,
			EntityType.ENTITY_EFFECT
		}
	},
	heartFlyDamageMultiplier = 1.3,
	attackFlyDamageMultiplier = 1.3,
	dropHeart = DukeHelpers.Hearts.BALEFUL,
	dropHeartChance = 10
}
