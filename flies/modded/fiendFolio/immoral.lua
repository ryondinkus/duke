local heart = DukeHelpers.Hearts.IMMORAL
local attackFlySubType = DukeHelpers.OffsetIdentifier(heart)

local function HEART_FLY_MC_PRE_FAMILIAR_PROJECTILE_COLLISION(_, f, e)
	if f.SubType == heart.variant then
		if e.Type == EntityType.ENTITY_PROJECTILE and not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
			local minion = Isaac.Spawn(EntityType.ENTITY_PICKUP, Isaac.GetEntityVariantByName("Fiend Minion (Half Immoral)"), 3,
				f.Position, Vector.Zero, f.Player)
			minion:GetSprite():Play("Drop")
		end
	end
end

return {
	spritesheet = "immoral_heart_fly.png",
	heart = heart,
	count = 2,
	weight = 1,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.28, 0, 0.50),
	sacAltarQuality = 2,
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			HEART_FLY_MC_PRE_FAMILIAR_PROJECTILE_COLLISION,
			DukeHelpers.FLY_VARIANT
		}
	},
	heartFlyDamageMultiplier = 1.5,
	attackFlyDamageMultiplier = 1.5,
	dropHeart = DukeHelpers.Hearts.IMMORAL,
	dropHeartChance = 0
}
