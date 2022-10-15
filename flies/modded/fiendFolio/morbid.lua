local heart = DukeHelpers.Hearts.MORBID
local attackFlySubType = DukeHelpers.OffsetIdentifier(heart)

local function HEART_FLY_MC_PRE_FAMILIAR_PROJECTILE_COLLISION(_, f, e)
	if f.SubType == heart.variant then
		if e.Type == EntityType.ENTITY_PROJECTILE and not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
			Isaac.Spawn(Isaac.GetEntityTypeByName("Morbid Chunk"), Isaac.GetEntityVariantByName("Morbid Chunk"), 2302, f.Position, Vector.Zero, f.Player)
		end
	end
end

local function HEART_FLY_MC_PRE_FAMILIAR_ENEMY_COLLISION(_, f, e)
	if f.SubType == heart.variant then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) and DukeHelpers.rng:RandomInt(3) == 0 then
			FiendFolio.AddBruise(e, f.Player, 60, 1, f.Player.Damage / 4)
		end
	end
end

return {
	spritesheet = "morbid_heart_fly.png",
	heart = heart,
	count = 3,
	weight = 1,
    poofColor = Color(0.12, 0.82, 0.12, 1, 0, 0, 0),
	sacAltarQuality = 2,
	sfx = SoundEffect.SOUND_ROTTEN_HEART,
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			HEART_FLY_MC_PRE_FAMILIAR_PROJECTILE_COLLISION,
			DukeHelpers.FLY_VARIANT
		},
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			HEART_FLY_MC_PRE_FAMILIAR_ENEMY_COLLISION,
			DukeHelpers.FLY_VARIANT
		}
	},
	heartFlyDamageMultiplier = 1.3,
	attackFlyDamageMultiplier = 1.3,
	dropHeart = DukeHelpers.Hearts.MORBID,
	dropHeartChance = 0
}
