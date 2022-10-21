local heart = DukeHelpers.Hearts.BLACK
local attackFlySubType = DukeHelpers.OffsetIdentifier(heart)

local function ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == attackFlySubType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddFear(EntityRef(f), 150)
		end
	end
end

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == heart.subType then
		if e.Type == EntityType.ENTITY_PROJECTILE and not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
			local p = f.SpawnerEntity or Isaac.GetPlayer(0)
			p:ToPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, UseFlag.USE_NOANIM)
		end
	end
end

return {
	spritesheet = "black_heart_fly.png",
	canAttack = true,
	heart = heart,
	count = 2,
	weight = 1,
	poofColor = Color(0, 0, 0, 1, 0, 0, 0),
	sacAltarQuality = 2,
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			DukeHelpers.FLY_VARIANT
		},
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_FLY
		}
	},
	heartFlyDamageMultiplier = 1.3,
	attackFlyDamageMultiplier = 1.3,
	dropHeart = DukeHelpers.Hearts.BLACK,
	dropHeartChance = 10
}
